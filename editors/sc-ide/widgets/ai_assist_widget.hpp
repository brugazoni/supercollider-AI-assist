/*
    SuperCollider Qt IDE — AI Assist Widget
    Tabbed interface for sc-gen-rag integration.
*/

#pragma once

#include <QWidget>
#include <QTabWidget>
#include <QPlainTextEdit>
#include <QLineEdit>
#include <QPushButton>
#include <QCheckBox>
#include <QRadioButton>
#include <QButtonGroup>
#include <QComboBox>
#include <QLabel>
#include <QProgressBar>
#include <QProcess>
#include <QSlider>
#include <QPointer>
#include <QMap>
#include <QQueue>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTemporaryFile>
#include <QMessageBox>
#include <QDialog>
#include <QList>
#include <QPair>
#include <QTextBrowser>
#include <QTextEdit>
#include <QListWidget>
#include <QProgressDialog>

namespace ScIDE {

class PostWindow;
class Document;
class PromptNavBar;

// SystemMessageDialog removed — replaced by reusable openSysMessageEditor()

class AiAssistWidget : public QWidget {
    Q_OBJECT

public:
    explicit AiAssistWidget(PostWindow* postWindow, QWidget* parent = nullptr);
    ~AiAssistWidget();
    void handleIdeShutdown();
    void connectDocumentSignals();

    PostWindow* postWindow() const { return mPostWindow; }

signals:
    void xAppendEvaluated(const QString& mode, int promptIndex, const QString& code);

public slots:
    void setLastEvaluatedCode(const QString& code);
    void onPostWindowText(const QString& text);

private slots:
    // Generate tab
    void onPlanClicked();
    void onGenerateClicked();

    // Design tab
    void onDesignPlanClicked();
    void onDesignGenerateClicked();

    // Compose tab
    void onComposePlanClicked();
    void onComposeGenerateClicked();

    // Custom tab
    void onCustomGenerateClicked();
    void onCustomSysEditClicked();

    // Append tab
    void onAppendClicked();
    void onAutoExecuteToggled(bool checked);
    void onDictateToggled();
    void onDictateMuteToggled();
    void submitAppendForBlock(const QString& prompt, bool isAuto = false);
    void processAppendQueue();

    // Cross-Append tab
    void onXAppendModeChanged();
    void onXAppendClicked();
    void onXDictateToggled();
    void onXDictateMuteToggled();
    void submitCrossAppendForBlock(const QString& prompt, const QString& mode, bool isValidation = false, qint64 enqueuedAtMs = 0);
    void processXAppendQueue(bool logIfBusy = false);

    // Cross-Append validation buttons (Send / RAG / P presets / random corpus dice)
    void onXTestPresetClicked(const QString& key);
    void onXTestRandomCorpusClicked(const QString& key);
    void onXTestSendClicked(const QString& mode);
    void onXTestRagClicked(const QString& mode);
    void submitXRagValidation(const QString& prompt, const QString& mode, qint64 enqueuedAtMs = 0);

    // Fix tab
    void onFixClicked();

    // Remake tab
    void onRemakeClicked();

    // Learn tab
    void onLearnSendClicked();

    // Add to KB tab
    void onAddKbClicked();
    void onConsumeKbClicked();
    void onKbSourceEditClicked();

    // System message handlers (per-tab, per-stage)
    void onGenPlanSysClicked();
    void onGenCodeSysClicked();
    void onDesignPlanSysClicked();
    void onDesignCodeSysClicked();
    void onComposePlanSysClicked();
    void onComposeCodeSysClicked();
    void onAppSysClicked();
    void onFixSysClicked();
    void onRemSysClicked();
    void onLearnSysClicked();

    // Prompt History
    void onPromptHistoryClicked();

    // Process handling
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void applyRagFallback();
    void onErrorCheckTimeout();

    // Session Stats & Setup
    void onSessionStatsClicked();
    void onImportSessionClicked();
    void onSustainabilityClicked();
    void onBootupClicked();
    void onApiKeysClicked();
    void onStatusClicked();
    void onCancelClicked();
    void onModelChanged(const QString& modelName);
    void onOpenRouterModelChanged(int index);
    void onOpenRouterBrowseClicked();
    void onOpenRouterDefaultsClicked();
    void fetchOpenRouterModels();
    void populateOpenRouterCombo(const QJsonArray& models);
    QString currentModelKey() const;
    void onTemperatureSliderChanged(int value);

private:
    void createTabs();
    QWidget* createGenerateTab();
    QWidget* createDesignTab();
    QWidget* createComposeTab();
    QWidget* createCustomTab();
    QWidget* createAppendTab();
    QWidget* createCrossAppendTab();
    QWidget* createFixTab();
    QWidget* createRemakeTab();
    QWidget* createLearnTab();
    QWidget* createAddKbTab();

