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
#include <QComboBox>
#include <QLabel>
#include <QProgressBar>
#include <QProcess>
#include <QSlider>
#include <QMap>
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
#include <QListWidget>
#include <QProgressDialog>

namespace ScIDE {

class PostWindow;
class Document;

// SystemMessageDialog removed — replaced by reusable openSysMessageEditor()

class AiAssistWidget : public QWidget {
    Q_OBJECT

public:
    explicit AiAssistWidget(PostWindow* postWindow, QWidget* parent = nullptr);
    ~AiAssistWidget();
    void handleIdeShutdown();
    void connectDocumentSignals();

    PostWindow* postWindow() const { return mPostWindow; }

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

    // Session Stats & Setup
    void onSessionStatsClicked();
    void onImportSessionClicked();
    void onSustainabilityClicked();
    void onBootupClicked();
    void onApiKeysClicked();
    void onStatusClicked();
    void onModelChanged(const QString& modelName);
    void onTemperatureSliderChanged(int value);

private:
    void createTabs();
    QWidget* createGenerateTab();
    QWidget* createDesignTab();
    QWidget* createComposeTab();
    QWidget* createCustomTab();
    QWidget* createAppendTab();
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
    void setProcessingState(bool processing);
    void updateLatestBlockFields();
    void tryUpdateSessionStats();

    // Session persistence
    void saveSessionFor(Document* doc);
    void restoreSessionFor(const QString& filePath);
    bool hasSessionContent() const;
    QString sessionFilePath(Document* doc) const;
    void clearSessionFields();

    // Document lifecycle handlers
    void onDocumentSaved(Document* doc);
    void onDocumentShown(Document* doc, int pos, int selLen);
    void onDocumentClosed(Document* doc);

    // UI
    QTabWidget* mTabWidget;
    PostWindow* mPostWindow;
    QComboBox* mModelCombo;
    QPushButton* mPromptHistoryBtn;
    QPushButton* mSessionStatsBtn;
    QPushButton* mImportSessionBtn;
    QPushButton* mBootupBtn;
    QPushButton* mApiKeysBtn;
    QPushButton* mStatusBtn;
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
    QCheckBox* mAppendUseCodeContext;

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
    Document* mLastActiveDocument;

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

    // Active process
    QProcess* mCurrentProcess;
    QByteArray mCurrentOutput;
    QByteArray mCurrentErrorOutput;
    std::function<void(const QJsonObject&)> mCurrentCallback;
};

} // namespace ScIDE
