/*
    SuperCollider Qt IDE — Adaptive Performance Mixer
    Copyright (c) 2026 SuperCollider AI-Assist Contributors

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
*/

#pragma once

#include "util/docklet.hpp"

#include <QComboBox>
#include <QFrame>
#include <QHash>
#include <QHBoxLayout>
#include <QLabel>
#include <QMap>
#include <QPushButton>
#include <QScrollArea>
#include <QSlider>
#include <QSplitter>
#include <QTimer>
#include <QUdpSocket>
#include <QWidget>
#include <functional>

namespace ScIDE {

class ScProcess;
class ScServer;

struct PerfTrackState {
    QString id;
    QString label;
    QString promptPrefix; // e.g. "A1", "A5", "C6", "D4", "G3"
    QString kind;         // "ndef", "submix", "pbindef", "design"
    QString originBadge;  // "APP", "GEN", "CMP", "DSN", "BUS"
    int meterId = 0;
    int numChannels = 2;
    int busIndex = 0;

    int coreNodeId = -1;
    int distNodeId = -1;
    int filterNodeId = -1;
    int compNodeId = -1;
    int delayNodeId = -1;
    int revNodeId = -1;

    // Core channel strip
    float volumeDb = 0.0f; // -60.0 (-inf) .. +12.0
    float pan = 0.0f;      // -1.0 .. +1.0
    bool muted = false;
    bool soloed = false;

    // Distortion
    bool distEnabled = false;
    int distMode = 0; // 0=Tube, 1=Hard, 2=Fold, 3=Crush
    float distDrive = 3.0f;
    float distTone = 6000.0f;
    float distMix = 0.5f;
    float distGainDb = 0.0f;

    // Filter
    bool filterEnabled = false;
    int filterMode = 0; // 0=LPF, 1=HPF, 2=BPF, 3=Notch
    float filterFreq = 2400.0f;
    float filterRes = 0.25f;
    float filterDrive = 1.0f;
    float filterMix = 1.0f;

    // Compressor
    bool compEnabled = false;
    float compThresh = -18.0f;
    float compRatio = 4.0f;
    float compAttackMs = 10.0f;
    float compReleaseMs = 150.0f;
    float compMakeupDb = 0.0f;
    float compMix = 1.0f;

    // Delay
    bool delayEnabled = false;
    float delayTimeMs = 350.0f;
    float delayFeedback = 0.40f;
    float delayDampHz = 4500.0f;
    float delaySpread = 0.35f;
    float delayMix = 0.30f;

    // Reverb
    bool revEnabled = false;
    float revRoom = 0.65f;
    float revDamp = 0.40f;
    float revPreDelayMs = 15.0f;
    float revLowCutHz = 120.0f;
    float revMix = 0.30f;

    // Metering
    float peakL = 0.0f;
    float rmsL = 0.0f;
    float peakR = 0.0f;
    float rmsR = 0.0f;
    qint64 clipUntilMs = 0;

    QString displayName() const {
        if (!promptPrefix.isEmpty())
            return promptPrefix + QStringLiteral(" ") + label;
        return label;
    }
};

class MixerRotaryKnob : public QWidget {
    Q_OBJECT
public:
    explicit MixerRotaryKnob(const QString& title, float minVal, float maxVal, float defaultVal,
                             bool logarithmic = false, const QColor& accent = QColor(0x4ea8de),
                             QWidget* parent = nullptr);

    void setValue(float v, bool emitSignal = false);
    float value() const { return mValue; }
    void setFormatter(std::function<QString(float)> fmt) { mFormatter = std::move(fmt); update(); }
    void setBipolar(bool b) { mBipolar = b; update(); }

signals:
    void valueChanged(float newValue);

protected:
    void paintEvent(QPaintEvent*) override;
    void mousePressEvent(QMouseEvent*) override;
    void mouseMoveEvent(QMouseEvent*) override;
    void mouseDoubleClickEvent(QMouseEvent*) override;
    void wheelEvent(QWheelEvent*) override;

private:
    float valueToNorm(float v) const;
    float normToValue(float n) const;

