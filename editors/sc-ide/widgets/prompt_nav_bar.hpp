/*
    SuperCollider Qt IDE — Prompt Navigation Bar
    Horizontal scrollable bar at the bottom of the code window for jumping to
    prompt-generated code blocks (G1, D1, A1, C1, ...).
*/

#pragma once

#include <QWidget>
#include <QHash>
#include <QSet>
#include <QVector>
#include <QPointer>
#include <QTextCursor>
#include <QJsonArray>
#include <QString>

class QScrollArea;
class QHBoxLayout;
class QPushButton;

namespace ScIDE {

class Document;
class GenericCodeEditor;

struct PromptNavEntry {
    int id = 0;
    QString mode;
    QString prefix;
    int modeIndex = 0;
    QString word;
    QString prompt;
    QString model;
    QString anchorText;
    int savedPos = 0;
    QTextCursor cursor;
};

class PromptNavBar : public QWidget {
    Q_OBJECT

public:
    explicit PromptNavBar(QWidget* parent = nullptr);

    static QString prefixForMode(const QString& mode);
    static QString extractFirstWord(const QString& prompt);
    static QString formatHeaderComment(const QString& mode, int interactionIndex,
                                       const QString& prompt, const QString& model = QString());
    static int firstCodeOffset(const QString& code);

    int nextInteractionIndex(Document* doc) const;
    int addEntry(Document* doc, const QString& mode, const QString& prompt,
                 int insertPos, const QString& codeText, const QString& model = QString());
    void removeEntry(Document* doc, int entryId);
    void handleRangeReplaced(Document* doc, int startPos, int oldLen, const QString& newText);

    void setCurrentEditor(GenericCodeEditor* editor);
    void setActiveDocument(Document* doc);
    void onDocumentClosed(Document* doc);

    QJsonArray serializeForDocument(Document* doc);
    void restoreFromJsonArray(Document* doc, const QJsonArray& arr, bool forceReplace = false);

protected:
    bool eventFilter(QObject* watched, QEvent* event) override;
    void changeEvent(QEvent* event) override;

private slots:
    void onCursorPositionChanged();
    void onDocumentContentsChange(int position, int charsRemoved, int charsAdded);

private:
    void rebuildButtons();
    void updateActiveButtonHighlight();
    void updateBarHeight();
    void updateContainerStyle();
    void jumpToEntry(int entryId);
    void showTabContextMenu(int entryId, const QPoint& globalPos);
    void reanchorEntries(Document* doc);
    void ensureDocumentWatched(Document* doc);
    void lazyLoadFromSidecarIfNeeded(Document* doc);
    int entryPosition(const PromptNavEntry& entry, const Document* doc) const;
    QString buttonStyleSheet(const QString& mode, bool active) const;

    bool mUpdatingStyle = false;
    QScrollArea* mScrollArea = nullptr;
    QWidget* mContainer = nullptr;
    QHBoxLayout* mTabLayout = nullptr;

    QPointer<GenericCodeEditor> mCurrentEditor;
    QPointer<Document> mActiveDoc;
    int mNextEntryId = 1;
    int mActiveEntryId = -1;

    QHash<Document*, QVector<PromptNavEntry>> mDocEntries;
    QSet<Document*> mLoadedDocs;
    QSet<Document*> mWatchedDocs;
    QHash<Document*, int> mLastDocCharCount;
    QHash<int, QPushButton*> mButtonsById;
};

} // namespace ScIDE