    QJsonObject basePayload() const;
    void runBackendCommand(const QString& command, const QJsonObject& data,
                           std::function<void(const QJsonObject&)> callback);
    QString pythonPath() const;
    QString backendScriptPath() const;
    QString systemMessagesDir() const;
    void openSysMessageEditor(QStringList& selectedList);
    void saveSysMsgDefaults();
    void loadSysMsgDefaults();
    void saveOpenRouterDefaults();
    void loadOpenRouterDefaults();
    void selectOpenRouterSlot(int slot, bool activateProvider = true);
    void applyOpenRouterModelToCombo(const QString& modelId, bool triggerModelChanged = false);
    void updateOpenRouterSlotTooltips();
    void setProcessingState(bool processing);
    void updateCancelButtonState();
    void updateLatestBlockFields();
    void evaluateCodeBlocks(const QString& code);
    void tryUpdateSessionStats();

    // Session persistence
    void saveSessionFor(Document* doc);
    void restoreSessionFor(const QString& filePath, bool forceNavRestore = false);
    bool hasSessionContent() const;
    bool hasApiKeyForCurrentModel();
    QString sessionFilePath(Document* doc) const;
    void clearSessionFields();

    // Prompt navigation bar helpers
    PromptNavBar* promptNavBar() const;
    int registerPromptNavBlock(Document* doc, const QString& mode, const QString& prompt,
                               int insertPos, const QString& codeText, const QString& model = QString());
    void removePromptNavEntry(Document* doc, int entryId);

    // Persistent daemon backend
    void startDaemon();
    void onDaemonFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void handleDaemonResponse(const QByteArray& jsonLine);

    // Document lifecycle handlers
    void onDocumentSaved(Document* doc);
    void onDocumentShown(Document* doc, int pos, int selLen);
    void onDocumentClosed(Document* doc);

    // UI
    QTabWidget* mTabWidget;
    PostWindow* mPostWindow;
    QComboBox* mModelCombo;
    QRadioButton* mProviderDirectRadio;
    QRadioButton* mProviderOpenRouterRadio;
    QPushButton* mOpenRouterFastBtn;
    QPushButton* mOpenRouterBetterBtn;
    QComboBox* mOpenRouterCombo;
    QPushButton* mOpenRouterBrowseBtn;
    QPushButton* mOpenRouterDefaultsBtn;
    QJsonArray mOpenRouterModels;
    QString mOpenRouterFastModel = QStringLiteral("openai/gpt-6-luna");
    QString mOpenRouterBetterModel = QStringLiteral("openai/gpt-6.1-sol");
    int mActiveOpenRouterSlot = 0; // 0 = Fast, 1 = Better
    // OpenRouter model ID restored from a session before the (async) model list
    // was fetched. Re-applied once populateOpenRouterCombo() runs.
    QString mPendingOpenRouterModel;
    QPushButton* mPromptHistoryBtn;
    QPushButton* mSessionStatsBtn;
    QPushButton* mImportSessionBtn;
    QPushButton* mBootupBtn;
    QPushButton* mApiKeysBtn;
    QPushButton* mStatusBtn;
    QPushButton* mCancelBtn = nullptr;
    QPushButton* mEcoLabel;
    QLabel* mTotalWaitLabel;
    QProgressBar* mContextBar;
    QLabel* mContextLabel;
    QPushButton* mSustainabilityBtn;
    
    QSlider* mTempSlider;
    QLabel* mTempLabel;
    QComboBox* mThinkingCombo;
    QMap<QString, QJsonObject> mModelConfig;

    // Cached eco totals for the detail dialog
    double mEcoEnergy = 0.0;
    double mEcoGwp = 0.0;
    double mEcoAdpe = 0.0;
    double mEcoPe = 0.0;
    double mEcoWcf = 0.0;
    bool mEcoFb = false;

    // Generate tab widgets
    QPlainTextEdit* mGenPrompt;
    QCheckBox* mGenUseKb;
    QCheckBox* mGenIncludeEnding;
    QPushButton* mGenPlanBtn;
    QPushButton* mGenPlanSysBtn;
    QPushButton* mGenCodeSysBtn;
    QPlainTextEdit* mGenPlanOutput;
    QPushButton* mGenGenerateBtn;

    // Design tab widgets
    QPlainTextEdit* mDesignPrompt;
    QCheckBox* mDesignUseKb;
    QPushButton* mDesignPlanBtn;
    QPushButton* mDesignPlanSysBtn;
    QPushButton* mDesignCodeSysBtn;
    QPlainTextEdit* mDesignPlanOutput;
    QPushButton* mDesignGenerateBtn;

