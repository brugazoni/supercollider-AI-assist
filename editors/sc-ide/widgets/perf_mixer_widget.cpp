/*
    SuperCollider Qt IDE — Adaptive Performance Mixer
    Copyright (c) 2026 SuperCollider AI-Assist Contributors

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#include "perf_mixer_widget.hpp"
#include "../core/sc_process.hpp"
#include "../core/sc_server.hpp"

#include <QApplication>
#include <QDateTime>
#include <QGridLayout>
#include <QHBoxLayout>
#include <QMouseEvent>
#include <QPainter>
#include <QRegularExpression>
#include <QScrollBar>
#include <QVBoxLayout>
#include <QWheelEvent>

#include <cmath>
#include <cstring>
#include <osc/OscOutboundPacketStream.h>
#include <osc/OscReceivedElements.h>
#include <yaml-cpp/yaml.h>

namespace ScIDE {

namespace {

float dbToAmp(float db) {
    if (db <= -59.9f)
        return 0.0f;
    return std::pow(10.0f, db / 20.0f);
}

QString formatDb(float db) {
    if (db <= -59.9f)
        return QStringLiteral("-inf");
    return QString("%1%2").arg(db > 0.05f ? "+" : "").arg(db, 0, 'f', 1);
}

QColor badgeColor(const QString& badge) {
    if (badge == QStringLiteral("APP"))
        return QColor(0x27ae60);
    if (badge == QStringLiteral("GEN"))
        return QColor(0x2980b9);
    if (badge == QStringLiteral("CMP"))
        return QColor(0x8e44ad);
    if (badge == QStringLiteral("DSN"))
        return QColor(0xd35400);
    return QColor(0x5d6d7e);
}

QString modeInitial(const QString& mode) {
    if (mode == QStringLiteral("compose"))
        return QStringLiteral("C");
    if (mode == QStringLiteral("design"))
        return QStringLiteral("D");
    if (mode == QStringLiteral("generate"))
        return QStringLiteral("G");
    return QStringLiteral("A");
}

} // namespace

// ============================================================================
// MixerRotaryKnob
// ============================================================================

MixerRotaryKnob::MixerRotaryKnob(const QString& title, float minVal, float maxVal, float defaultVal,
                                 bool logarithmic, const QColor& accent, QWidget* parent):
    QWidget(parent),
    mTitle(title),
    mMin(minVal),
    mMax(maxVal),
    mDefault(defaultVal),
    mValue(defaultVal),
    mLog(logarithmic),
    mAccent(accent) {
    setFixedSize(50, 50);
    setCursor(Qt::SizeVerCursor);
    setToolTip(QString("%1 (Double-click to reset)").arg(title));
}

float MixerRotaryKnob::valueToNorm(float v) const {
    float clamped = qBound(mMin, v, mMax);
    if (mLog && mMin > 0.0f && mMax > mMin) {
        return std::log(clamped / mMin) / std::log(mMax / mMin);
    }
    return (mMax > mMin) ? (clamped - mMin) / (mMax - mMin) : 0.0f;
}

float MixerRotaryKnob::normToValue(float n) const {
    float cn = qBound(0.0f, n, 1.0f);
    if (mLog && mMin > 0.0f && mMax > mMin) {
        return mMin * std::pow(mMax / mMin, cn);
    }
    return mMin + cn * (mMax - mMin);
}

void MixerRotaryKnob::setValue(float v, bool emitSignal) {
    float clamped = qBound(mMin, v, mMax);
    if (std::abs(clamped - mValue) > 1e-5f) {
        mValue = clamped;
        update();
        if (emitSignal)
            emit valueChanged(mValue);
    }
}

void MixerRotaryKnob::paintEvent(QPaintEvent*) {
    QPainter p(this);
    p.setRenderHint(QPainter::Antialiasing, true);

    const int w = width();
    const int dialSize = 24;
    const int cx = w / 2;
    const int cy = 14;
    QRectF arcRect(cx - dialSize / 2.0, cy - dialSize / 2.0, dialSize, dialSize);

    QFont f = font();
    f.setPixelSize(9);
    p.setFont(f);

    QPen bgPen(QColor(0x2c3e50), 2.8, Qt::SolidLine, Qt::RoundCap);
    p.setPen(bgPen);
    p.drawArc(arcRect, 225 * 16, -270 * 16);

    float norm = valueToNorm(mValue);
    QPen valPen(mAccent, 2.8, Qt::SolidLine, Qt::RoundCap);
    p.setPen(valPen);
    if (mBipolar) {
        float centerNorm = valueToNorm(mDefault);
        int startDeg = static_cast<int>((225.0f - centerNorm * 270.0f) * 16.0f);
        int spanDeg = static_cast<int>(-(norm - centerNorm) * 270.0f * 16.0f);
        p.drawArc(arcRect, startDeg, spanDeg);
    } else {
        int spanDeg = static_cast<int>(-norm * 270.0f * 16.0f);
        p.drawArc(arcRect, 225 * 16, spanDeg);
    }

    p.setBrush(QColor(0x1f2833));
    p.setPen(QPen(QColor(0x4a5568), 1.0));
    p.drawEllipse(QPointF(cx, cy), 8.0, 8.0);

    float angleRad = (225.0f - norm * 270.0f) * 3.14159265f / 180.0f;
    QPointF tip(cx + std::cos(angleRad) * 7.0f, cy - std::sin(angleRad) * 7.0f);
    p.setPen(QPen(Qt::white, 1.6, Qt::SolidLine, Qt::RoundCap));
    p.drawLine(QPointF(cx, cy), tip);

    QString valStr = mFormatter ? mFormatter(mValue) : QString::number(mValue, 'f', 2);
    p.setPen(QColor(0xecf0f1));
    p.drawText(QRect(0, 27, w, 11), Qt::AlignCenter, valStr);

    p.setPen(QColor(0x85929e));
    p.drawText(QRect(0, 38, w, 11), Qt::AlignCenter, mTitle);
}

void MixerRotaryKnob::mousePressEvent(QMouseEvent* e) {
    if (e->button() == Qt::LeftButton) {
        mDragging = true;
        mDragStartY = static_cast<int>(e->globalPosition().y());
        mDragStartNorm = valueToNorm(mValue);
        e->accept();
    }
}

void MixerRotaryKnob::mouseMoveEvent(QMouseEvent* e) {
    if (!mDragging)
        return;
    int dy = mDragStartY - static_cast<int>(e->globalPosition().y());
    float sens = (e->modifiers() & Qt::ShiftModifier) ? 450.0f : 140.0f;
    float newNorm = qBound(0.0f, mDragStartNorm + dy / sens, 1.0f);
    setValue(normToValue(newNorm), true);
    e->accept();
}

void MixerRotaryKnob::mouseDoubleClickEvent(QMouseEvent* e) {
    if (e->button() == Qt::LeftButton) {
        setValue(mDefault, true);
        e->accept();
    }
}

void MixerRotaryKnob::wheelEvent(QWheelEvent* e) {
    float step = (e->modifiers() & Qt::ShiftModifier) ? 0.01f : 0.04f;
    float dir = (e->angleDelta().y() > 0) ? 1.0f : -1.0f;
    float newNorm = qBound(0.0f, valueToNorm(mValue) + dir * step, 1.0f);
    setValue(normToValue(newNorm), true);
    e->accept();
}

// ============================================================================
// StereoLevelMeter
// ============================================================================

StereoLevelMeter::StereoLevelMeter(QWidget* parent): QWidget(parent) {
    setFixedWidth(16);
    setMinimumHeight(56);
}

void StereoLevelMeter::setLevels(float peakL, float rmsL, float peakR, float rmsR, bool clipped) {
    mPeakL = qBound(0.0f, peakL, 1.5f);
    mRmsL = qBound(0.0f, rmsL, 1.5f);
    mPeakR = qBound(0.0f, peakR, 1.5f);
    mRmsR = qBound(0.0f, rmsR, 1.5f);
    mClipped = clipped;
    update();
}

void StereoLevelMeter::paintEvent(QPaintEvent*) {
    QPainter p(this);
    const int w = width();
    const int h = height();
    p.fillRect(0, 0, w, h, QColor(0x0d1117));

    auto ampToNorm = [](float amp) -> float {
        if (amp <= 0.0005f)
            return 0.0f;
        float db = 20.0f * std::log10(amp);
        return qBound(0.0f, (db + 60.0f) / 60.0f, 1.0f);
    };

    const int barW = 5;
    const int gap = 2;
    const int xL = 2;
    const int xR = xL + barW + gap;
    const int clipH = 4;
    const int meterTop = clipH + 2;
    const int meterH = qMax(4, h - meterTop - 1);

    auto drawBar = [&](int x, float rms, float peak) {
        float nRms = ampToNorm(rms);
        float nPeak = ampToNorm(peak);
        int fillH = static_cast<int>(nRms * meterH);
        if (fillH > 0) {
            QLinearGradient grad(0, meterTop + meterH, 0, meterTop);
            grad.setColorAt(0.0, QColor(0x2ecc71));
            grad.setColorAt(0.72, QColor(0xf1c40f));
            grad.setColorAt(0.92, QColor(0xe74c3c));
            p.fillRect(x, meterTop + meterH - fillH, barW, fillH, grad);
        }
        int peakY = meterTop + meterH - static_cast<int>(nPeak * meterH);
        if (nPeak > 0.02f) {
            QColor pkCol = (nPeak > 0.92f) ? QColor(0xe74c3c) : QColor(0xd5f5e3);
            p.fillRect(x, qBound(meterTop, peakY, meterTop + meterH - 2), barW, 2, pkCol);
        }
    };

    drawBar(xL, mRmsL, mPeakL);
    drawBar(xR, mRmsR, mPeakR);
    p.fillRect(xL, 1, barW * 2 + gap, clipH, mClipped ? QColor(0xe74c3c) : QColor(0x1c2833));
}

// ============================================================================
// MixerChannelStrip
// ============================================================================

MixerChannelStrip::MixerChannelStrip(const QString& trackId, QWidget* parent):
    QFrame(parent),
    mTrackId(trackId) {
    setFixedWidth(104);
    setFrameShape(QFrame::StyledPanel);

    QVBoxLayout* root = new QVBoxLayout(this);
    root->setContentsMargins(4, 4, 4, 4);
    root->setSpacing(3);

    // Top row: Origin Badge
    QHBoxLayout* topRow = new QHBoxLayout;
    topRow->setContentsMargins(0, 0, 0, 0);
    topRow->setSpacing(2);

    mBadgeLabel = new QLabel(QStringLiteral("APP"));
    mBadgeLabel->setAlignment(Qt::AlignCenter);
    mBadgeLabel->setFixedHeight(14);
    mBadgeLabel->setStyleSheet("QLabel { font-size: 8px; font-weight: bold; color: #fff; border-radius: 2px; padding: 0 5px; }");
    topRow->addWidget(mBadgeLabel);
    topRow->addStretch();
    root->addLayout(topRow);

    // Track Name (includes prompt initial + index, e.g. "A5 saoLuisBell")
    mNameLabel = new QLabel(trackId);
    mNameLabel->setAlignment(Qt::AlignCenter);
    mNameLabel->setStyleSheet("QLabel { color: #ecf0f1; font-size: 10px; font-weight: bold; }");
    root->addWidget(mNameLabel);

    // 5 FX Pills: Row 0 = FLT, DST, CMP; Row 1 = DLY, REV
    QGridLayout* fxGrid = new QGridLayout;
    fxGrid->setContentsMargins(0, 0, 0, 0);
    fxGrid->setSpacing(2);
    const char* fxNames[5] = { "FLT", "DST", "CMP", "DLY", "REV" };
    const char* fxKeys[5] = { "filter", "dist", "comp", "delay", "reverb" };
    const char* fxColors[5] = { "#1abc9c", "#e67e22", "#5dade2", "#2ecc71", "#af7ac5" };
    for (int i = 0; i < 5; ++i) {
        QPushButton* btn = new QPushButton(fxNames[i]);
        btn->setCheckable(true);
        btn->setFixedHeight(14);
        btn->setStyleSheet(
            QString("QPushButton { background: #1c2430; color: #7f8c8d; border: 1px solid #2c3e50; border-radius: 2px; font-size: 8px; font-weight: bold; padding: 0; }"
                    "QPushButton:checked { background: %1; color: #111; border-color: %1; }")
                .arg(fxColors[i]));
        QString slot = QString::fromLatin1(fxKeys[i]);
        connect(btn, &QPushButton::clicked, this, [this, slot](bool checked) {
            if (!mUpdatingUi) {
                emit selectedRequested(mTrackId);
                emit fxToggleRequested(mTrackId, slot, checked);
            }
        });
        mFxBtns[i] = btn;
        if (i < 3)
            fxGrid->addWidget(btn, 0, i);
        else
            fxGrid->addWidget(btn, 1, i - 3, 1, (i == 4) ? 2 : 1);
    }
    root->addLayout(fxGrid);

    // Pan Knob
    QHBoxLayout* panRow = new QHBoxLayout;
    panRow->setContentsMargins(0, 0, 0, 0);
    panRow->addStretch();
    mPanKnob = new MixerRotaryKnob(tr("PAN"), -1.0f, 1.0f, 0.0f, false, QColor(0x5dade2));
    mPanKnob->setBipolar(true);
    mPanKnob->setFormatter([](float v) {
        if (std::abs(v) < 0.03f)
            return QStringLiteral("C");
        int pct = static_cast<int>(std::round(std::abs(v) * 100.0f));
        return QString("%1%2").arg(v < 0 ? "L" : "R").arg(pct);
    });
    connect(mPanKnob, &MixerRotaryKnob::valueChanged, this, [this](float val) {
        if (!mUpdatingUi)
            emit panChanged(mTrackId, val);
    });
    panRow->addWidget(mPanKnob);
    panRow->addStretch();
    root->addLayout(panRow);

    // Fader + Meter row
    QHBoxLayout* faderRow = new QHBoxLayout;
    faderRow->setContentsMargins(2, 0, 2, 0);
    faderRow->setSpacing(5);

    mFader = new QSlider(Qt::Vertical);
    mFader->setRange(-600, 120); // tenths of dB: -60.0 to +12.0
    mFader->setValue(0);
    mFader->setMinimumHeight(56);
    mFader->installEventFilter(this);
    mFader->setStyleSheet(
        "QSlider::groove:vertical { background: #0d1117; width: 6px; border-radius: 3px; border: 1px solid #2c3e50; }"
        "QSlider::handle:vertical { background: #d0d7de; border: 1px solid #57606a; height: 12px; margin: 0 -5px; border-radius: 2px; }"
        "QSlider::handle:vertical:hover { background: #ffffff; }");
    connect(mFader, &QSlider::valueChanged, this, [this](int val) {
        float db = val / 10.0f;
        mDbLabel->setText(formatDb(db) + " dB");
        if (!mUpdatingUi)
            emit volumeChanged(mTrackId, db);
    });

    mMeter = new StereoLevelMeter;
    faderRow->addStretch();
    faderRow->addWidget(mFader);
    faderRow->addWidget(mMeter);
    faderRow->addStretch();
    root->addLayout(faderRow, 1);

    // dB Readout
    mDbLabel = new QLabel(QStringLiteral("0.0 dB"));
    mDbLabel->setAlignment(Qt::AlignCenter);
    mDbLabel->setStyleSheet("QLabel { color: #aeb6bf; font-size: 9px; font-family: 'Consolas', monospace; }");
    root->addWidget(mDbLabel);

    // Mute / Solo buttons
    QHBoxLayout* msRow = new QHBoxLayout;
    msRow->setContentsMargins(0, 0, 0, 0);
    msRow->setSpacing(3);

    mMuteBtn = new QPushButton(QStringLiteral("M"));
    mMuteBtn->setCheckable(true);
    mMuteBtn->setFixedHeight(17);
    mMuteBtn->setStyleSheet(
        "QPushButton { background: #1c2430; color: #95a5a6; border: 1px solid #2c3e50; border-radius: 2px; font-size: 9px; font-weight: bold; }"
        "QPushButton:checked { background: #c0392b; color: #fff; border-color: #e74c3c; }");
    connect(mMuteBtn, &QPushButton::clicked, this, [this](bool checked) {
        if (!mUpdatingUi)
            emit muteToggled(mTrackId, checked);
    });

    mSoloBtn = new QPushButton(QStringLiteral("S"));
    mSoloBtn->setCheckable(true);
    mSoloBtn->setFixedHeight(17);
    mSoloBtn->setStyleSheet(
        "QPushButton { background: #1c2430; color: #95a5a6; border: 1px solid #2c3e50; border-radius: 2px; font-size: 9px; font-weight: bold; }"
        "QPushButton:checked { background: #d4ac0d; color: #111; border-color: #f4d03f; }");
    connect(mSoloBtn, &QPushButton::clicked, this, [this](bool checked) {
        if (!mUpdatingUi)
            emit soloToggled(mTrackId, checked);
    });

    msRow->addWidget(mMuteBtn);
    msRow->addWidget(mSoloBtn);
    root->addLayout(msRow);

    // Dedicated Fade Out & Stop button
    mFadeOutBtn = new QPushButton(tr("Fade Out"));
    mFadeOutBtn->setFixedHeight(18);
    mFadeOutBtn->setToolTip(tr("Fade out and stop this voice (1.5s)"));
    mFadeOutBtn->setStyleSheet(
        "QPushButton { background: #3b1e22; color: #f5b7b1; border: 1px solid #78281f; border-radius: 3px; font-size: 9px; font-weight: bold; }"
        "QPushButton:hover { background: #c0392b; color: #ffffff; border-color: #e74c3c; }");
    connect(mFadeOutBtn, &QPushButton::clicked, this, [this]() {
        emit stopTrackRequested(mTrackId);
    });
    root->addWidget(mFadeOutBtn);
}

void MixerChannelStrip::syncFromState(const PerfTrackState& state, bool selected) {
    mUpdatingUi = true;
    mBadgeLabel->setText(state.originBadge);
    mBadgeLabel->setStyleSheet(QString("QLabel { font-size: 8px; font-weight: bold; color: #fff; background: %1; border-radius: 2px; padding: 0 5px; }")
                                   .arg(badgeColor(state.originBadge).name()));

    QString fullTitle = state.displayName();
    QString elided = fontMetrics().elidedText(fullTitle, Qt::ElideRight, 94);
    mNameLabel->setText(elided);
    setToolTip(QString("%1 (%2, bus %3, %4 ch)")
                   .arg(fullTitle, state.kind)
                   .arg(state.busIndex)
                   .arg(state.numChannels));

    mFxBtns[0]->setChecked(state.filterEnabled);
    mFxBtns[1]->setChecked(state.distEnabled);
    mFxBtns[2]->setChecked(state.compEnabled);
    mFxBtns[3]->setChecked(state.delayEnabled);
    mFxBtns[4]->setChecked(state.revEnabled);
    bool stereoOk = (state.numChannels >= 2);
    for (int i = 0; i < 5; ++i)
        mFxBtns[i]->setEnabled(stereoOk);

    mPanKnob->setValue(state.pan, false);
    mPanKnob->setEnabled(stereoOk);
    mFader->setValue(static_cast<int>(std::round(state.volumeDb * 10.0f)));
    mDbLabel->setText(formatDb(state.volumeDb) + " dB");
    mMuteBtn->setChecked(state.muted);
    mSoloBtn->setChecked(state.soloed);

    setStyleSheet(selected
                      ? "MixerChannelStrip { background-color: #1e2a38; border: 1px solid #5dade2; border-radius: 4px; }"
                      : "MixerChannelStrip { background-color: #161b22; border: 1px solid #2b3440; border-radius: 4px; }");
    mUpdatingUi = false;
}

void MixerChannelStrip::updateMeters(float peakL, float rmsL, float peakR, float rmsR, bool clipped) {
    mMeter->setLevels(peakL, rmsL, peakR, rmsR, clipped);
}

void MixerChannelStrip::mousePressEvent(QMouseEvent* e) {
    if (e->button() == Qt::LeftButton)
        emit selectedRequested(mTrackId);
    QFrame::mousePressEvent(e);
}

bool MixerChannelStrip::eventFilter(QObject* obj, QEvent* ev) {
    if (obj == mFader && ev->type() == QEvent::MouseButtonDblClick) {
        mFader->setValue(0);
        return true;
    }
    return QFrame::eventFilter(obj, ev);
}

// ============================================================================
// MixerFxInspector
// ============================================================================

MixerFxInspector::MixerFxInspector(QWidget* parent): QWidget(parent) {
    setMinimumWidth(260);
    QVBoxLayout* root = new QVBoxLayout(this);
    root->setContentsMargins(4, 2, 4, 2);
    root->setSpacing(4);

    mHeaderLabel = new QLabel(tr("Track FX Inspector — No Track Selected"));
    mHeaderLabel->setStyleSheet("QLabel { color: #d6eaf8; font-size: 10px; font-weight: bold; }");
    root->addWidget(mHeaderLabel);

    mEmptyLabel = new QLabel(tr("Click a channel strip to inspect and tweak its Filter, Distortion, Compressor, Delay, and Reverb."));
    mEmptyLabel->setWordWrap(true);
    mEmptyLabel->setAlignment(Qt::AlignCenter);
    mEmptyLabel->setStyleSheet("QLabel { color: #7f8c8d; font-size: 10px; padding: 12px; }");
    root->addWidget(mEmptyLabel, 1);

    mCardsScroll = new QScrollArea;
    mCardsScroll->setWidgetResizable(true);
    mCardsScroll->setFrameShape(QFrame::NoFrame);
    mCardsScroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    mCardsScroll->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    mCardsScroll->setStyleSheet("QScrollArea { background: transparent; border: none; }");

    mCardsContainer = new QWidget;
    mCardsContainer->setStyleSheet("QWidget { background: transparent; }");
    // 5 compact 2-row-knob FX cards side-by-side (or wrap smoothly via scroll area without ever clipping)
    QHBoxLayout* cardsRow = new QHBoxLayout(mCardsContainer);
    cardsRow->setContentsMargins(0, 0, 0, 0);
    cardsRow->setSpacing(6);
    cardsRow->addWidget(createFilterCard());
    cardsRow->addWidget(createDistCard());
    cardsRow->addWidget(createCompCard());
    cardsRow->addWidget(createDelayCard());
    cardsRow->addWidget(createRevCard());
    cardsRow->addStretch(1);

    mCardsScroll->setWidget(mCardsContainer);
    mCardsScroll->setVisible(false);
    root->addWidget(mCardsScroll, 1);
}

static QFrame* makeFxCardFrame(const QString& title, const QColor& accent,
                               QPushButton*& outEnableBtn, std::function<void()> onReset,
                               QGridLayout*& outKnobGrid) {
    QFrame* card = new QFrame;
    card->setFixedWidth(174);
    card->setStyleSheet("QFrame { background-color: #161b22; border: 1px solid #2b3440; border-radius: 4px; }");
    QVBoxLayout* v = new QVBoxLayout(card);
    v->setContentsMargins(6, 4, 6, 5);
    v->setSpacing(4);

    QHBoxLayout* hdr = new QHBoxLayout;
    hdr->setContentsMargins(0, 0, 0, 0);
    hdr->setSpacing(4);

    outEnableBtn = new QPushButton(QStringLiteral("ON"));
    outEnableBtn->setCheckable(true);
    outEnableBtn->setFixedSize(26, 16);
    outEnableBtn->setStyleSheet(
        QString("QPushButton { background: #21262d; color: #7f8c8d; border: 1px solid #30363d; border-radius: 2px; font-size: 8px; font-weight: bold; }"
                "QPushButton:checked { background: %1; color: #111; border-color: %1; }")
            .arg(accent.name()));
    hdr->addWidget(outEnableBtn);

    QLabel* titleLbl = new QLabel(title);
    titleLbl->setStyleSheet("QLabel { color: #e6edf3; font-size: 10px; font-weight: bold; border: none; }");
    hdr->addWidget(titleLbl);
    hdr->addStretch();

    QPushButton* rstBtn = new QPushButton(QStringLiteral("Rst"));
    rstBtn->setFixedSize(24, 16);
    rstBtn->setToolTip(QString("Reset %1 parameters").arg(title));
    rstBtn->setStyleSheet(
        "QPushButton { background: #21262d; color: #8b949e; border: 1px solid #30363d; border-radius: 2px; font-size: 8px; }"
        "QPushButton:hover { color: #fff; }");
    QObject::connect(rstBtn, &QPushButton::clicked, onReset);
    hdr->addWidget(rstBtn);
    v->addLayout(hdr);

    outKnobGrid = new QGridLayout;
    outKnobGrid->setContentsMargins(0, 2, 0, 0);
    outKnobGrid->setHorizontalSpacing(4);
    outKnobGrid->setVerticalSpacing(6);
    v->addLayout(outKnobGrid, 1);
    return card;
}

QWidget* MixerFxInspector::createFilterCard() {
    QGridLayout* grid = nullptr;
    QFrame* card = makeFxCardFrame(tr("Filter"), QColor(0x1abc9c), mFilterEnableBtn, [this]() {
        if (!mTrackId.isEmpty())
            emit fxResetRequested(mTrackId, QStringLiteral("filter"));
    }, grid);

    connect(mFilterEnableBtn, &QPushButton::clicked, this, [this](bool on) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxToggleRequested(mTrackId, QStringLiteral("filter"), on);
    });

    QWidget* modeCell = new QWidget;
    QVBoxLayout* modeCol = new QVBoxLayout(modeCell);
    modeCol->setContentsMargins(0, 0, 0, 0);
    modeCol->setSpacing(2);
    mFilterModeCombo = new QComboBox;
    mFilterModeCombo->addItems({ tr("LPF"), tr("HPF"), tr("BPF"), tr("Notch") });
    mFilterModeCombo->setFixedWidth(50);
    mFilterModeCombo->setStyleSheet("QComboBox { background: #0d1117; color: #e6edf3; border: 1px solid #30363d; font-size: 9px; padding: 1px 2px; }");
    connect(mFilterModeCombo, QOverload<int>::of(&QComboBox::currentIndexChanged), this, [this](int idx) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("filter"), QStringLiteral("mode"), static_cast<float>(idx));
    });
    QLabel* mLbl = new QLabel(tr("Type"));
    mLbl->setAlignment(Qt::AlignCenter);
    mLbl->setStyleSheet("QLabel { color: #85929e; font-size: 8px; border: none; }");
    modeCol->addStretch();
    modeCol->addWidget(mFilterModeCombo);
    modeCol->addWidget(mLbl);
    modeCol->addStretch();

    mFilterFreqKnob = new MixerRotaryKnob(tr("Cutoff"), 20.0f, 18000.0f, 2400.0f, true, QColor(0x1abc9c));
    mFilterFreqKnob->setFormatter([](float v) { return v >= 1000 ? QString("%1k").arg(v / 1000.0f, 0, 'f', 1) : QString("%1").arg(static_cast<int>(v)); });
    connect(mFilterFreqKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("filter"), QStringLiteral("freq"), v);
    });

    mFilterResKnob = new MixerRotaryKnob(tr("Res"), 0.0f, 0.94f, 0.25f, false, QColor(0x1abc9c));
    mFilterResKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mFilterResKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("filter"), QStringLiteral("res"), v);
    });

    mFilterDriveKnob = new MixerRotaryKnob(tr("Drive"), 1.0f, 4.0f, 1.0f, false, QColor(0x1abc9c));
    mFilterDriveKnob->setFormatter([](float v) { return QString("%1x").arg(v, 0, 'f', 1); });
    connect(mFilterDriveKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("filter"), QStringLiteral("drive"), v);
    });

    mFilterMixKnob = new MixerRotaryKnob(tr("Mix"), 0.0f, 1.0f, 1.0f, false, QColor(0x1abc9c));
    mFilterMixKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mFilterMixKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("filter"), QStringLiteral("mix"), v);
    });

    // 2 rows of knobs/controls
    grid->addWidget(modeCell, 0, 0, Qt::AlignCenter);
    grid->addWidget(mFilterFreqKnob, 0, 1, Qt::AlignCenter);
    grid->addWidget(mFilterResKnob, 0, 2, Qt::AlignCenter);
    grid->addWidget(mFilterDriveKnob, 1, 0, Qt::AlignCenter);
    grid->addWidget(mFilterMixKnob, 1, 1, Qt::AlignCenter);
    return card;
}

QWidget* MixerFxInspector::createDistCard() {
    QGridLayout* grid = nullptr;
    QFrame* card = makeFxCardFrame(tr("Distortion"), QColor(0xe67e22), mDistEnableBtn, [this]() {
        if (!mTrackId.isEmpty())
            emit fxResetRequested(mTrackId, QStringLiteral("dist"));
    }, grid);

    connect(mDistEnableBtn, &QPushButton::clicked, this, [this](bool on) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxToggleRequested(mTrackId, QStringLiteral("dist"), on);
    });

    QWidget* modeCell = new QWidget;
    QVBoxLayout* modeCol = new QVBoxLayout(modeCell);
    modeCol->setContentsMargins(0, 0, 0, 0);
    modeCol->setSpacing(2);
    mDistModeCombo = new QComboBox;
    mDistModeCombo->addItems({ tr("Tube"), tr("Hard"), tr("Fold"), tr("Crush") });
    mDistModeCombo->setFixedWidth(50);
    mDistModeCombo->setStyleSheet("QComboBox { background: #0d1117; color: #e6edf3; border: 1px solid #30363d; font-size: 9px; padding: 1px 2px; }");
    connect(mDistModeCombo, QOverload<int>::of(&QComboBox::currentIndexChanged), this, [this](int idx) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("dist"), QStringLiteral("mode"), static_cast<float>(idx));
    });
    QLabel* mLbl = new QLabel(tr("Mode"));
    mLbl->setAlignment(Qt::AlignCenter);
    mLbl->setStyleSheet("QLabel { color: #85929e; font-size: 8px; border: none; }");
    modeCol->addStretch();
    modeCol->addWidget(mDistModeCombo);
    modeCol->addWidget(mLbl);
    modeCol->addStretch();

    mDistDriveKnob = new MixerRotaryKnob(tr("Drive"), 1.0f, 25.0f, 3.0f, true, QColor(0xe67e22));
    mDistDriveKnob->setFormatter([](float v) { return QString("%1x").arg(v, 0, 'f', 1); });
    connect(mDistDriveKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("dist"), QStringLiteral("drive"), v);
    });

    mDistToneKnob = new MixerRotaryKnob(tr("Tone"), 400.0f, 16000.0f, 6000.0f, true, QColor(0xe67e22));
    mDistToneKnob->setFormatter([](float v) { return v >= 1000 ? QString("%1k").arg(v / 1000.0f, 0, 'f', 1) : QString("%1").arg(static_cast<int>(v)); });
    connect(mDistToneKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("dist"), QStringLiteral("tone"), v);
    });

    mDistMixKnob = new MixerRotaryKnob(tr("Mix"), 0.0f, 1.0f, 0.5f, false, QColor(0xe67e22));
    mDistMixKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mDistMixKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("dist"), QStringLiteral("mix"), v);
    });

    mDistGainKnob = new MixerRotaryKnob(tr("Out"), -18.0f, 6.0f, 0.0f, false, QColor(0xe67e22));
    mDistGainKnob->setBipolar(true);
    mDistGainKnob->setFormatter([](float v) { return QString("%1dB").arg(v, 0, 'f', 0); });
    connect(mDistGainKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("dist"), QStringLiteral("outGain"), v);
    });

    // 2 rows
    grid->addWidget(modeCell, 0, 0, Qt::AlignCenter);
    grid->addWidget(mDistDriveKnob, 0, 1, Qt::AlignCenter);
    grid->addWidget(mDistToneKnob, 0, 2, Qt::AlignCenter);
    grid->addWidget(mDistMixKnob, 1, 0, Qt::AlignCenter);
    grid->addWidget(mDistGainKnob, 1, 1, Qt::AlignCenter);
    return card;
}

QWidget* MixerFxInspector::createCompCard() {
    QGridLayout* grid = nullptr;
    QFrame* card = makeFxCardFrame(tr("Compressor"), QColor(0x5dade2), mCompEnableBtn, [this]() {
        if (!mTrackId.isEmpty())
            emit fxResetRequested(mTrackId, QStringLiteral("comp"));
    }, grid);

    connect(mCompEnableBtn, &QPushButton::clicked, this, [this](bool on) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxToggleRequested(mTrackId, QStringLiteral("comp"), on);
    });

    mCompThreshKnob = new MixerRotaryKnob(tr("Thresh"), -40.0f, 0.0f, -18.0f, false, QColor(0x5dade2));
    mCompThreshKnob->setFormatter([](float v) { return QString("%1dB").arg(v, 0, 'f', 0); });
    connect(mCompThreshKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("comp"), QStringLiteral("thresh"), v);
    });

    mCompRatioKnob = new MixerRotaryKnob(tr("Ratio"), 1.0f, 20.0f, 4.0f, true, QColor(0x5dade2));
    mCompRatioKnob->setFormatter([](float v) { return QString("%1:1").arg(v, 0, 'f', 1); });
    connect(mCompRatioKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("comp"), QStringLiteral("ratio"), v);
    });

    mCompAtkKnob = new MixerRotaryKnob(tr("Atk"), 1.0f, 200.0f, 10.0f, true, QColor(0x5dade2));
    mCompAtkKnob->setFormatter([](float v) { return QString("%1ms").arg(static_cast<int>(v)); });
    connect(mCompAtkKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("comp"), QStringLiteral("attack"), v);
    });

    mCompRelKnob = new MixerRotaryKnob(tr("Rel"), 20.0f, 1000.0f, 150.0f, true, QColor(0x5dade2));
    mCompRelKnob->setFormatter([](float v) { return QString("%1ms").arg(static_cast<int>(v)); });
    connect(mCompRelKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("comp"), QStringLiteral("release"), v);
    });

    mCompMakeupKnob = new MixerRotaryKnob(tr("Gain"), 0.0f, 24.0f, 0.0f, false, QColor(0x5dade2));
    mCompMakeupKnob->setFormatter([](float v) { return QString("+%1").arg(v, 0, 'f', 1); });
    connect(mCompMakeupKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("comp"), QStringLiteral("makeup"), v);
    });

    mCompMixKnob = new MixerRotaryKnob(tr("Mix"), 0.0f, 1.0f, 1.0f, false, QColor(0x5dade2));
    mCompMixKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mCompMixKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("comp"), QStringLiteral("mix"), v);
    });

    // 2 rows of 3 knobs
    grid->addWidget(mCompThreshKnob, 0, 0, Qt::AlignCenter);
    grid->addWidget(mCompRatioKnob, 0, 1, Qt::AlignCenter);
    grid->addWidget(mCompAtkKnob, 0, 2, Qt::AlignCenter);
    grid->addWidget(mCompRelKnob, 1, 0, Qt::AlignCenter);
    grid->addWidget(mCompMakeupKnob, 1, 1, Qt::AlignCenter);
    grid->addWidget(mCompMixKnob, 1, 2, Qt::AlignCenter);
    return card;
}

QWidget* MixerFxInspector::createDelayCard() {
    QGridLayout* grid = nullptr;
    QFrame* card = makeFxCardFrame(tr("Delay"), QColor(0x2ecc71), mDelayEnableBtn, [this]() {
        if (!mTrackId.isEmpty())
            emit fxResetRequested(mTrackId, QStringLiteral("delay"));
    }, grid);

    connect(mDelayEnableBtn, &QPushButton::clicked, this, [this](bool on) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxToggleRequested(mTrackId, QStringLiteral("delay"), on);
    });

    mDelayTimeKnob = new MixerRotaryKnob(tr("Time"), 20.0f, 1500.0f, 350.0f, true, QColor(0x2ecc71));
    mDelayTimeKnob->setFormatter([](float v) { return v >= 1000 ? QString("%1s").arg(v / 1000.0f, 0, 'f', 2) : QString("%1ms").arg(static_cast<int>(v)); });
    connect(mDelayTimeKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("delay"), QStringLiteral("time"), v);
    });

    mDelayFbKnob = new MixerRotaryKnob(tr("Fdbk"), 0.0f, 0.92f, 0.40f, false, QColor(0x2ecc71));
    mDelayFbKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mDelayFbKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("delay"), QStringLiteral("feedback"), v);
    });

    mDelayDampKnob = new MixerRotaryKnob(tr("Damp"), 500.0f, 16000.0f, 4500.0f, true, QColor(0x2ecc71));
    mDelayDampKnob->setFormatter([](float v) { return v >= 1000 ? QString("%1k").arg(v / 1000.0f, 0, 'f', 1) : QString("%1").arg(static_cast<int>(v)); });
    connect(mDelayDampKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("delay"), QStringLiteral("damp"), v);
    });

    mDelaySpreadKnob = new MixerRotaryKnob(tr("Ping"), 0.0f, 1.0f, 0.35f, false, QColor(0x2ecc71));
    mDelaySpreadKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mDelaySpreadKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("delay"), QStringLiteral("spread"), v);
    });

    mDelayMixKnob = new MixerRotaryKnob(tr("Mix"), 0.0f, 1.0f, 0.30f, false, QColor(0x2ecc71));
    mDelayMixKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mDelayMixKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("delay"), QStringLiteral("mix"), v);
    });

    // 2 rows (3 + 2)
    grid->addWidget(mDelayTimeKnob, 0, 0, Qt::AlignCenter);
    grid->addWidget(mDelayFbKnob, 0, 1, Qt::AlignCenter);
    grid->addWidget(mDelayDampKnob, 0, 2, Qt::AlignCenter);
    grid->addWidget(mDelaySpreadKnob, 1, 0, Qt::AlignCenter);
    grid->addWidget(mDelayMixKnob, 1, 1, Qt::AlignCenter);
    return card;
}

QWidget* MixerFxInspector::createRevCard() {
    QGridLayout* grid = nullptr;
    QFrame* card = makeFxCardFrame(tr("Reverb"), QColor(0xaf7ac5), mRevEnableBtn, [this]() {
        if (!mTrackId.isEmpty())
            emit fxResetRequested(mTrackId, QStringLiteral("reverb"));
    }, grid);

    connect(mRevEnableBtn, &QPushButton::clicked, this, [this](bool on) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxToggleRequested(mTrackId, QStringLiteral("reverb"), on);
    });

    mRevRoomKnob = new MixerRotaryKnob(tr("Size"), 0.0f, 1.0f, 0.65f, false, QColor(0xaf7ac5));
    mRevRoomKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mRevRoomKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("reverb"), QStringLiteral("room"), v);
    });

    mRevDampKnob = new MixerRotaryKnob(tr("Damp"), 0.0f, 1.0f, 0.40f, false, QColor(0xaf7ac5));
    mRevDampKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mRevDampKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("reverb"), QStringLiteral("damp"), v);
    });

    mRevPreKnob = new MixerRotaryKnob(tr("Pre"), 0.0f, 150.0f, 15.0f, false, QColor(0xaf7ac5));
    mRevPreKnob->setFormatter([](float v) { return QString("%1ms").arg(static_cast<int>(v)); });
    connect(mRevPreKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("reverb"), QStringLiteral("preDelay"), v);
    });

    mRevLowCutKnob = new MixerRotaryKnob(tr("LoCut"), 20.0f, 800.0f, 120.0f, true, QColor(0xaf7ac5));
    mRevLowCutKnob->setFormatter([](float v) { return QString("%1Hz").arg(static_cast<int>(v)); });
    connect(mRevLowCutKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("reverb"), QStringLiteral("lowCut"), v);
    });

    mRevMixKnob = new MixerRotaryKnob(tr("Mix"), 0.0f, 1.0f, 0.30f, false, QColor(0xaf7ac5));
    mRevMixKnob->setFormatter([](float v) { return QString("%1%").arg(static_cast<int>(v * 100)); });
    connect(mRevMixKnob, &MixerRotaryKnob::valueChanged, this, [this](float v) {
        if (!mUpdatingUi && !mTrackId.isEmpty())
            emit fxParamChanged(mTrackId, QStringLiteral("reverb"), QStringLiteral("mix"), v);
    });

    // 2 rows (3 + 2)
    grid->addWidget(mRevRoomKnob, 0, 0, Qt::AlignCenter);
    grid->addWidget(mRevDampKnob, 0, 1, Qt::AlignCenter);
    grid->addWidget(mRevPreKnob, 0, 2, Qt::AlignCenter);
    grid->addWidget(mRevLowCutKnob, 1, 0, Qt::AlignCenter);
    grid->addWidget(mRevMixKnob, 1, 1, Qt::AlignCenter);
    return card;
}

void MixerFxInspector::setTrack(const PerfTrackState* state) {
    mUpdatingUi = true;
    if (!state) {
        mTrackId.clear();
        mHeaderLabel->setText(tr("Track FX Inspector — No Track Selected"));
        mCardsScroll->setVisible(false);
        mEmptyLabel->setVisible(true);
        mUpdatingUi = false;
        return;
    }

    mTrackId = state->id;
    mHeaderLabel->setText(tr("Track FX — %1 (%2)").arg(state->displayName(), state->originBadge));
    mEmptyLabel->setVisible(false);
    mCardsScroll->setVisible(true);
    mCardsContainer->setEnabled(state->numChannels >= 2);

    mFilterEnableBtn->setChecked(state->filterEnabled);
    mFilterModeCombo->setCurrentIndex(qBound(0, state->filterMode, 3));
    mFilterFreqKnob->setValue(state->filterFreq, false);
    mFilterResKnob->setValue(state->filterRes, false);
    mFilterDriveKnob->setValue(state->filterDrive, false);
    mFilterMixKnob->setValue(state->filterMix, false);

    mDistEnableBtn->setChecked(state->distEnabled);
    mDistModeCombo->setCurrentIndex(qBound(0, state->distMode, 3));
    mDistDriveKnob->setValue(state->distDrive, false);
    mDistToneKnob->setValue(state->distTone, false);
    mDistMixKnob->setValue(state->distMix, false);
    mDistGainKnob->setValue(state->distGainDb, false);

    mCompEnableBtn->setChecked(state->compEnabled);
    mCompThreshKnob->setValue(state->compThresh, false);
    mCompRatioKnob->setValue(state->compRatio, false);
    mCompAtkKnob->setValue(state->compAttackMs, false);
    mCompRelKnob->setValue(state->compReleaseMs, false);
    mCompMakeupKnob->setValue(state->compMakeupDb, false);
    mCompMixKnob->setValue(state->compMix, false);

    mDelayEnableBtn->setChecked(state->delayEnabled);
    mDelayTimeKnob->setValue(state->delayTimeMs, false);
    mDelayFbKnob->setValue(state->delayFeedback, false);
    mDelayDampKnob->setValue(state->delayDampHz, false);
    mDelaySpreadKnob->setValue(state->delaySpread, false);
    mDelayMixKnob->setValue(state->delayMix, false);

    mRevEnableBtn->setChecked(state->revEnabled);
    mRevRoomKnob->setValue(state->revRoom, false);
    mRevDampKnob->setValue(state->revDamp, false);
    mRevPreKnob->setValue(state->revPreDelayMs, false);
    mRevLowCutKnob->setValue(state->revLowCutHz, false);
    mRevMixKnob->setValue(state->revMix, false);

    mUpdatingUi = false;
}

// ============================================================================
// PerfMixerWidget
// ============================================================================

PerfMixerWidget::PerfMixerWidget(ScProcess* scLang, ScServer* scServer, QWidget* parent):
    QWidget(parent),
    mLang(scLang),
    mServer(scServer) {
    setStyleSheet("PerfMixerWidget { background-color: #0d1117; }");

    mOscOutSocket = new QUdpSocket(this);
    mMeterSocket = new QUdpSocket(this);
    if (mMeterSocket->bind(QHostAddress::LocalHost, 0)) {
        mMeterPort = mMeterSocket->localPort();
    }
    connect(mMeterSocket, &QUdpSocket::readyRead, this, &PerfMixerWidget::onMeterDatagrams);

    QVBoxLayout* root = new QVBoxLayout(this);
    root->setContentsMargins(4, 3, 4, 4);
    root->setSpacing(4);

    // Header Bar
    QHBoxLayout* hdr = new QHBoxLayout;
    hdr->setContentsMargins(2, 0, 2, 0);
    hdr->setSpacing(6);

    QLabel* title = new QLabel(tr("Performance Mixer"));
    title->setStyleSheet("QLabel { color: #e6edf3; font-size: 11px; font-weight: bold; }");
    hdr->addWidget(title);

    mCountLabel = new QLabel(tr("0 Active"));
    mCountLabel->setStyleSheet("QLabel { background: #1f2833; color: #7fb3d5; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
    hdr->addWidget(mCountLabel);

    mEnableBtn = new QPushButton(tr("Active"));
    mEnableBtn->setCheckable(true);
    mEnableBtn->setChecked(true);
    mEnableBtn->setFixedHeight(20);
    mEnableBtn->setStyleSheet(
        "QPushButton { background: #21262d; color: #8b949e; border: 1px solid #30363d; border-radius: 3px; font-size: 9px; padding: 0 8px; }"
        "QPushButton:checked { background: #145a32; color: #2ecc71; border-color: #2ecc71; }");
    connect(mEnableBtn, &QPushButton::clicked, this, [this](bool on) {
        mMixerEnabled = on;
        mEnableBtn->setText(on ? tr("Active") : tr("Bypassed"));
        sendLangRequest(QStringLiteral("perfMixerSetEnabled"), on ? QStringLiteral("1") : QStringLiteral("0"));
    });
    hdr->addWidget(mEnableBtn);

    mClearSoloBtn = new QPushButton(tr("Clear Solo"));
    mClearSoloBtn->setFixedHeight(20);
    mClearSoloBtn->setStyleSheet("QPushButton { background: #21262d; color: #d0d7de; border: 1px solid #30363d; border-radius: 3px; font-size: 9px; padding: 0 7px; }");
    connect(mClearSoloBtn, &QPushButton::clicked, this, [this]() {
        for (auto it = mTracks.begin(); it != mTracks.end(); ++it)
            it->soloed = false;
        applySoloDims();
        for (auto it = mStripWidgets.begin(); it != mStripWidgets.end(); ++it) {
            if (mTracks.contains(it.key()))
                it.value()->syncFromState(mTracks[it.key()], it.key() == mSelectedTrackId);
        }
    });
    hdr->addWidget(mClearSoloBtn);

    mResetAllBtn = new QPushButton(tr("Reset Strips"));
    mResetAllBtn->setFixedHeight(20);
    mResetAllBtn->setStyleSheet("QPushButton { background: #21262d; color: #d0d7de; border: 1px solid #30363d; border-radius: 3px; font-size: 9px; padding: 0 7px; }");
    connect(mResetAllBtn, &QPushButton::clicked, this, [this]() {
        for (auto it = mTracks.begin(); it != mTracks.end(); ++it) {
            it->volumeDb = 0.0f;
            it->pan = 0.0f;
            it->muted = false;
            it->soloed = false;
        }
        applySoloDims();
        for (auto it = mStripWidgets.begin(); it != mStripWidgets.end(); ++it) {
            if (mTracks.contains(it.key())) {
                sendCoreOsc(mTracks[it.key()]);
                it.value()->syncFromState(mTracks[it.key()], it.key() == mSelectedTrackId);
            }
        }
    });
    hdr->addWidget(mResetAllBtn);

    mSyncBtn = new QPushButton(tr("Sync"));
    mSyncBtn->setFixedHeight(20);
    mSyncBtn->setStyleSheet("QPushButton { background: #21262d; color: #7fb3d5; border: 1px solid #30363d; border-radius: 3px; font-size: 9px; padding: 0 7px; }");
    connect(mSyncBtn, &QPushButton::clicked, this, [this]() {
        sendLangRequest(QStringLiteral("perfMixerSyncNow"));
    });
    hdr->addWidget(mSyncBtn);

    hdr->addStretch();

    mMasterVolLabel = new QLabel(tr("Master: 0.0 dB"));
    mMasterVolLabel->setStyleSheet("QLabel { color: #aeb6bf; font-size: 9px; font-family: 'Consolas', monospace; }");
    hdr->addWidget(mMasterVolLabel);

    mFxToggleBtn = new QPushButton(tr("FX Rack"));
    mFxToggleBtn->setCheckable(true);
    mFxToggleBtn->setChecked(true);
    mFxToggleBtn->setFixedHeight(20);
    mFxToggleBtn->setStyleSheet(
        "QPushButton { background: #21262d; color: #8b949e; border: 1px solid #30363d; border-radius: 3px; font-size: 9px; padding: 0 8px; }"
        "QPushButton:checked { background: #1f618d; color: #ebf5fb; border-color: #5dade2; }");
    hdr->addWidget(mFxToggleBtn);
    root->addLayout(hdr);

    // Resizable Splitter: Channel Strips (left) + FX Inspector (right)
    mMainSplitter = new QSplitter(Qt::Horizontal);
    mMainSplitter->setHandleWidth(5);
    mMainSplitter->setStyleSheet("QSplitter::handle { background: #21262d; }");

    mStripScroll = new QScrollArea;
    mStripScroll->setWidgetResizable(true);
    mStripScroll->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    mStripScroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    mStripScroll->setStyleSheet("QScrollArea { background: #0d1117; border: 1px solid #21262d; border-radius: 4px; }");

    mStripContainer = new QWidget;
    mStripContainer->setStyleSheet("QWidget { background: #0d1117; }");
    mStripLayout = new QHBoxLayout(mStripContainer);
    mStripLayout->setContentsMargins(6, 4, 6, 4);
    mStripLayout->setSpacing(6);

    mNoVoicesLabel = new QLabel(tr("No active voices yet.\nEvaluate SuperCollider code or run X-Append (Append / Generate / Compose / Design) to populate tracks automatically."));
    mNoVoicesLabel->setAlignment(Qt::AlignCenter);
    mNoVoicesLabel->setWordWrap(true);
    mNoVoicesLabel->setStyleSheet("QLabel { color: #6e7681; font-size: 10px; padding: 16px; }");
    mStripLayout->addWidget(mNoVoicesLabel, 1);

    mStripScroll->setWidget(mStripContainer);
    mMainSplitter->addWidget(mStripScroll);

    mFxInspector = new MixerFxInspector;
    connect(mFxToggleBtn, &QPushButton::toggled, mFxInspector, &QWidget::setVisible);
    mMainSplitter->addWidget(mFxInspector);

    mMainSplitter->setStretchFactor(0, 2);
    mMainSplitter->setStretchFactor(1, 3);
    root->addWidget(mMainSplitter, 1);

    // Wire FX Inspector signals
    connect(mFxInspector, &MixerFxInspector::fxToggleRequested, this, [this](const QString& id, const QString& slot, bool on) {
        if (!mTracks.contains(id))
            return;
        PerfTrackState& tr = mTracks[id];
        if (slot == "filter") tr.filterEnabled = on;
        else if (slot == "dist") tr.distEnabled = on;
        else if (slot == "comp") tr.compEnabled = on;
        else if (slot == "delay") tr.delayEnabled = on;
        else if (slot == "reverb") tr.revEnabled = on;
        if (mStripWidgets.contains(id))
            mStripWidgets[id]->syncFromState(tr, id == mSelectedTrackId);
        sendLangRequest(QStringLiteral("perfMixerSetFxEnabled"), QString("%1|%2|%3").arg(id, slot, on ? "1" : "0"));
    });

    connect(mFxInspector, &MixerFxInspector::fxParamChanged, this, [this](const QString& id, const QString& slot, const QString& param, float val) {
        if (!mTracks.contains(id))
            return;
        PerfTrackState& tr = mTracks[id];
        if (slot == "filter") {
            if (param == "mode") tr.filterMode = static_cast<int>(val);
            else if (param == "freq") tr.filterFreq = val;
            else if (param == "res") tr.filterRes = val;
            else if (param == "drive") tr.filterDrive = val;
            else if (param == "mix") tr.filterMix = val;
            if (tr.filterNodeId > 0)
                sendNodeSetFloat(tr.filterNodeId, param.toLatin1().constData(), val);
        } else if (slot == "dist") {
            if (param == "mode") tr.distMode = static_cast<int>(val);
            else if (param == "drive") tr.distDrive = val;
            else if (param == "tone") tr.distTone = val;
            else if (param == "mix") tr.distMix = val;
            else if (param == "outGain") tr.distGainDb = val;
            if (tr.distNodeId > 0) {
                float sendVal = (param == "outGain") ? dbToAmp(val) : val;
                sendNodeSetFloat(tr.distNodeId, param.toLatin1().constData(), sendVal);
            }
        } else if (slot == "comp") {
            if (param == "thresh") tr.compThresh = val;
            else if (param == "ratio") tr.compRatio = val;
            else if (param == "attack") tr.compAttackMs = val;
            else if (param == "release") tr.compReleaseMs = val;
            else if (param == "makeup") tr.compMakeupDb = val;
            else if (param == "mix") tr.compMix = val;
            if (tr.compNodeId > 0) {
                float sendVal = val;
                if (param == "attack" || param == "release") sendVal = val / 1000.0f;
                else if (param == "makeup") sendVal = dbToAmp(val);
                sendNodeSetFloat(tr.compNodeId, param.toLatin1().constData(), sendVal);
            }
        } else if (slot == "delay") {
            if (param == "time") tr.delayTimeMs = val;
            else if (param == "feedback") tr.delayFeedback = val;
            else if (param == "damp") tr.delayDampHz = val;
            else if (param == "spread") tr.delaySpread = val;
            else if (param == "mix") tr.delayMix = val;
            if (tr.delayNodeId > 0) {
                float sendVal = (param == "time") ? (val / 1000.0f) : val;
                sendNodeSetFloat(tr.delayNodeId, param.toLatin1().constData(), sendVal);
            }
        } else if (slot == "reverb") {
            if (param == "room") tr.revRoom = val;
            else if (param == "damp") tr.revDamp = val;
            else if (param == "preDelay") tr.revPreDelayMs = val;
            else if (param == "lowCut") tr.revLowCutHz = val;
            else if (param == "mix") tr.revMix = val;
            if (tr.revNodeId > 0) {
                float sendVal = (param == "preDelay") ? (val / 1000.0f) : val;
                sendNodeSetFloat(tr.revNodeId, param.toLatin1().constData(), sendVal);
            }
        }
    });

    connect(mFxInspector, &MixerFxInspector::fxResetRequested, this, [this](const QString& id, const QString& slot) {
        if (!mTracks.contains(id))
            return;
        PerfTrackState& tr = mTracks[id];
        if (slot == "filter") {
            tr.filterMode = 0; tr.filterFreq = 2400.0f; tr.filterRes = 0.25f; tr.filterDrive = 1.0f; tr.filterMix = 1.0f;
        } else if (slot == "dist") {
            tr.distMode = 0; tr.distDrive = 3.0f; tr.distTone = 6000.0f; tr.distMix = 0.5f; tr.distGainDb = 0.0f;
        } else if (slot == "comp") {
            tr.compThresh = -18.0f; tr.compRatio = 4.0f; tr.compAttackMs = 10.0f; tr.compReleaseMs = 150.0f; tr.compMakeupDb = 0.0f; tr.compMix = 1.0f;
        } else if (slot == "delay") {
            tr.delayTimeMs = 350.0f; tr.delayFeedback = 0.40f; tr.delayDampHz = 4500.0f; tr.delaySpread = 0.35f; tr.delayMix = 0.30f;
        } else if (slot == "reverb") {
            tr.revRoom = 0.65f; tr.revDamp = 0.40f; tr.revPreDelayMs = 15.0f; tr.revLowCutHz = 120.0f; tr.revMix = 0.30f;
        }
        sendAllFxOsc(tr, slot);
        if (id == mSelectedTrackId)
            mFxInspector->setTrack(&tr);
    });

    // Wire ScProcess & ScServer
    connect(mLang, &ScProcess::response, this, &PerfMixerWidget::onScLangResponse);
    connect(mServer, &ScServer::runningStateChanged, this, &PerfMixerWidget::onServerRunningChanged);
    connect(mServer, &ScServer::volumeChanged, this, [this](float db) {
        mMasterVolLabel->setText(QString("Master: %1 dB").arg(db, 0, 'f', 1));
    });
    connect(mServer, &ScServer::mutedChanged, this, [this](bool muted) {
        mMasterVolLabel->setText(muted ? tr("Master: MUTED") : QString("Master: %1 dB").arg(mServer->volume(), 0, 'f', 1));
    });

    mMeterDecayTimer = new QTimer(this);
    connect(mMeterDecayTimer, &QTimer::timeout, this, &PerfMixerWidget::onMeterDecayTick);
    mMeterDecayTimer->start(33);
}

void PerfMixerWidget::onXAppendEvaluated(const QString& mode, int promptIndex, const QString& code) {
    QString badge = QStringLiteral("APP");
    if (mode == QStringLiteral("generate")) badge = QStringLiteral("GEN");
    else if (mode == QStringLiteral("compose")) badge = QStringLiteral("CMP");
    else if (mode == QStringLiteral("design")) badge = QStringLiteral("DSN");

    const QString prefix = (promptIndex > 0)
        ? (modeInitial(mode) + QString::number(promptIndex))
        : QString();

    // Only tag newly defined instruments/patterns/synthdefs so later tweak prompts don't overwrite original creation index
    auto recordDefs = [&](const QString& rxStr, bool overwriteExisting) {
        QRegularExpression rx(rxStr);
        auto it = rx.globalMatch(code);
        while (it.hasNext()) {
            auto m = it.next();
            const QString sym = m.captured(1);
            if (overwriteExisting || !mSymbolOriginHints.contains(sym))
                mSymbolOriginHints[sym] = badge;
            if (!prefix.isEmpty() && (overwriteExisting || !mSymbolPromptPrefix.contains(sym)))
                mSymbolPromptPrefix[sym] = prefix;
        }
    };
    recordDefs(QStringLiteral("Ndef\\(\\s*\\\\(\\w+)\\s*,\\s*\\{"), true);
    recordDefs(QStringLiteral("SynthDef\\(\\s*\\\\(\\w+)\\s*,"), true);
    recordDefs(QStringLiteral("Pbindef\\(\\s*\\\\(\\w+)\\s*,"), false);

    QTimer::singleShot(120, this, [this]() {
        sendLangRequest(QStringLiteral("perfMixerSyncNow"));
    });
}

QString PerfMixerWidget::inferOriginBadge(const QString& label, const QString& kind) const {
    if (kind == QStringLiteral("submix"))
        return QStringLiteral("BUS");
    if (kind == QStringLiteral("design"))
        return QStringLiteral("DSN");
    if (mSymbolOriginHints.contains(label))
        return mSymbolOriginHints.value(label);
    if (kind == QStringLiteral("pbindef"))
        return QStringLiteral("CMP");
    return QStringLiteral("APP");
}

void PerfMixerWidget::onScLangResponse(const QString& selector, const QString& data) {
    if (selector == QStringLiteral("perfMixerSync")) {
        handleSyncPayload(data);
    } else if (selector == QStringLiteral("classLibraryRecompiled")) {
        QTimer::singleShot(300, this, [this]() {
            sendLangRequest(QStringLiteral("perfMixerInit"), QString::number(mMeterPort));
        });
    }
}

void PerfMixerWidget::onServerRunningChanged(bool running, const QString&, int, bool) {
    if (running) {
        sendLangRequest(QStringLiteral("perfMixerSetMeterPort"), QString::number(mMeterPort));
        QTimer::singleShot(150, this, [this]() {
            sendLangRequest(QStringLiteral("perfMixerSyncNow"));
        });
    } else {
        mTrackOrder.clear();
        mMeterIdToTrackId.clear();
        rebuildStripsLayout();
    }
}

void PerfMixerWidget::handleSyncPayload(const QString& yamlData) {
    try {
        const YAML::Node root = YAML::Load(yamlData.toStdString());
        if (!root || !root.IsSequence())
            return;

        QStringList newOrder;
        mMeterIdToTrackId.clear();

        for (std::size_t i = 0; i < root.size(); ++i) {
            const YAML::Node& row = root[i];
            if (!row.IsSequence() || row.size() < 11)
                continue;

            QString id = QString::fromStdString(row[0].as<std::string>());
            QString label = QString::fromStdString(row[1].as<std::string>());
            QString kind = QString::fromStdString(row[2].as<std::string>());
            int meterId = row[3].as<int>();
            int numCh = row[4].as<int>();
            int busIdx = row[5].as<int>();
            int coreId = row[6].as<int>();
            int distId = row[7].as<int>();
            int compId = row[8].as<int>();
            int delayId = row[9].as<int>();
            int revId = row[10].as<int>();
            int filterId = (row.size() >= 12) ? row[11].as<int>() : -1;

            PerfTrackState& tr = mTracks[id];
            bool coreChanged = (tr.coreNodeId != coreId && coreId > 0);
            bool distSpawned = (tr.distNodeId != distId && distId > 0);
            bool filterSpawned = (tr.filterNodeId != filterId && filterId > 0);
            bool compSpawned = (tr.compNodeId != compId && compId > 0);
            bool delaySpawned = (tr.delayNodeId != delayId && delayId > 0);
            bool revSpawned = (tr.revNodeId != revId && revId > 0);

            tr.id = id;
            tr.label = label;
            if (mSymbolPromptPrefix.contains(label))
                tr.promptPrefix = mSymbolPromptPrefix.value(label);
            tr.kind = kind;
            tr.originBadge = inferOriginBadge(label, kind);
            tr.meterId = meterId;
            tr.numChannels = numCh;
            tr.busIndex = busIdx;
            tr.coreNodeId = coreId;
            tr.distNodeId = distId;
            tr.filterNodeId = filterId;
            tr.compNodeId = compId;
            tr.delayNodeId = delayId;
            tr.revNodeId = revId;
            tr.distEnabled = (distId > 0);
            tr.filterEnabled = (filterId > 0);
            tr.compEnabled = (compId > 0);
            tr.delayEnabled = (delayId > 0);
            tr.revEnabled = (revId > 0);

            newOrder.append(id);
            mMeterIdToTrackId[meterId] = id;

            if (coreChanged)
                sendCoreOsc(tr);
            if (filterSpawned)
                sendAllFxOsc(tr, QStringLiteral("filter"));
            if (distSpawned)
                sendAllFxOsc(tr, QStringLiteral("dist"));
            if (compSpawned)
                sendAllFxOsc(tr, QStringLiteral("comp"));
            if (delaySpawned)
                sendAllFxOsc(tr, QStringLiteral("delay"));
            if (revSpawned)
                sendAllFxOsc(tr, QStringLiteral("reverb"));
        }

        mTrackOrder = newOrder;
        if (!mTrackOrder.contains(mSelectedTrackId)) {
            mSelectedTrackId = mTrackOrder.isEmpty() ? QString() : mTrackOrder.first();
        }
        applySoloDims();
        rebuildStripsLayout();
    } catch (...) {
    }
}

void PerfMixerWidget::rebuildStripsLayout() {
    while (QLayoutItem* item = mStripLayout->takeAt(0)) {
        if (item->widget() && item->widget() != mNoVoicesLabel && !mTrackOrder.contains(item->widget()->objectName())) {
            item->widget()->deleteLater();
        }
        delete item;
    }

    for (auto it = mStripWidgets.begin(); it != mStripWidgets.end();) {
        if (!mTrackOrder.contains(it.key())) {
            it.value()->deleteLater();
            it = mStripWidgets.erase(it);
        } else {
            ++it;
        }
    }

    if (mTrackOrder.isEmpty()) {
        mNoVoicesLabel->setVisible(true);
        mStripLayout->addWidget(mNoVoicesLabel, 1);
        mCountLabel->setText(tr("0 Active"));
        mFxInspector->setTrack(nullptr);
        return;
    }

    mNoVoicesLabel->setVisible(false);
    for (const QString& id : mTrackOrder) {
        MixerChannelStrip* strip = mStripWidgets.value(id, nullptr);
        if (!strip) {
            strip = new MixerChannelStrip(id, mStripContainer);
            strip->setObjectName(id);
            connect(strip, &MixerChannelStrip::selectedRequested, this, &PerfMixerWidget::selectTrack);
            connect(strip, &MixerChannelStrip::volumeChanged, this, [this](const QString& tid, float db) {
                if (!mTracks.contains(tid)) return;
                mTracks[tid].volumeDb = db;
                sendCoreOsc(mTracks[tid]);
            });
            connect(strip, &MixerChannelStrip::panChanged, this, [this](const QString& tid, float pan) {
                if (!mTracks.contains(tid)) return;
                mTracks[tid].pan = pan;
                sendCoreOsc(mTracks[tid]);
            });
            connect(strip, &MixerChannelStrip::muteToggled, this, [this](const QString& tid, bool muted) {
                if (!mTracks.contains(tid)) return;
                mTracks[tid].muted = muted;
                sendCoreOsc(mTracks[tid]);
            });
            connect(strip, &MixerChannelStrip::soloToggled, this, [this](const QString& tid, bool soloed) {
                if (!mTracks.contains(tid)) return;
                mTracks[tid].soloed = soloed;
                applySoloDims();
            });
            connect(strip, &MixerChannelStrip::fxToggleRequested, this, [this](const QString& tid, const QString& slot, bool on) {
                if (!mTracks.contains(tid)) return;
                PerfTrackState& tr = mTracks[tid];
                if (slot == "filter") tr.filterEnabled = on;
                else if (slot == "dist") tr.distEnabled = on;
                else if (slot == "comp") tr.compEnabled = on;
                else if (slot == "delay") tr.delayEnabled = on;
                else if (slot == "reverb") tr.revEnabled = on;
                sendLangRequest(QStringLiteral("perfMixerSetFxEnabled"), QString("%1|%2|%3").arg(tid, slot, on ? "1" : "0"));
                if (tid == mSelectedTrackId)
                    mFxInspector->setTrack(&tr);
            });
            connect(strip, &MixerChannelStrip::stopTrackRequested, this, [this](const QString& tid) {
                sendLangRequest(QStringLiteral("perfMixerStopTrack"), tid);
            });
            mStripWidgets[id] = strip;
        }
        strip->syncFromState(mTracks[id], id == mSelectedTrackId);
        mStripLayout->addWidget(strip);
    }
    mStripLayout->addStretch(1);

    mCountLabel->setText(tr("%1 Active").arg(mTrackOrder.size()));
    mFxInspector->setTrack(mSelectedTrackId.isEmpty() ? nullptr : &mTracks[mSelectedTrackId]);
}

void PerfMixerWidget::selectTrack(const QString& trackId) {
    if (mSelectedTrackId == trackId)
        return;
    mSelectedTrackId = trackId;
    for (auto it = mStripWidgets.begin(); it != mStripWidgets.end(); ++it) {
        if (mTracks.contains(it.key()))
            it.value()->syncFromState(mTracks[it.key()], it.key() == mSelectedTrackId);
    }
    mFxInspector->setTrack(mTracks.contains(mSelectedTrackId) ? &mTracks[mSelectedTrackId] : nullptr);
}

void PerfMixerWidget::applySoloDims() {
    bool anySolo = false;
    for (const QString& id : mTrackOrder) {
        if (mTracks.contains(id) && mTracks[id].soloed) {
            anySolo = true;
            break;
        }
    }
    for (const QString& id : mTrackOrder) {
        if (!mTracks.contains(id))
            continue;
        const PerfTrackState& tr = mTracks[id];
        float soloDim = (!anySolo || tr.soloed) ? 1.0f : 0.0f;
        if (tr.coreNodeId > 0)
            sendNodeSetFloat(tr.coreNodeId, "soloDim", soloDim);
    }
}

void PerfMixerWidget::sendCoreOsc(const PerfTrackState& tr) {
    if (tr.coreNodeId <= 0)
        return;
    bool anySolo = false;
    for (const QString& id : mTrackOrder) {
        if (mTracks.contains(id) && mTracks[id].soloed) {
            anySolo = true;
            break;
        }
    }
    float soloDim = (!anySolo || tr.soloed) ? 1.0f : 0.0f;
    sendNodeSetMulti(tr.coreNodeId, {
        { "amp", dbToAmp(tr.volumeDb) },
        { "pan", tr.pan },
        { "mute", tr.muted ? 1.0f : 0.0f },
        { "soloDim", soloDim }
    });
}

void PerfMixerWidget::sendAllFxOsc(const PerfTrackState& tr, const QString& fxSlot) {
    if (fxSlot == QStringLiteral("filter") && tr.filterNodeId > 0) {
        sendNodeSetMulti(tr.filterNodeId, {
            { "mode", static_cast<float>(tr.filterMode) },
            { "freq", tr.filterFreq },
            { "res", tr.filterRes },
            { "drive", tr.filterDrive },
            { "mix", tr.filterMix }
        });
    } else if (fxSlot == QStringLiteral("dist") && tr.distNodeId > 0) {
        sendNodeSetMulti(tr.distNodeId, {
            { "mode", static_cast<float>(tr.distMode) },
            { "drive", tr.distDrive },
            { "tone", tr.distTone },
            { "mix", tr.distMix },
            { "outGain", dbToAmp(tr.distGainDb) }
        });
    } else if (fxSlot == QStringLiteral("comp") && tr.compNodeId > 0) {
        sendNodeSetMulti(tr.compNodeId, {
            { "thresh", tr.compThresh },
            { "ratio", tr.compRatio },
            { "attack", tr.compAttackMs / 1000.0f },
            { "release", tr.compReleaseMs / 1000.0f },
            { "makeup", dbToAmp(tr.compMakeupDb) },
            { "mix", tr.compMix }
        });
    } else if (fxSlot == QStringLiteral("delay") && tr.delayNodeId > 0) {
        sendNodeSetMulti(tr.delayNodeId, {
            { "time", tr.delayTimeMs / 1000.0f },
            { "feedback", tr.delayFeedback },
            { "damp", tr.delayDampHz },
            { "spread", tr.delaySpread },
            { "mix", tr.delayMix }
        });
    } else if (fxSlot == QStringLiteral("reverb") && tr.revNodeId > 0) {
        sendNodeSetMulti(tr.revNodeId, {
            { "room", tr.revRoom },
            { "damp", tr.revDamp },
            { "preDelay", tr.revPreDelayMs / 1000.0f },
            { "lowCut", tr.revLowCutHz },
            { "mix", tr.revMix }
        });
    }
}

void PerfMixerWidget::sendNodeSetFloat(int nodeId, const char* paramName, float value) {
    if (!mServer || !mServer->isRunning() || nodeId <= 0)
        return;
    char buffer[256];
    osc::OutboundPacketStream stream(buffer, sizeof(buffer));
    stream << osc::BeginMessage("/n_set") << static_cast<osc::int32>(nodeId) << paramName << value << osc::MessageTerminator();
    mOscOutSocket->writeDatagram(stream.Data(), stream.Size(), mServer->serverAddress(), static_cast<quint16>(mServer->serverPort()));
}

void PerfMixerWidget::sendNodeSetMulti(int nodeId, const QVector<QPair<const char*, float>>& pairs) {
    if (!mServer || !mServer->isRunning() || nodeId <= 0)
        return;
    char buffer[512];
    osc::OutboundPacketStream stream(buffer, sizeof(buffer));
    stream << osc::BeginMessage("/n_set") << static_cast<osc::int32>(nodeId);
    for (const auto& kv : pairs)
        stream << kv.first << kv.second;
    stream << osc::MessageTerminator();
    mOscOutSocket->writeDatagram(stream.Data(), stream.Size(), mServer->serverAddress(), static_cast<quint16>(mServer->serverPort()));
}

void PerfMixerWidget::sendLangRequest(const QString& cmd, const QString& data) {
    if (!mLang || mLang->state() != QProcess::Running)
        return;
    mLang->sendRequest(QStringLiteral("pm"), cmd, data);
}

void PerfMixerWidget::onMeterDatagrams() {
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    while (mMeterSocket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(static_cast<int>(mMeterSocket->pendingDatagramSize()));
        mMeterSocket->readDatagram(datagram.data(), datagram.size());
        try {
            osc::ReceivedPacket pkt(datagram.constData(), static_cast<std::size_t>(datagram.size()));
            if (!pkt.IsMessage())
                continue;
            osc::ReceivedMessage msg(pkt);
            if (std::strcmp(msg.AddressPattern(), "/pm/m") != 0)
                continue;
            osc::int32 meterId = 0;
            float peakL = 0, rmsL = 0, peakR = 0, rmsR = 0;
            msg.ArgumentStream() >> meterId >> peakL >> rmsL >> peakR >> rmsR;

            QString tid = mMeterIdToTrackId.value(meterId);
            if (tid.isEmpty() || !mTracks.contains(tid))
                continue;
            PerfTrackState& tr = mTracks[tid];
            tr.peakL = qMax(peakL, tr.peakL * 0.7f);
            tr.rmsL = rmsL;
            tr.peakR = qMax(peakR, tr.peakR * 0.7f);
            tr.rmsR = rmsR;
            if (peakL >= 0.99f || peakR >= 0.99f)
                tr.clipUntilMs = now + 1200;

            if (MixerChannelStrip* strip = mStripWidgets.value(tid, nullptr))
                strip->updateMeters(tr.peakL, tr.rmsL, tr.peakR, tr.rmsR, now < tr.clipUntilMs);
        } catch (...) {
        }
    }
}

void PerfMixerWidget::onMeterDecayTick() {
    const qint64 now = QDateTime::currentMSecsSinceEpoch();
    for (const QString& id : mTrackOrder) {
        if (!mTracks.contains(id))
            continue;
        PerfTrackState& tr = mTracks[id];
        if (tr.peakL > 0.001f || tr.rmsL > 0.001f || tr.peakR > 0.001f || tr.rmsR > 0.001f) {
            tr.peakL *= 0.85f;
            tr.rmsL *= 0.82f;
            tr.peakR *= 0.85f;
            tr.rmsR *= 0.82f;
            if (MixerChannelStrip* strip = mStripWidgets.value(id, nullptr))
                strip->updateMeters(tr.peakL, tr.rmsL, tr.peakR, tr.rmsR, now < tr.clipUntilMs);
        }
    }
}

// ============================================================================
// PerfMixerDocklet
// ============================================================================

PerfMixerDocklet::PerfMixerDocklet(ScProcess* scLang, ScServer* scServer, QWidget* parent):
    Docklet(tr("Performance Mixer"), parent) {
    setAllowedAreas(Qt::BottomDockWidgetArea | Qt::TopDockWidgetArea);
    mMixerWidget = new PerfMixerWidget(scLang, scServer);
    mMixerWidget->setMinimumHeight(215);
    setWidget(mMixerWidget);
}

} // namespace ScIDE
