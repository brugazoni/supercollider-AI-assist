/*
    SuperCollider Qt IDE — Prompt Navigation Bar
    Horizontal scrollable bar at the bottom of the code window for jumping to
    prompt-generated code blocks (G1, D1, A1, C1, ...).
*/

#include "prompt_nav_bar.hpp"
#include "code_editor/editor.hpp"
#include "../core/doc_manager.hpp"

#include <QApplication>
#include <QClipboard>
#include <QEvent>
#include <QFileInfo>
#include <QHBoxLayout>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMenu>
#include <QPushButton>
#include <QRegularExpression>
#include <QScrollArea>
#include <QScrollBar>
#include <QTextBlock>
#include <QTimer>
#include <QWheelEvent>

namespace ScIDE {

namespace {

constexpr int kRowContentHeight = 26;
constexpr int kMaxWordLength = 18;
constexpr int kAnchorLength = 120;

QString normalizeMode(const QString& mode) {
    QString m = mode.trimmed().toLower();
    if (m.isEmpty())
        return QStringLiteral("generate");
    return m;
}

QString accentColorForMode(const QString& mode) {
    const QString m = normalizeMode(mode);
    if (m == QLatin1String("generate"))
        return QStringLiteral("#3498db");
    if (m == QLatin1String("design"))
        return QStringLiteral("#2ecc71");
    if (m == QLatin1String("append"))
        return QStringLiteral("#e67e22");
    if (m == QLatin1String("compose"))
        return QStringLiteral("#9b59b6");
    if (m == QLatin1String("custom"))
        return QStringLiteral("#1abc9c");
    return QStringLiteral("#95a5a6");
}

QString modeDisplayName(const QString& mode) {
    const QString m = normalizeMode(mode);
    if (m == QLatin1String("generate"))
        return QStringLiteral("Generate");
    if (m == QLatin1String("design"))
        return QStringLiteral("Design");
    if (m == QLatin1String("append"))
        return QStringLiteral("Append");
    if (m == QLatin1String("compose"))
        return QStringLiteral("Compose");
    if (m == QLatin1String("custom"))
        return QStringLiteral("Custom");
    return m;
}

int findClosestMatch(const QString& haystack, const QString& needle, int targetPos) {
    if (needle.isEmpty())
        return -1;
    int bestIdx = -1;
    int bestDist = INT_MAX;
    int from = 0;
    while (true) {
        int idx = haystack.indexOf(needle, from);
        if (idx < 0)
            break;
        int dist = qAbs(idx - targetPos);
        if (dist < bestDist) {
            bestDist = dist;
            bestIdx = idx;
        }
        from = idx + 1;
    }
    return bestIdx;
}

int reanchorPosition(const QString& docText, int savedPos, const QString& anchorText) {
    const int maxPos = docText.length();
    const int clampedSaved = qBound(0, savedPos, maxPos);

    if (!anchorText.isEmpty()) {
        if (clampedSaved + anchorText.length() <= maxPos
            && docText.mid(clampedSaved, anchorText.length()) == anchorText) {
            return clampedSaved;
        }

        int idx = findClosestMatch(docText, anchorText, clampedSaved);
        if (idx >= 0)
            return idx;

        if (anchorText.length() > 40) {
            idx = findClosestMatch(docText, anchorText.left(40), clampedSaved);
            if (idx >= 0)
                return idx;
        }

        const int nl = anchorText.indexOf(QLatin1Char('\n'));
        const QString firstLine = (nl >= 0 ? anchorText.left(nl) : anchorText).trimmed();
        if (firstLine.length() >= 8) {
            idx = findClosestMatch(docText, firstLine, clampedSaved);
            if (idx >= 0)
                return idx;
        }
    }

    return clampedSaved;
}

} // namespace

PromptNavBar::PromptNavBar(QWidget* parent): QWidget(parent) {
    setObjectName(QStringLiteral("PromptNavBar"));
    setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    QVBoxLayout* outer = new QVBoxLayout(this);
    outer->setContentsMargins(0, 1, 0, 0);
    outer->setSpacing(0);

    mScrollArea = new QScrollArea(this);
    mScrollArea->setWidgetResizable(true);
    mScrollArea->setFrameShape(QFrame::NoFrame);
    mScrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    mScrollArea->setHorizontalScrollBarPolicy(Qt::ScrollBarAsNeeded);
    mScrollArea->setFixedHeight(kRowContentHeight);
    setFixedHeight(kRowContentHeight + 1);

    mContainer = new QWidget(mScrollArea);
    mTabLayout = new QHBoxLayout(mContainer);
    mTabLayout->setContentsMargins(6, 3, 6, 3);
    mTabLayout->setSpacing(4);
    mTabLayout->addStretch(1);

    mScrollArea->setWidget(mContainer);
    outer->addWidget(mScrollArea);

    mScrollArea->viewport()->installEventFilter(this);
    mContainer->installEventFilter(this);
    mScrollArea->horizontalScrollBar()->installEventFilter(this);

    updateContainerStyle();
    setVisible(false);
}

QString PromptNavBar::prefixForMode(const QString& mode) {
    const QString m = normalizeMode(mode);
    if (m == QLatin1String("generate"))
        return QStringLiteral("G");
    if (m == QLatin1String("design"))
        return QStringLiteral("D");
    if (m == QLatin1String("append"))
        return QStringLiteral("A");
    if (m == QLatin1String("compose"))
        return QStringLiteral("C");
    if (m == QLatin1String("custom"))
        return QStringLiteral("Cu");
    return m.left(1).toUpper();
}

QString PromptNavBar::extractFirstWord(const QString& prompt) {
    const QString trimmed = prompt.trimmed();
    if (trimmed.isEmpty())
        return QStringLiteral("block");

    static const QRegularExpression wordRx(QStringLiteral("[\\p{L}\\p{N}][\\p{L}\\p{N}_'-]*"));
    QRegularExpressionMatch match = wordRx.match(trimmed);
    QString word = match.hasMatch() ? match.captured(0) : trimmed.section(QRegularExpression(QStringLiteral("\\s+")), 0, 0);
    if (word.isEmpty())
        return QStringLiteral("block");
    if (word.length() > kMaxWordLength)
        word = word.left(kMaxWordLength);
    return word;
}

QString PromptNavBar::formatHeaderComment(const QString& mode, int interactionIndex,
                                          const QString& prompt, const QString& model) {
    const QString modeUpper = normalizeMode(mode).toUpper();
    QString cleaned = prompt.trimmed();
    cleaned.replace(QRegularExpression(QStringLiteral("\\s+")), QStringLiteral(" "));
    const QStringList words = cleaned.split(QLatin1Char(' '), Qt::SkipEmptyParts);

    constexpr int kMaxPreviewWords = 5;
    QString snippet;
    if (words.isEmpty()) {
        snippet = QStringLiteral("(...)");
    } else if (words.size() > kMaxPreviewWords) {
        snippet = words.mid(0, kMaxPreviewWords).join(QLatin1Char(' ')) + QStringLiteral(" (...)");
    } else {
        snippet = words.join(QLatin1Char(' ')) + QStringLiteral(" (...)");
    }

    const QString trimmedModel = model.trimmed();
    if (!trimmedModel.isEmpty()) {
        return QStringLiteral("/// %1 %2 [%3] %4")
            .arg(modeUpper)
            .arg(qMax(1, interactionIndex))
            .arg(trimmedModel, snippet);
    }

    return QStringLiteral("/// %1 %2 %3")
        .arg(modeUpper)
        .arg(qMax(1, interactionIndex))
        .arg(snippet);
}

int PromptNavBar::nextInteractionIndex(Document* doc) const {
    if (!doc || !mDocEntries.contains(doc))
        return 1;

    int maxIdx = 0;
    const QVector<PromptNavEntry>& entries = mDocEntries.value(doc);
    for (const PromptNavEntry& existing : entries) {
        if (existing.modeIndex > maxIdx)
            maxIdx = existing.modeIndex;
    }
    return maxIdx + 1;
}

int PromptNavBar::firstCodeOffset(const QString& code) {
    if (code.isEmpty())
        return 0;

    int lineStart = 0;
    const int len = code.length();
    for (int i = 0; i < len; ++i) {
        const QChar ch = code.at(i);
        if (ch == QLatin1Char('\n') || ch == QLatin1Char('\r')) {
            lineStart = i + 1;
        } else if (!ch.isSpace()) {
            return lineStart;
        }
    }
    return 0;
}

int PromptNavBar::addEntry(Document* doc, const QString& mode, const QString& prompt,
                           int insertPos, const QString& codeText, const QString& model) {
    if (!doc)
        return 0;

    ensureDocumentWatched(doc);
    mLoadedDocs.insert(doc);

    QTextDocument* tdoc = doc->textDocument();
    const QString docText = tdoc->toPlainText();
    const int maxValidPos = qMax(0, tdoc->characterCount() - 1);

    const QString normMode = normalizeMode(mode);
    const QString trimmedModel = model.trimmed();
    const int nextIdx = nextInteractionIndex(doc);
    QVector<PromptNavEntry>& entries = mDocEntries[doc];

    int targetPos = qBound(0, insertPos + firstCodeOffset(codeText), maxValidPos);
    const QString expectedHeader = formatHeaderComment(normMode, nextIdx, prompt, trimmedModel);
    const int matchedHeaderPos = findClosestMatch(docText, expectedHeader, targetPos);
    if (matchedHeaderPos >= 0) {
        targetPos = qBound(0, matchedHeaderPos, maxValidPos);
    }

    PromptNavEntry entry;
    entry.id = mNextEntryId++;
    entry.mode = normMode;
    entry.prefix = prefixForMode(normMode);
    entry.modeIndex = nextIdx;
    entry.word = extractFirstWord(prompt);
    entry.prompt = prompt.trimmed();
    entry.model = trimmedModel;
    entry.savedPos = targetPos;
    entry.anchorText = docText.mid(targetPos, kAnchorLength);
    entry.cursor = QTextCursor(tdoc);
    entry.cursor.setPosition(targetPos);
    entry.cursor.setKeepPositionOnInsert(true);

    entries.append(entry);
    mLastDocCharCount[doc] = tdoc->characterCount();

    if (doc == mActiveDoc) {
        mActiveEntryId = entry.id;
        rebuildButtons();
        if (QPushButton* btn = mButtonsById.value(entry.id, nullptr)) {
            QTimer::singleShot(0, this, [this, btn]() {
                if (mScrollArea && btn)
                    mScrollArea->ensureWidgetVisible(btn, 16, 0);
            });
        }
    }

    return entry.id;
}

void PromptNavBar::removeEntry(Document* doc, int entryId) {
    if (!doc || entryId <= 0 || !mDocEntries.contains(doc))
        return;

    QVector<PromptNavEntry>& entries = mDocEntries[doc];
    for (int i = 0; i < entries.size(); ++i) {
        if (entries.at(i).id == entryId) {
            entries.removeAt(i);
            break;
        }
    }

    if (mActiveEntryId == entryId)
        mActiveEntryId = -1;

    if (doc == mActiveDoc)
        rebuildButtons();
}

void PromptNavBar::handleRangeReplaced(Document* doc, int startPos, int oldLen, const QString& newText) {
    if (!doc || !mDocEntries.contains(doc))
        return;

    QTextDocument* tdoc = doc->textDocument();
    const int maxValidPos = qMax(0, tdoc->characterCount() - 1);
    const int rangeEnd = startPos + qMax(0, oldLen);

    QVector<PromptNavEntry>& entries = mDocEntries[doc];
    for (PromptNavEntry& entry : entries) {
        if (entry.savedPos >= startPos && entry.savedPos <= rangeEnd) {
            const int snapPos = qBound(0, startPos + firstCodeOffset(newText), maxValidPos);
            entry.cursor = QTextCursor(tdoc);
            entry.cursor.setPosition(snapPos);
            entry.savedPos = snapPos;
            entry.anchorText = tdoc->toPlainText().mid(snapPos, kAnchorLength);
        } else {
            entry.savedPos = entryPosition(entry, doc);
        }
    }

    if (doc == mActiveDoc)
        rebuildButtons();
}

void PromptNavBar::setCurrentEditor(GenericCodeEditor* editor) {
    if (mCurrentEditor == editor) {
        Document* doc = editor ? editor->document() : nullptr;
        if (doc != mActiveDoc)
            setActiveDocument(doc);
        else
            onCursorPositionChanged();
        return;
    }

    if (mCurrentEditor)
        disconnect(mCurrentEditor, &QPlainTextEdit::cursorPositionChanged,
                   this, &PromptNavBar::onCursorPositionChanged);

    mCurrentEditor = editor;

    if (mCurrentEditor)
        connect(mCurrentEditor, &QPlainTextEdit::cursorPositionChanged,
                this, &PromptNavBar::onCursorPositionChanged);

    setActiveDocument(editor ? editor->document() : nullptr);
    onCursorPositionChanged();
}

void PromptNavBar::setActiveDocument(Document* doc) {
    if (doc) {
        ensureDocumentWatched(doc);
        lazyLoadFromSidecarIfNeeded(doc);
    }

    if (mActiveDoc == doc) {
        updateBarHeight();
        return;
    }

    mActiveDoc = doc;
    mActiveEntryId = -1;
    rebuildButtons();
    onCursorPositionChanged();
}

void PromptNavBar::onDocumentClosed(Document* doc) {
    if (!doc)
        return;

    mDocEntries.remove(doc);
    mLoadedDocs.remove(doc);
    mWatchedDocs.remove(doc);
    mLastDocCharCount.remove(doc);

    if (mActiveDoc == doc) {
        mActiveDoc = nullptr;
        mActiveEntryId = -1;
        rebuildButtons();
    }
}

QJsonArray PromptNavBar::serializeForDocument(Document* doc) {
    QJsonArray arr;
    if (!doc || !mDocEntries.contains(doc))
        return arr;

    QVector<PromptNavEntry>& entries = mDocEntries[doc];
    const QString docText = doc->textDocument()->toPlainText();

    for (PromptNavEntry& entry : entries) {
        const int pos = entryPosition(entry, doc);
        entry.savedPos = pos;
        if (!docText.isEmpty() && pos < docText.length())
            entry.anchorText = docText.mid(pos, kAnchorLength);

        QJsonObject obj;
        obj[QStringLiteral("mode")] = entry.mode;
        obj[QStringLiteral("prefix")] = entry.prefix;
        obj[QStringLiteral("mode_index")] = entry.modeIndex;
        obj[QStringLiteral("word")] = entry.word;
        obj[QStringLiteral("prompt")] = entry.prompt;
        obj[QStringLiteral("model")] = entry.model;
        obj[QStringLiteral("pos")] = pos;
        obj[QStringLiteral("anchor")] = entry.anchorText;
        arr.append(obj);
    }

    return arr;
}

void PromptNavBar::restoreFromJsonArray(Document* doc, const QJsonArray& arr, bool forceReplace) {
    if (!doc)
        return;

    ensureDocumentWatched(doc);

    if (!forceReplace && mDocEntries.contains(doc) && !mDocEntries.value(doc).isEmpty())
        return;

    mLoadedDocs.insert(doc);
    mDocEntries[doc].clear();

    QTextDocument* tdoc = doc->textDocument();
    const QString docText = tdoc->toPlainText();
    const int maxValidPos = qMax(0, tdoc->characterCount() - 1);

    for (const QJsonValue& val : arr) {
        if (!val.isObject())
            continue;
        const QJsonObject obj = val.toObject();
        const QString mode = normalizeMode(obj.value(QStringLiteral("mode")).toString());
        const QString prompt = obj.value(QStringLiteral("prompt")).toString();
        const QString anchor = obj.value(QStringLiteral("anchor")).toString();
        const int savedPos = obj.value(QStringLiteral("pos")).toInt(0);

        const int resolvedPos = qBound(0, reanchorPosition(docText, savedPos, anchor), maxValidPos);

        PromptNavEntry entry;
        entry.id = mNextEntryId++;
        entry.mode = mode;
        entry.prefix = obj.value(QStringLiteral("prefix")).toString();
        if (entry.prefix.isEmpty())
            entry.prefix = prefixForMode(mode);
        entry.modeIndex = obj.value(QStringLiteral("mode_index")).toInt(1);
        entry.word = obj.value(QStringLiteral("word")).toString();
        if (entry.word.isEmpty())
            entry.word = extractFirstWord(prompt);
        entry.prompt = prompt;
        entry.model = obj.value(QStringLiteral("model")).toString().trimmed();
        entry.anchorText = anchor.isEmpty() ? docText.mid(resolvedPos, kAnchorLength) : anchor;
        entry.savedPos = resolvedPos;
        entry.cursor = QTextCursor(tdoc);
        entry.cursor.setPosition(resolvedPos);

        mDocEntries[doc].append(entry);
    }

    mLastDocCharCount[doc] = tdoc->characterCount();

    if (doc == mActiveDoc) {
        mActiveEntryId = -1;
        rebuildButtons();
        onCursorPositionChanged();
    }
}

bool PromptNavBar::eventFilter(QObject* watched, QEvent* event) {
    if (watched == mScrollArea->horizontalScrollBar()) {
        if (event->type() == QEvent::Show || event->type() == QEvent::Hide)
            QTimer::singleShot(0, this, &PromptNavBar::updateBarHeight);
    } else if (watched == mScrollArea->viewport() || watched == mContainer) {
        if (event->type() == QEvent::Wheel) {
            QWheelEvent* we = static_cast<QWheelEvent*>(event);
            QScrollBar* hbar = mScrollArea->horizontalScrollBar();
            if (hbar && hbar->maximum() > 0) {
                int delta = we->angleDelta().x() != 0 ? we->angleDelta().x() : we->angleDelta().y();
                if (delta != 0) {
                    hbar->setValue(hbar->value() - delta / 2);
                    return true;
                }
            }
        }
    }
    return QWidget::eventFilter(watched, event);
}

void PromptNavBar::changeEvent(QEvent* event) {
    QWidget::changeEvent(event);
    if (mUpdatingStyle)
        return;
    if (event->type() == QEvent::PaletteChange) {
        mUpdatingStyle = true;
        updateContainerStyle();
        updateActiveButtonHighlight();
        mUpdatingStyle = false;
    }
}

void PromptNavBar::onCursorPositionChanged() {
    if (!mCurrentEditor || !mActiveDoc || mCurrentEditor->document() != mActiveDoc)
        return;

    const QVector<PromptNavEntry>& entries = mDocEntries.value(mActiveDoc);
    if (entries.isEmpty())
        return;

    const int cursorPos = mCurrentEditor->textCursor().position();
    int bestId = -1;
    int bestPos = -1;

    for (const PromptNavEntry& entry : entries) {
        const int pos = entryPosition(entry, mActiveDoc);
        if (pos <= cursorPos && pos >= bestPos) {
            bestPos = pos;
            bestId = entry.id;
        }
    }

    if (bestId != mActiveEntryId) {
        mActiveEntryId = bestId;
        updateActiveButtonHighlight();
    }
}

void PromptNavBar::onDocumentContentsChange(int position, int charsRemoved, int charsAdded) {
    QTextDocument* tdoc = qobject_cast<QTextDocument*>(sender());
    if (!tdoc)
        return;

    Document* targetDoc = nullptr;
    for (Document* doc : std::as_const(mWatchedDocs)) {
        if (doc && doc->textDocument() == tdoc) {
            targetDoc = doc;
            break;
        }
    }
    if (!targetDoc)
        return;

    const int prevCount = mLastDocCharCount.value(targetDoc, 0);
    mLastDocCharCount[targetDoc] = tdoc->characterCount();

    if (!mDocEntries.contains(targetDoc) || mDocEntries.value(targetDoc).isEmpty())
        return;

    // Detect full-document replacement (e.g., DocumentManager::reload calling setPlainText).
    if (position == 0 && charsRemoved > 10 && charsAdded > 0 && charsRemoved >= prevCount - 2) {
        QPointer<Document> safeDoc(targetDoc);
        QTimer::singleShot(0, this, [this, safeDoc]() {
            if (safeDoc)
                reanchorEntries(safeDoc);
        });
        return;
    }

    QVector<PromptNavEntry>& entries = mDocEntries[targetDoc];
    for (PromptNavEntry& entry : entries) {
        if (!entry.cursor.isNull())
            entry.savedPos = entry.cursor.position();
    }
}

void PromptNavBar::rebuildButtons() {
    mButtonsById.clear();

    while (mTabLayout->count() > 0) {
        QLayoutItem* item = mTabLayout->takeAt(0);
        if (QWidget* w = item->widget())
            w->deleteLater();
        delete item;
    }

    if (!mActiveDoc || !mDocEntries.contains(mActiveDoc) || mDocEntries.value(mActiveDoc).isEmpty()) {
        mTabLayout->addStretch(1);
        setVisible(false);
        return;
    }

    const QVector<PromptNavEntry>& entries = mDocEntries.value(mActiveDoc);
    for (const PromptNavEntry& entry : entries) {
        const QString label = QStringLiteral("%1%2 %3")
                                  .arg(entry.prefix)
                                  .arg(entry.modeIndex)
                                  .arg(entry.word);

        QPushButton* btn = new QPushButton(label, mContainer);
        btn->setFlat(true);
        btn->setCursor(Qt::PointingHandCursor);
        btn->setFocusPolicy(Qt::NoFocus);
        btn->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
        btn->setFixedHeight(20);
        btn->setProperty("entryId", entry.id);
        btn->setProperty("entryMode", entry.mode);
        btn->setContextMenuPolicy(Qt::CustomContextMenu);

        const int pos = entryPosition(entry, mActiveDoc);
        const int lineNum = mActiveDoc->textDocument()->findBlock(pos).blockNumber() + 1;
        QString promptPreview = entry.prompt;
        if (promptPreview.length() > 300)
            promptPreview = promptPreview.left(300) + QStringLiteral("...");
        btn->setToolTip(QStringLiteral("[%1 #%2] Line %3\n%4")
                            .arg(modeDisplayName(entry.mode))
                            .arg(entry.modeIndex)
                            .arg(lineNum)
                            .arg(promptPreview));

        const int entryId = entry.id;
        connect(btn, &QPushButton::clicked, this, [this, entryId]() {
            jumpToEntry(entryId);
        });
        connect(btn, &QWidget::customContextMenuRequested, this, [this, btn, entryId](const QPoint& pt) {
            showTabContextMenu(entryId, btn->mapToGlobal(pt));
        });

        mButtonsById.insert(entryId, btn);
        mTabLayout->addWidget(btn);
    }

    mTabLayout->addStretch(1);
    updateActiveButtonHighlight();
    setVisible(true);
    QTimer::singleShot(0, this, &PromptNavBar::updateBarHeight);
}

void PromptNavBar::updateActiveButtonHighlight() {
    for (auto it = mButtonsById.cbegin(); it != mButtonsById.cend(); ++it) {
        QPushButton* btn = it.value();
        if (!btn)
            continue;
        const QString mode = btn->property("entryMode").toString();
        const bool isActive = (it.key() == mActiveEntryId);
        btn->setStyleSheet(buttonStyleSheet(mode, isActive));
    }
}

void PromptNavBar::updateBarHeight() {
    if (!mScrollArea)
        return;
    QScrollBar* hbar = mScrollArea->horizontalScrollBar();
    const bool hbarVisible = hbar && hbar->isVisible();
    const int hbarHeight = hbarVisible ? qMax(8, hbar->sizeHint().height()) : 0;
    const int innerH = kRowContentHeight + hbarHeight;
    mScrollArea->setFixedHeight(innerH);
    setFixedHeight(innerH + 1);
}

void PromptNavBar::updateContainerStyle() {
    const QColor win = palette().color(QPalette::Window);
    const QColor shadow = palette().color(QPalette::Shadow);
    const bool isDark = win.value() < 128;

    const QString bgHex = (isDark ? win.darker(115) : win.darker(104)).name();
    const QString borderHex = shadow.name();
    const QString handleHex = isDark ? QStringLiteral("#555555") : QStringLiteral("#b0b0b0");
    const QString handleHoverHex = isDark ? QStringLiteral("#777777") : QStringLiteral("#888888");

    setStyleSheet(QStringLiteral(
        "#PromptNavBar { background-color: %1; border-top: 1px solid %2; }"
        "#PromptNavBar QScrollArea { background-color: %1; border: none; }"
        "#PromptNavBar QScrollBar:horizontal { height: 7px; background: %1; margin: 0px; }"
        "#PromptNavBar QScrollBar::handle:horizontal { background: %3; border-radius: 3px; min-width: 24px; }"
        "#PromptNavBar QScrollBar::handle:horizontal:hover { background: %4; }"
        "#PromptNavBar QScrollBar::add-line:horizontal, #PromptNavBar QScrollBar::sub-line:horizontal { width: 0px; }"
        "#PromptNavBar QScrollBar::add-page:horizontal, #PromptNavBar QScrollBar::sub-page:horizontal { background: none; }")
                      .arg(bgHex, borderHex, handleHex, handleHoverHex));
    if (mContainer)
        mContainer->setStyleSheet(QStringLiteral("background-color: %1;").arg(bgHex));
}

QString PromptNavBar::buttonStyleSheet(const QString& mode, bool active) const {
    const QColor win = palette().color(QPalette::Window);
    const QColor text = palette().color(QPalette::WindowText);
    const bool isDark = win.value() < 128;
    const QString accent = accentColorForMode(mode);

    QString bg;
    QString hoverBg;
    QString border;
    QString fg = text.name();

    if (active) {
        bg = isDark ? QStringLiteral("#2d3748") : QStringLiteral("#dce8f7");
        hoverBg = isDark ? QStringLiteral("#374459") : QStringLiteral("#cddff5");
        border = accent;
    } else {
        bg = isDark ? QStringLiteral("#262626") : QStringLiteral("#e8e8e8");
        hoverBg = isDark ? QStringLiteral("#333333") : QStringLiteral("#dcdcdc");
        border = isDark ? QStringLiteral("#3a3a3a") : QStringLiteral("#c8c8c8");
    }

    return QStringLiteral(
        "QPushButton {"
        "  background-color: %1;"
        "  color: %2;"
        "  border: 1px solid %3;"
        "  border-left: 3px solid %4;"
        "  border-radius: 3px;"
        "  padding: 1px 7px;"
        "  font-size: 11px;"
        "  font-weight: %5;"
        "}"
        "QPushButton:hover {"
        "  background-color: %6;"
        "  border-color: %4;"
        "}")
        .arg(bg, fg, border, accent, active ? QStringLiteral("bold") : QStringLiteral("normal"), hoverBg);
}

void PromptNavBar::jumpToEntry(int entryId) {
    if (!mActiveDoc || !mDocEntries.contains(mActiveDoc))
        return;

    const QVector<PromptNavEntry>& entries = mDocEntries.value(mActiveDoc);
    for (const PromptNavEntry& entry : entries) {
        if (entry.id != entryId)
            continue;

        const int pos = entryPosition(entry, mActiveDoc);
        if (mCurrentEditor && mCurrentEditor->document() == mActiveDoc) {
            const QTextBlock block = mActiveDoc->textDocument()->findBlock(pos);
            const int lineStartPos = block.isValid() ? block.position() : pos;
            mCurrentEditor->showPosition(lineStartPos, 0);
            if (block.isValid() && mCurrentEditor->verticalScrollBar()) {
                mCurrentEditor->verticalScrollBar()->setValue(block.firstLineNumber());
            }
            mCurrentEditor->setFocus(Qt::OtherFocusReason);
        }

        mActiveEntryId = entryId;
        updateActiveButtonHighlight();

        if (QPushButton* btn = mButtonsById.value(entryId, nullptr))
            mScrollArea->ensureWidgetVisible(btn, 16, 0);
        return;
    }
}

void PromptNavBar::showTabContextMenu(int entryId, const QPoint& globalPos) {
    if (!mActiveDoc || !mDocEntries.contains(mActiveDoc))
        return;

    const PromptNavEntry* target = nullptr;
    const QVector<PromptNavEntry>& entries = mDocEntries.value(mActiveDoc);
    for (const PromptNavEntry& entry : entries) {
        if (entry.id == entryId) {
            target = &entry;
            break;
        }
    }
    if (!target)
        return;

    QMenu menu(this);
    QAction* jumpAct = menu.addAction(tr("Jump to Code Block"));
    QAction* copyAct = menu.addAction(tr("Copy Prompt"));
    copyAct->setEnabled(!target->prompt.isEmpty());
    menu.addSeparator();
    QAction* removeAct = menu.addAction(tr("Remove Navigation Tab"));

    QAction* chosen = menu.exec(globalPos);
    if (chosen == jumpAct) {
        jumpToEntry(entryId);
    } else if (chosen == copyAct) {
        QApplication::clipboard()->setText(target->prompt);
    } else if (chosen == removeAct) {
        removeEntry(mActiveDoc, entryId);
    }
}

void PromptNavBar::reanchorEntries(Document* doc) {
    if (!doc || !mDocEntries.contains(doc))
        return;

    QTextDocument* tdoc = doc->textDocument();
    const QString docText = tdoc->toPlainText();
    const int maxValidPos = qMax(0, tdoc->characterCount() - 1);

    QVector<PromptNavEntry>& entries = mDocEntries[doc];
    for (PromptNavEntry& entry : entries) {
        const QString headerLine = formatHeaderComment(entry.mode, entry.modeIndex, entry.prompt, entry.model);
        int pos = findClosestMatch(docText, headerLine, entry.savedPos);
        if (pos < 0)
            pos = reanchorPosition(docText, entry.savedPos, entry.anchorText);
        pos = qBound(0, pos, maxValidPos);
        entry.savedPos = pos;
        entry.cursor = QTextCursor(tdoc);
        entry.cursor.setPosition(pos);
        entry.cursor.setKeepPositionOnInsert(true);
    }

    if (doc == mActiveDoc)
        rebuildButtons();
}

void PromptNavBar::ensureDocumentWatched(Document* doc) {
    if (!doc || mWatchedDocs.contains(doc))
        return;

    mWatchedDocs.insert(doc);
    mLastDocCharCount[doc] = doc->textDocument()->characterCount();
    connect(doc->textDocument(), &QTextDocument::contentsChange,
            this, &PromptNavBar::onDocumentContentsChange);
}

void PromptNavBar::lazyLoadFromSidecarIfNeeded(Document* doc) {
    if (!doc || mLoadedDocs.contains(doc))
        return;

    mLoadedDocs.insert(doc);
    const QString fp = doc->filePath();
    if (fp.isEmpty())
        return;

    const QString sidecarPath = fp + QStringLiteral(".ai-session.json");
    if (!QFileInfo::exists(sidecarPath))
        return;

    QFile f(sidecarPath);
    if (!f.open(QIODevice::ReadOnly))
        return;

    const QJsonDocument jsonDoc = QJsonDocument::fromJson(f.readAll());
    if (jsonDoc.isNull() || !jsonDoc.isObject())
        return;

    const QJsonObject obj = jsonDoc.object();
    if (obj.contains(QStringLiteral("prompt_blocks")) && obj.value(QStringLiteral("prompt_blocks")).isArray())
        restoreFromJsonArray(doc, obj.value(QStringLiteral("prompt_blocks")).toArray(), false);
}

int PromptNavBar::entryPosition(const PromptNavEntry& entry, const Document* doc) const {
    if (!doc)
        return entry.savedPos;
    const QTextDocument* tdoc = const_cast<Document*>(doc)->textDocument();
    const QString docText = tdoc->toPlainText();
    const int maxValidPos = qMax(0, tdoc->characterCount() - 1);
    int rawPos = entry.cursor.isNull() ? entry.savedPos : entry.cursor.position();
    rawPos = qBound(0, rawPos, maxValidPos);

    const QString headerLine = formatHeaderComment(entry.mode, entry.modeIndex, entry.prompt, entry.model);
    const int headerIdx = findClosestMatch(docText, headerLine, rawPos);
    if (headerIdx >= 0)
        return qBound(0, headerIdx, maxValidPos);

    if (!entry.anchorText.isEmpty())
        return qBound(0, reanchorPosition(docText, rawPos, entry.anchorText), maxValidPos);

    return rawPos;
}

} // namespace ScIDE