    // Compose tab widgets
    QPlainTextEdit* mComposePrompt;
    QCheckBox* mComposeUseKb;
    QPushButton* mComposePlanBtn;
    QPushButton* mComposePlanSysBtn;
    QPushButton* mComposeCodeSysBtn;
    QPlainTextEdit* mComposePlanOutput;
    QPushButton* mComposeGenerateBtn;

    // Custom tab widgets
    QPlainTextEdit* mCustomPrompt;
    QCheckBox* mCustomUseKb;
    QPushButton* mCustomSysBtn;
    QPushButton* mCustomGenerateBtn;

    // Append tab widgets
    QPlainTextEdit* mAppendPrompt;
    QPushButton* mAppendBtn;
    QPushButton* mSystemMsgBtnApp;
    QCheckBox* mAutoExecuteCheck;
    QCheckBox* mAppendUseKb;
    QPushButton* mDictateBtn;
    QPushButton* mDictateMuteBtn;
    QCheckBox* mAutoAppendCheck;
    QComboBox* mDictLangCombo;       // STT language selector (en, pt, es, auto-detect)
    QComboBox* mDictModelCombo;      // Whisper model size selector
    QTextEdit* mAutoAppendLog;       // dedicated log area for auto-append activity
    int mDictationBlockIndex = 0;     // monotonic counter for indexed dictation separators
    bool mDictating = false;
    bool mDictationMuted = false;
    bool mDictationModelLoaded = false;
    QProgressDialog* mDictationLoadingDialog = nullptr;
    QString mLastDictationBlock;
    QQueue<QString> mAppendQueue;

    QString mRagFallbackCode;
    QString mPendingFallbackMode;
    bool mWaitingForErrorCheck = false;
    QTimer* mErrorCheckTimer = nullptr;
    bool mXErrorCheckInFlight = false;
    QString mXCurrentCandidateCode;
    QString mXCurrentMode;
    QString mXCurrentOkTag;
    int mXCurrentFixAttempt = 0;
    int mXCurrentMaxFixAttempts = 0;
    QString mXLastInsertedChunk;
    QPointer<Document> mXLastNavDoc;
    int mXLastNavEntryId = 0;
    QTimer* mXPostErrorFixTimer = nullptr;
    void onMainServerErrorAutoFix();

    // Cross-Append tab widgets
    QPlainTextEdit* mXPrompt;
    QPushButton* mXAppendBtn;
    QRadioButton* mXAppendRadio;
    QRadioButton* mXComposeRadio;
    QRadioButton* mXDesignRadio;
    QRadioButton* mXGenerateRadio;
    QCheckBox* mXAutoExecuteCheck;
    QCheckBox* mXAutoAppendCheck;
    QCheckBox* mXUseKbCheck;
    QCheckBox* mXLeanPromptCheck = nullptr;
    QCheckBox* mXAutoFixCheck = nullptr;
    QComboBox* mXAutoFixAttemptsCombo = nullptr;
    QPushButton* mXDictateBtn;
    QPushButton* mXDictateMuteBtn;
    QComboBox* mXDictLangCombo;
    QComboBox* mXDictModelCombo;
    QTextEdit* mXAutoAppendLog;
    int mXDictationBlockIndex = 0;

    // Live + final elapsed time counter next to sent prompt logs in X-Append
    QTimer* mXPromptElapsedTimer = nullptr;
    int mXPromptTimerSeq = 0;
    int mXActivePromptId = 0;
    qint64 mXActivePromptStartMs = 0;
    QString mXActivePromptToken;
    QString startXPromptTimer(qint64 startMs = 0);
    void updateXPromptTimerDisplay();
    double finishXPromptTimer(const QString& colorHex = QStringLiteral("#2ecc71"));

    // Parallel Validation Server UI & process (X-Append)
    QLabel* mValServerStatusLabel = nullptr;
    QPushButton* mValServerConsoleToggleBtn = nullptr;
    QPushButton* mValServerRestartBtn = nullptr;
    QTextEdit* mValServerConsole = nullptr;
    QProcess* mValidationProcess = nullptr;
    QTimer* mValidationTimeoutTimer = nullptr;
    QString mValidationOutputBuffer;
    bool mValidationReady = false;
    bool mValidationBusy = false;
    std::function<void(bool, const QString&)> mValidationCallback;