    QString mTitle;
    float mMin;
    float mMax;
    float mDefault;
    float mValue;
    bool mLog;
    bool mBipolar = false;
    QColor mAccent;
    std::function<QString(float)> mFormatter;

    bool mDragging = false;
    int mDragStartY = 0;
    float mDragStartNorm = 0.0f;
};

class StereoLevelMeter : public QWidget {
    Q_OBJECT
public:
    explicit StereoLevelMeter(QWidget* parent = nullptr);
    void setLevels(float peakL, float rmsL, float peakR, float rmsR, bool clipped);

protected:
    void paintEvent(QPaintEvent*) override;

private:
    float mPeakL = 0.0f;
    float mRmsL = 0.0f;
    float mPeakR = 0.0f;
    float mRmsR = 0.0f;
    bool mClipped = false;
};

class MixerChannelStrip : public QFrame {
    Q_OBJECT
public:
    explicit MixerChannelStrip(const QString& trackId, QWidget* parent = nullptr);

    void syncFromState(const PerfTrackState& state, bool selected);
    void updateMeters(float peakL, float rmsL, float peakR, float rmsR, bool clipped);

signals:
    void selectedRequested(const QString& trackId);
    void volumeChanged(const QString& trackId, float db);
    void panChanged(const QString& trackId, float pan);
    void muteToggled(const QString& trackId, bool muted);
    void soloToggled(const QString& trackId, bool soloed);
    void fxToggleRequested(const QString& trackId, const QString& fxSlot, bool enable);
    void stopTrackRequested(const QString& trackId);

protected:
    void mousePressEvent(QMouseEvent* e) override;
    bool eventFilter(QObject* obj, QEvent* ev) override;

private:
    QString mTrackId;
    QLabel* mBadgeLabel;
    QLabel* mNameLabel;
    QPushButton* mFxBtns[5]; // FLT, DST, CMP, DLY, REV
    MixerRotaryKnob* mPanKnob;
    QSlider* mFader;
    StereoLevelMeter* mMeter;
    QLabel* mDbLabel;
    QPushButton* mMuteBtn;
    QPushButton* mSoloBtn;
    QPushButton* mFadeOutBtn;
    bool mUpdatingUi = false;
};

class MixerFxInspector : public QWidget {
    Q_OBJECT
public:
    explicit MixerFxInspector(QWidget* parent = nullptr);
    void setTrack(const PerfTrackState* state);

signals:
    void fxToggleRequested(const QString& trackId, const QString& fxSlot, bool enable);
    void fxParamChanged(const QString& trackId, const QString& fxSlot, const QString& param, float value);
    void fxResetRequested(const QString& trackId, const QString& fxSlot);

private:
    QWidget* createFilterCard();
    QWidget* createDistCard();
    QWidget* createCompCard();
    QWidget* createDelayCard();
    QWidget* createRevCard();

    QString mTrackId;
    bool mUpdatingUi = false;
    QLabel* mHeaderLabel;
    QScrollArea* mCardsScroll;
    QWidget* mCardsContainer;
    QLabel* mEmptyLabel;

    // Filter controls
    QPushButton* mFilterEnableBtn;
    QComboBox* mFilterModeCombo;
    MixerRotaryKnob* mFilterFreqKnob;
    MixerRotaryKnob* mFilterResKnob;
    MixerRotaryKnob* mFilterDriveKnob;
    MixerRotaryKnob* mFilterMixKnob;

    // Dist controls
    QPushButton* mDistEnableBtn;
    QComboBox* mDistModeCombo;
    MixerRotaryKnob* mDistDriveKnob;
    MixerRotaryKnob* mDistToneKnob;
    MixerRotaryKnob* mDistMixKnob;
    MixerRotaryKnob* mDistGainKnob;