    void startValidationServer();
    void stopValidationServer();
    void handleValidationServerOutput(const QString& chunk);
    void validateCodeOnParallelServer(const QString& code, const QString& mode,
                                      std::function<void(bool valid, const QString& errorMsg)> callback);
    void validateAndCommitOrFixXAppend(const QString& candidateCode, const QString& mode,
                                       const QString& okTag, const QString& fallbackCode,
                                       int fixAttempt, int maxFixAttempts);

    // Cross-Append job queue. Dictation and validation jobs share this queue so
    // they are serialized through the single daemon exactly like voice blocks.
    enum class XJobKind { Dictation, ValidationSend, ValidationRag };
    struct XAppendJob {
        QString prompt;
        QString mode;
        XJobKind kind = XJobKind::Dictation;
        qint64 enqueuedAtMs = 0;
    };
    QQueue<XAppendJob> mXAppendQueue;

    // Failsafe RAG verification & queueing pipeline (Gate 1 + Gate 2 on Val Server)
    struct PendingRagCandidate {
        QString code;
        QString prompt;
        QString hintMode;
        bool alreadyValidatedGate1 = false;
    };
    QQueue<PendingRagCandidate> mRagVerifyQueue;
    PendingRagCandidate mActiveRagCandidate;
    bool mRagVerifyInFlight = false;
    int mSessionDuplicateRagCount = 0;
    QString mPendingAppendRagCode;
    QString mPendingAppendRagPrompt;
    QString mXCurrentPrompt;
    QString mXCurrentModel;
    void enqueueRagCandidate(const QString& code, const QString& prompt,
                             const QString& hintMode, bool alreadyValidatedGate1);
    void processRagVerifyQueue();
    void validateRagExecutableBlocksOnServer(const QStringList& execBlocks,
                                             const QString& consolidatedBlock,
                                             const QString& mode,
                                             std::function<void(bool valid, const QString& errorMsg)> callback);

    // Validation preset prompts ("P" buttons), keyed "send_append", "rag_design", ...
    // Persisted in sc-gen-rag/xappend_test_prompts.json across sessions.
    QMap<QString, QString> mXTestPrompts;
    QVector<QJsonObject> mXCorpusFragments;
    QString xTestPromptsFilePath() const;
    QString xCorpusFilePath() const;
    bool loadXCorpusFragments();
    void loadXTestPrompts();
    void saveXTestPrompts();
    QWidget* createXTestCell(const QString& kind, const QString& mode, const QString& label);
    void appendXHistoryBlock(const QString& block);
    void runRagFailsafeCode(const QString& code, const QString& mode, std::function<void()> onDone,
                            const QString& prompt = QString());

    // Fix tab widgets
    QPlainTextEdit* mFixBlock;
    QPlainTextEdit* mFixStackTrace;
    QPushButton* mFixBtn;
    QPushButton* mSystemMsgBtnFix;

    // Remake tab widgets
    QPlainTextEdit* mRemakeBlock;
    QPlainTextEdit* mRemakePrompt;
    QPushButton* mRemakeBtn;
    QPushButton* mSystemMsgBtnRem;

    // Learn tab widgets
    QPlainTextEdit* mLearnHistory;
    QLineEdit* mLearnPrompt;
    QPushButton* mLearnSendBtn;
    QPushButton* mSystemMsgBtnLearn;

    // Add to KB tab widgets
    QPlainTextEdit* mKbBlock;
    QPlainTextEdit* mKbDescription;
    QPushButton* mKbAddBtn;
    QPushButton* mKbConsumeBtn;

    // State
    QString mLastEvaluatedCode;
    QString mLastStackTrace;
    QString mCompositionState;
    QString mLearnChatHistory;
    QString mFullStatusText;
    QPointer<Document> mLastActiveDocument;

    // Per-tab system message selections
    QStringList mGenPlanSysMsgs;
    QStringList mGenCodeSysMsgs;
    QStringList mDesignPlanSysMsgs;
    QStringList mDesignCodeSysMsgs;
    QStringList mComposePlanSysMsgs;
    QStringList mComposeCodeSysMsgs;
    QStringList mAppendSysMsgs;
    QStringList mFixSysMsgs;
    QStringList mRemakeSysMsgs;
    QStringList mLearnSysMsgs;
    QStringList mCustomSelectedSysMsgs;

    // Legacy per-command process (for sync startup commands)
    QProcess* mCurrentProcess;
    QByteArray mCurrentOutput;
    QByteArray mCurrentErrorOutput;
    std::function<void(const QJsonObject&)> mCurrentCallback;

    // Persistent daemon process
    QProcess* mDaemonProcess = nullptr;
    QByteArray mDaemonOutputBuffer;
    bool mDaemonReady = false;
    bool mDaemonBusy = false;
    int mRequestSeq = 0;
    int mActiveRequestId = 0;
};

} // namespace ScIDE