    // Comp controls
    QPushButton* mCompEnableBtn;
    MixerRotaryKnob* mCompThreshKnob;
    MixerRotaryKnob* mCompRatioKnob;
    MixerRotaryKnob* mCompAtkKnob;
    MixerRotaryKnob* mCompRelKnob;
    MixerRotaryKnob* mCompMakeupKnob;
    MixerRotaryKnob* mCompMixKnob;

    // Delay controls
    QPushButton* mDelayEnableBtn;
    MixerRotaryKnob* mDelayTimeKnob;
    MixerRotaryKnob* mDelayFbKnob;
    MixerRotaryKnob* mDelayDampKnob;
    MixerRotaryKnob* mDelaySpreadKnob;
    MixerRotaryKnob* mDelayMixKnob;

    // Reverb controls
    QPushButton* mRevEnableBtn;
    MixerRotaryKnob* mRevRoomKnob;
    MixerRotaryKnob* mRevDampKnob;
    MixerRotaryKnob* mRevPreKnob;
    MixerRotaryKnob* mRevLowCutKnob;
    MixerRotaryKnob* mRevMixKnob;
};

class PerfMixerWidget : public QWidget {
    Q_OBJECT
public:
    explicit PerfMixerWidget(ScProcess* scLang, ScServer* scServer, QWidget* parent = nullptr);

public slots:
    void onXAppendEvaluated(const QString& mode, int promptIndex, const QString& code);

private slots:
    void onScLangResponse(const QString& selector, const QString& data);
    void onServerRunningChanged(bool running, const QString& hostName, int port, bool unresponsive);
    void onMeterDatagrams();
    void onMeterDecayTick();

private:
    void handleSyncPayload(const QString& yamlData);
    void rebuildStripsLayout();
    void selectTrack(const QString& trackId);
    void applySoloDims();
    void sendCoreOsc(const PerfTrackState& tr);
    void sendAllFxOsc(const PerfTrackState& tr, const QString& fxSlot);
    void sendNodeSetFloat(int nodeId, const char* paramName, float value);
    void sendNodeSetMulti(int nodeId, const QVector<QPair<const char*, float>>& pairs);
    void sendLangRequest(const QString& cmd, const QString& data = QString());
    QString inferOriginBadge(const QString& label, const QString& kind) const;

    ScProcess* mLang;
    ScServer* mServer;
    QUdpSocket* mOscOutSocket;
    QUdpSocket* mMeterSocket;
    int mMeterPort = 0;

    bool mMixerEnabled = true;
    QString mSelectedTrackId;

    QLabel* mCountLabel;
    QPushButton* mEnableBtn;
    QPushButton* mClearSoloBtn;
    QPushButton* mResetAllBtn;
    QPushButton* mFxToggleBtn;
    QPushButton* mSyncBtn;
    QLabel* mMasterVolLabel;

    QSplitter* mMainSplitter;
    QScrollArea* mStripScroll;
    QWidget* mStripContainer;
    QHBoxLayout* mStripLayout;
    QLabel* mNoVoicesLabel;
    MixerFxInspector* mFxInspector;

    QMap<QString, PerfTrackState> mTracks;
    QStringList mTrackOrder;
    QHash<QString, MixerChannelStrip*> mStripWidgets;
    QHash<int, QString> mMeterIdToTrackId;
    QHash<QString, QString> mSymbolOriginHints;  // symbol name -> "APP"/"GEN"/"CMP"/"DSN"
    QHash<QString, QString> mSymbolPromptPrefix; // symbol name -> "A1", "A5", "C6", "D4", "G3"

    QTimer* mMeterDecayTimer;
};

class PerfMixerDocklet : public Docklet {
    Q_OBJECT
public:
    explicit PerfMixerDocklet(ScProcess* scLang, ScServer* scServer, QWidget* parent = nullptr);
    PerfMixerWidget* mixerWidget() const { return mMixerWidget; }

private:
    PerfMixerWidget* mMixerWidget;
};

} // namespace ScIDE
