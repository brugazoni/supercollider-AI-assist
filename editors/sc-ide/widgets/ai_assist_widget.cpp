/*
    SuperCollider Qt IDE — AI Assist Widget
    Tabbed interface for sc-gen-rag integration.
*/

#include "ai_assist_widget.hpp"
#include "post_window.hpp"
#include "../core/doc_manager.hpp"
#include "../core/main.hpp"
#include <QTextCursor>

#include <QApplication>
#include <QDir>
#include <QFileInfo>
#include <QScrollBar>
#include <QProgressBar>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTemporaryFile>
#include <QMessageBox>
#include <QDialog>
#include <QList>
#include <QPair>
#include <QTextBrowser>
#include <QFileDialog>
#include <QUuid>
#include <QVBoxLayout>
#include <QHBoxLayout>

namespace ScIDE {

SystemMessageDialog::SystemMessageDialog(const QList<QPair<QString, QString>>& files, QWidget* parent)
    : QDialog(parent) {
    setWindowTitle(tr("System Messages Editor"));
    resize(800, 600);
    
    QVBoxLayout* layout = new QVBoxLayout(this);
    QTabWidget* tabs = new QTabWidget;
    layout->addWidget(tabs);
    
    for (const auto& pair : files) {
        QString label = pair.first;
        QString path = pair.second;
        
        QPlainTextEdit* editor = new QPlainTextEdit;
        QFile file(path);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            editor->setPlainText(QString::fromUtf8(file.readAll()));
            file.close();
        } else {
            editor->setPlainText(tr("File not found: ") + path);
        }
        
        mEditors.append(qMakePair(path, editor));
        tabs->addTab(editor, label);
    }
    
    QHBoxLayout* btnRow = new QHBoxLayout;
    btnRow->addStretch();
    QPushButton* saveBtn = new QPushButton(tr("Save All"));
    QPushButton* cancelBtn = new QPushButton(tr("Cancel"));
    btnRow->addWidget(cancelBtn);
    btnRow->addWidget(saveBtn);
    layout->addLayout(btnRow);
    
    connect(cancelBtn, &QPushButton::clicked, this, &QDialog::reject);
    connect(saveBtn, &QPushButton::clicked, this, &SystemMessageDialog::onSaveClicked);
}

void SystemMessageDialog::onSaveClicked() {
    for (int i = 0; i < mEditors.size(); ++i) {
        QString path = mEditors[i].first;
        QPlainTextEdit* editor = mEditors[i].second;
        
        QFile file(path);
        QDir().mkpath(QFileInfo(file).absolutePath());
        
        if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            file.write(editor->toPlainText().toUtf8());
            file.close();
        } else {
            QMessageBox::warning(this, tr("Save Error"), tr("Failed to save: ") + path);
        }
    }
    accept();
}

AiAssistWidget::AiAssistWidget(PostWindow* postWindow, QWidget* parent)
    : QWidget(parent)
    , mPostWindow(postWindow)
    , mCurrentProcess(nullptr)
{
    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(0, 0, 0, 0);
    mainLayout->setSpacing(2);

    // === Row 1: Model selector, action buttons, status ===
    QHBoxLayout* row1 = new QHBoxLayout;
    row1->setContentsMargins(4, 2, 4, 2);
    row1->addWidget(new QLabel(tr("Model:")));
    mModelCombo = new QComboBox;
    mModelCombo->setMinimumWidth(150);
    row1->addWidget(mModelCombo);

    connect(mModelCombo, &QComboBox::currentTextChanged, this, &AiAssistWidget::onModelChanged);



    row1->addStretch();

    mSessionStatsBtn = new QPushButton(tr("Session: $0.00"));
    mSessionStatsBtn->setToolTip(tr("Click to view precision breakdown of current session cost and latency per model."));
    connect(mSessionStatsBtn, &QPushButton::clicked, this, &AiAssistWidget::onSessionStatsClicked);
    row1->addWidget(mSessionStatsBtn);

    mPromptHistoryBtn = new QPushButton(tr("Prompt History"));
    connect(mPromptHistoryBtn, &QPushButton::clicked, this, &AiAssistWidget::onPromptHistoryClicked);
    row1->addWidget(mPromptHistoryBtn);

    mImportSessionBtn = new QPushButton(tr("Import Session"));
    mImportSessionBtn->setToolTip(tr("Manually load a previous AI session for this file (.ai-session.json)."));
    connect(mImportSessionBtn, &QPushButton::clicked, this, &AiAssistWidget::onImportSessionClicked);
    row1->addWidget(mImportSessionBtn);

    mStatusBtn = new QPushButton;
    mStatusBtn->setFixedWidth(200);
    mStatusBtn->setFlat(true);
    mStatusBtn->setStyleSheet("QPushButton { font-weight: bold; color: white; text-align: left; padding: 2px 6px; border: 1px solid #555; border-radius: 4px; } QPushButton:hover { background-color: #3a3a3a; }");
    connect(mStatusBtn, &QPushButton::clicked, this, &AiAssistWidget::onStatusClicked);
    row1->addWidget(mStatusBtn);

    mainLayout->addLayout(row1);

    // === Row 2: Eco stats, context progress, total wait time ===
    QHBoxLayout* row2 = new QHBoxLayout;
    row2->setContentsMargins(4, 0, 4, 2);

    // Sustainability Info Button (compact)
    mSustainabilityBtn = new QPushButton(tr("i"));
    mSustainabilityBtn->setFixedSize(20, 20);
    mSustainabilityBtn->setToolTip(tr("View definitions for Eco-Impact metrics (Energy, GWP, ADPe, PE, WCF)"));
    mSustainabilityBtn->setStyleSheet("QPushButton { color: white; background-color: #2980b9; border-radius: 10px; font-weight: bold; font-size: 11px; }");
    connect(mSustainabilityBtn, &QPushButton::clicked, this, &AiAssistWidget::onSustainabilityClicked);
    row2->addWidget(mSustainabilityBtn);

    mEcoLabel = new QPushButton(tr("Eco: --"));
    mEcoLabel->setToolTip(tr("Click to view all environmental impact metrics and definitions."));
    mEcoLabel->setStyleSheet(
        "QPushButton { background-color: #27ae60; color: white; padding: 2px 6px; border-radius: 4px; border: none; text-align: left; }"
        "QPushButton:hover { background-color: #2ecc71; }");
    connect(mEcoLabel, &QPushButton::clicked, this, &AiAssistWidget::onSustainabilityClicked);
    row2->addWidget(mEcoLabel);

    // Temperature slider placed next to Eco Stats
    row2->addSpacing(10);
    row2->addWidget(new QLabel(tr("Temp:")));
    mTempSlider = new QSlider(Qt::Horizontal);
    mTempSlider->setRange(0, 20); // Fallback
    mTempSlider->setValue(7);
    mTempSlider->setFixedWidth(100);
    row2->addWidget(mTempSlider);
    
    mTempLabel = new QLabel(tr("0.7"));
    row2->addWidget(mTempLabel);

    connect(mTempSlider, &QSlider::valueChanged, this, &AiAssistWidget::onTemperatureSliderChanged);

    row2->addStretch();

    // Context Progress
    QHBoxLayout* ctxLayout = new QHBoxLayout;
    ctxLayout->setSpacing(4);
    mContextLabel = new QLabel(tr("Ctx: 0k"));
    mContextLabel->setStyleSheet("color: #7f8c8d;");
    mContextBar = new QProgressBar;
    mContextBar->setRange(0, 100);
    mContextBar->setValue(0);
    mContextBar->setFixedHeight(8);
    mContextBar->setFixedWidth(100);
    mContextBar->setTextVisible(false);
    mContextBar->setStyleSheet("QProgressBar { background-color: #2c3e50; border: none; border-radius: 4px; } "
                               "QProgressBar::chunk { background-color: #3498db; border-radius: 4px; }");
    mContextBar->setToolTip(tr("Cumulative context token usage for this session.\n"
                               "This tracks total tokens consumed across all calls.\n"
                               "Individual calls are sent independently to the API,\n"
                               "so exceeding 100%% does not block further generation\n"
                               "but may indicate heavy session usage."));
    ctxLayout->addWidget(mContextLabel);
    ctxLayout->addWidget(mContextBar);
    row2->addLayout(ctxLayout);

    row2->addStretch();

    // Total wait time
    mTotalWaitLabel = new QLabel(tr("Wait: 0.0s"));
    mTotalWaitLabel->setToolTip(tr("Total time spent waiting for LLM responses this session."));
    mTotalWaitLabel->setStyleSheet("QLabel { color: #f39c12; }");
    row2->addWidget(mTotalWaitLabel);

    mainLayout->addLayout(row2);

    // Tab widget
    mTabWidget = new QTabWidget;
    mainLayout->addWidget(mTabWidget);

    createTabs();
    setLayout(mainLayout);

    // Fetch models and config synchronously on startup (after all UI elements exist)
    QProcess modelProc;
    modelProc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList modelArgs;
    modelArgs << backendScriptPath() << "list_models" << "{}";
    modelProc.start(pythonPath(), modelArgs);
    if (modelProc.waitForFinished(3000)) {
        QJsonDocument doc = QJsonDocument::fromJson(modelProc.readAllStandardOutput());
        if (!doc.isNull() && doc.isObject()) {
            QJsonObject res = doc.object();
            QJsonObject info = res["models_info"].toObject();
            for (const QString& key : info.keys()) {
                mModelConfig.insert(key, info[key].toObject());
                mModelCombo->addItem(key);
            }
        }
    }

    // Safety net: if process fails or JSON is invalid, ensure combo box is usable
    if (mModelCombo->count() == 0) {
        mModelCombo->addItem("gemini/gemini-2.5-flash");
        mModelCombo->addItem("gemini/gemini-3.1-pro-preview");
        mModelCombo->addItem("ollama/qwen3:4b");
        mModelCombo->addItem("anthropic/claude-3-7-sonnet");
        mModelCombo->addItem("openai/gpt-4o");
        mModelCombo->addItem("deepseek/deepseek-chat");
    }
    
    // Init precise timestamped session log (silent)
    QProcess initProc;
    initProc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList initArgs;
    QJsonObject initData = basePayload();
    initArgs << backendScriptPath() << "init_session" << QJsonDocument(initData).toJson(QJsonDocument::Compact);
    initProc.start(pythonPath(), initArgs);
    initProc.waitForFinished(3000);
    
    // Initial fetch of session stats on startup
    tryUpdateSessionStats();
}

AiAssistWidget::~AiAssistWidget() {
}

void AiAssistWidget::onModelChanged(const QString& modelName) {
    if (mModelConfig.contains(modelName)) {
        QJsonObject conf = mModelConfig[modelName];
        double minTemp = conf["min_temp"].toDouble(0.0);
        double maxTemp = conf["max_temp"].toDouble(2.0);
        double defaultTemp = conf["default_temp"].toDouble(0.7);
        
        mTempSlider->blockSignals(true);
        mTempSlider->setRange(minTemp * 10, maxTemp * 10);
        mTempSlider->setValue(defaultTemp * 10);
        mTempLabel->setText(QString::number(defaultTemp, 'f', 1));
        mTempSlider->blockSignals(false);
    }
}

void AiAssistWidget::onTemperatureSliderChanged(int value) {
    double temp = value / 10.0;
    mTempLabel->setText(QString::number(temp, 'f', 1));
}

// --- Session Persistence ---

void AiAssistWidget::connectDocumentSignals() {
    DocumentManager* dm = Main::instance()->documentManager();
    connect(dm, &DocumentManager::saved, this, &AiAssistWidget::onDocumentSaved);
    connect(dm, &DocumentManager::showRequest, this, &AiAssistWidget::onDocumentShown);
    connect(dm, &DocumentManager::closed, this, &AiAssistWidget::onDocumentClosed);
}

QString AiAssistWidget::sessionFilePath(const QString& scdPath) const {
    return scdPath + ".ai-session.json";
}

bool AiAssistWidget::hasSessionContent() const {
    return !mGenPrompt->toPlainText().trimmed().isEmpty()
        || !mGenPlanOutput->toPlainText().trimmed().isEmpty()
        || !mDesignPrompt->toPlainText().trimmed().isEmpty()
        || !mDesignPlanOutput->toPlainText().trimmed().isEmpty()
        || !mCompositionState.isEmpty()
        || !mLearnChatHistory.isEmpty()
        || !mAppendPrompt->toPlainText().trimmed().isEmpty()
        || !mLearnHistory->toPlainText().trimmed().isEmpty();
}

void AiAssistWidget::saveSessionFor(const QString& filePath) {
    if (filePath.isEmpty()) return;
    
    QJsonObject session;
    session["gen_prompt"] = mGenPrompt->toPlainText();
    session["gen_plan"] = mGenPlanOutput->toPlainText();
    session["gen_use_kb"] = mGenUseKb->isChecked();
    session["gen_include_ending"] = mGenIncludeEnding->isChecked();
    session["design_prompt"] = mDesignPrompt->toPlainText();
    session["design_plan"] = mDesignPlanOutput->toPlainText();
    session["design_use_kb"] = mDesignUseKb->isChecked();
    session["append_prompt"] = mAppendPrompt->toPlainText();
    session["composition_state"] = mCompositionState;
    session["learn_history"] = mLearnHistory->toPlainText();
    session["learn_chat_history"] = mLearnChatHistory;
    session["model"] = mModelCombo->currentText();
    session["temperature"] = mTempSlider->value();
    session["remake_prompt"] = mRemakePrompt->toPlainText();
    session["kb_description"] = mKbDescription->toPlainText();
    
    // Enrich with Stats Labels state
    session["stats_cost_text"] = mSessionStatsBtn->text();
    session["stats_eco_text"] = mEcoLabel->text();
    session["stats_wait_text"] = mTotalWaitLabel->text();
    session["stats_ctx_text"] = mContextLabel->text();
    session["stats_ctx_value"] = mContextBar->value();

    // Fetch and embed the raw markdown log for perfect re-import
    QProcess proc;
    proc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList args;
    QJsonObject data = basePayload();
    args << backendScriptPath() << "get_raw_session_log" << QJsonDocument(data).toJson(QJsonDocument::Compact);
    proc.start(pythonPath(), args);
    if (proc.waitForFinished(3000)) {
        QJsonDocument doc = QJsonDocument::fromJson(proc.readAllStandardOutput());
        if (!doc.isNull() && doc.isObject()) {
            session["raw_log"] = doc.object()["raw_log"].toString();
        }
    }
    
    QFile f(sessionFilePath(filePath));
    if (f.open(QIODevice::WriteOnly)) {
        f.write(QJsonDocument(session).toJson());
    }
}

void AiAssistWidget::restoreSessionFor(const QString& filePath) {
    if (filePath.isEmpty()) return;
    
    QFile f(filePath);
    if (!f.open(QIODevice::ReadOnly)) return;
    
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (doc.isNull() || !doc.isObject()) return;
    
    QJsonObject session = doc.object();
    
    mGenPrompt->setPlainText(session["gen_prompt"].toString());
    mGenPlanOutput->setPlainText(session["gen_plan"].toString());
    mGenUseKb->setChecked(session["gen_use_kb"].toBool());
    mGenIncludeEnding->setChecked(session["gen_include_ending"].toBool(true));
    mDesignPrompt->setPlainText(session["design_prompt"].toString());
    mDesignPlanOutput->setPlainText(session["design_plan"].toString());
    mDesignUseKb->setChecked(session["design_use_kb"].toBool(true));
    mAppendPrompt->setPlainText(session["append_prompt"].toString());
    mCompositionState = session["composition_state"].toString();
    mLearnHistory->setPlainText(session["learn_history"].toString());
    mLearnChatHistory = session["learn_chat_history"].toString();
    mRemakePrompt->setPlainText(session["remake_prompt"].toString());
    mKbDescription->setPlainText(session["kb_description"].toString());
    
    // Restore labels
    if (session.contains("stats_cost_text")) mSessionStatsBtn->setText(session["stats_cost_text"].toString());
    if (session.contains("stats_eco_text")) mEcoLabel->setText(session["stats_eco_text"].toString());
    if (session.contains("stats_wait_text")) mTotalWaitLabel->setText(session["stats_wait_text"].toString());
    if (session.contains("stats_ctx_text")) mContextLabel->setText(session["stats_ctx_text"].toString());
    if (session.contains("stats_ctx_value")) mContextBar->setValue(session["stats_ctx_value"].toInt());

    // Restore model selection
    QString model = session["model"].toString();
    int idx = mModelCombo->findText(model);
    if (idx >= 0) mModelCombo->setCurrentIndex(idx);
    
    if (session.contains("temperature")) {
        mTempSlider->setValue(session["temperature"].toInt());
    }
    
    // Sync the raw log back to the backend
    if (session.contains("raw_log")) {
        QProcess proc;
        proc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
        QStringList args;
        QJsonObject data = basePayload();
        data["raw_log"] = session["raw_log"].toString();
        args << backendScriptPath() << "import_raw_session_log" << QJsonDocument(data).toJson(QJsonDocument::Compact);
        proc.start(pythonPath(), args);
        proc.waitForFinished(3000);
    }

    mFullStatusText = tr("Session restored from JSON.");
    mStatusBtn->setText(mFullStatusText);
}

void AiAssistWidget::onDocumentSaved(Document* doc) {
    if (!doc) return;
    QString fp = doc->filePath();
    if (!fp.isEmpty()) {
        saveSessionFor(fp);
    }
}

void AiAssistWidget::onDocumentShown(Document* doc, int pos, int selLen) {
    Q_UNUSED(pos);
    Q_UNUSED(selLen);
    if (!doc) return;
    
    QString fp = doc->filePath();
    if (fp.isEmpty()) return;

    if (!doc->property("ai_prompt_shown").toBool()) {
        doc->setProperty("ai_prompt_shown", true);
        
        QString jsonPath = sessionFilePath(fp);
        if (QFileInfo::exists(jsonPath)) {
            QMessageBox::StandardButton res = QMessageBox::question(this, tr("AI Session Found"),
                tr("An AI session sidecar file was found for this document.\nWould you like to import it?"),
                QMessageBox::Yes | QMessageBox::No);
                
            if (res == QMessageBox::Yes) {
                QString fileName = QFileDialog::getOpenFileName(this,
                    tr("Import AI Session"), QFileInfo(jsonPath).absolutePath(), tr("AI Session Files (*.ai-session.json)"));
                
                if (!fileName.isEmpty()) {
                    restoreSessionFor(fileName);
                }
            }
        }
    }
}

void AiAssistWidget::onImportSessionClicked() {
    Document* doc = Main::instance()->documentManager()->activeDocument();
    QString defaultDir = QDir::homePath();
    if (doc && !doc->filePath().isEmpty()) {
        defaultDir = QFileInfo(doc->filePath()).absolutePath();
    }

    QString fileName = QFileDialog::getOpenFileName(this,
        tr("Import AI Session"), defaultDir, tr("AI Session Files (*.ai-session.json)"));

    if (fileName.isEmpty()) return;

    QMessageBox::StandardButton res = QMessageBox::question(this, tr("Import Session"),
        tr("Would you like to import this session data into the current editor state?"),
        QMessageBox::Yes | QMessageBox::No);
    
    if (res == QMessageBox::Yes) {
        restoreSessionFor(fileName);
    }
}

void AiAssistWidget::onDocumentClosed(Document* doc) {
    if (!doc) return;
    QString fp = doc->filePath();
    
    // If the document is unsaved (no file path) and we have session content, warn the user
    if (fp.isEmpty() && hasSessionContent()) {
        QMessageBox::warning(this, tr("AI Session Lost"),
            tr("The AI session data (prompts, plan, composition state) for this unsaved file has been lost.\n\n"
               "To preserve AI session data, save the file before closing it."));
    }
}

void AiAssistWidget::createTabs() {
    // Tab 0: Post Window (the original)
    mTabWidget->addTab(mPostWindow, tr("Post"));

    // Tab 1: Generate
    mTabWidget->addTab(createGenerateTab(), tr("Generate"));

    // Tab 2: Design (MIDI)
    mTabWidget->addTab(createDesignTab(), tr("Design"));

    // Tab 3: Append
    mTabWidget->addTab(createAppendTab(), tr("Append"));

    // Tab 3: Fix
    mTabWidget->addTab(createFixTab(), tr("Fix"));

    // Tab 4: Remake
    mTabWidget->addTab(createRemakeTab(), tr("Remake"));

    // Tab 5: Learn -> Ask
    mTabWidget->addTab(createLearnTab(), tr("Ask"));

    // Tab 6: Add to KB
    mTabWidget->addTab(createAddKbTab(), tr("Add to KB"));
}

QWidget* AiAssistWidget::createGenerateTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Composition prompt:")));
    mGenPrompt = new QPlainTextEdit;
    mGenPrompt->setPlaceholderText(tr("Describe what you want to compose..."));
    mGenPrompt->setMaximumHeight(80);
    layout->addWidget(mGenPrompt);

    QHBoxLayout* planRow = new QHBoxLayout;
    mGenUseKb = new QCheckBox(tr("Use knowledge base"));
    mGenUseKb->setChecked(true);
    planRow->addWidget(mGenUseKb);
    
    mGenIncludeEnding = new QCheckBox(tr("Include Ending"));
    mGenIncludeEnding->setChecked(true); // Default to ending piece
    planRow->addWidget(mGenIncludeEnding);

    planRow->addStretch();
    mSystemMsgBtnGen = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnGen, &QPushButton::clicked, this, &AiAssistWidget::onGenSysClicked);
    planRow->addWidget(mSystemMsgBtnGen);
    
    mGenPlanBtn = new QPushButton(tr("Plan"));
    connect(mGenPlanBtn, &QPushButton::clicked, this, &AiAssistWidget::onPlanClicked);
    planRow->addWidget(mGenPlanBtn);
    layout->addLayout(planRow);

    layout->addWidget(new QLabel(tr("Composition plan (editable):")));
    mGenPlanOutput = new QPlainTextEdit;
    mGenPlanOutput->setPlaceholderText(tr("Plan will appear here after clicking Plan..."));
    layout->addWidget(mGenPlanOutput, 1);

    mGenGenerateBtn = new QPushButton(tr("Generate"));
    connect(mGenGenerateBtn, &QPushButton::clicked, this, &AiAssistWidget::onGenerateClicked);
    layout->addWidget(mGenGenerateBtn);

    return tab;
}

QWidget* AiAssistWidget::createDesignTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Design prompt:")));
    mDesignPrompt = new QPlainTextEdit;
    mDesignPrompt->setPlaceholderText(tr("Describe the MIDI synthesizer you want to design..."));
    mDesignPrompt->setMaximumHeight(80);
    layout->addWidget(mDesignPrompt);

    QHBoxLayout* planRow = new QHBoxLayout;
    mDesignUseKb = new QCheckBox(tr("Use knowledge base"));
    mDesignUseKb->setChecked(true);
    planRow->addWidget(mDesignUseKb);
    
    planRow->addStretch();
    mSystemMsgBtnDesign = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnDesign, &QPushButton::clicked, this, &AiAssistWidget::onDesignSysClicked);
    planRow->addWidget(mSystemMsgBtnDesign);
    
    mDesignPlanBtn = new QPushButton(tr("Plan"));
    connect(mDesignPlanBtn, &QPushButton::clicked, this, &AiAssistWidget::onDesignPlanClicked);
    planRow->addWidget(mDesignPlanBtn);
    layout->addLayout(planRow);

    layout->addWidget(new QLabel(tr("Design plan (editable):")));
    mDesignPlanOutput = new QPlainTextEdit;
    mDesignPlanOutput->setPlaceholderText(tr("Plan will appear here after clicking Plan..."));
    layout->addWidget(mDesignPlanOutput, 1);

    mDesignGenerateBtn = new QPushButton(tr("Design"));
    connect(mDesignGenerateBtn, &QPushButton::clicked, this, &AiAssistWidget::onDesignGenerateClicked);
    layout->addWidget(mDesignGenerateBtn);

    return tab;
}

QWidget* AiAssistWidget::createAppendTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("What should be added to the composition?")));
    mAppendPrompt = new QPlainTextEdit;
    mAppendPrompt->setPlaceholderText(tr("Describe the new element..."));
    layout->addWidget(mAppendPrompt, 1);

    QHBoxLayout* btnRow = new QHBoxLayout;
    mAutoExecuteCheck = new QCheckBox(tr("Auto-Execute"));
    mAutoExecuteCheck->setToolTip(tr("Automatically evaluate externally modified files"));
    connect(mAutoExecuteCheck, &QCheckBox::toggled, this, &AiAssistWidget::onAutoExecuteToggled);
    // Sync with current state
    mAutoExecuteCheck->setChecked(Main::instance()->documentManager()->isAutoEvaluateEnabled());
    btnRow->addWidget(mAutoExecuteCheck);
    
    mAppendUseCodeContext = new QCheckBox(tr("Use code as context"));
    btnRow->addWidget(mAppendUseCodeContext);
    
    btnRow->addStretch();
    mSystemMsgBtnApp = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnApp, &QPushButton::clicked, this, &AiAssistWidget::onAppSysClicked);
    btnRow->addWidget(mSystemMsgBtnApp);

    mAppendBtn = new QPushButton(tr("Append"));
    connect(mAppendBtn, &QPushButton::clicked, this, &AiAssistWidget::onAppendClicked);
    btnRow->addWidget(mAppendBtn);
    layout->addLayout(btnRow);

    return tab;
}

QWidget* AiAssistWidget::createFixTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Latest run code block:")));
    mFixBlock = new QPlainTextEdit;
    mFixBlock->setPlaceholderText(tr("(auto-populated when you evaluate code)"));
    layout->addWidget(mFixBlock, 1);

    layout->addWidget(new QLabel(tr("Stack trace / error:")));
    mFixStackTrace = new QPlainTextEdit;
    mFixStackTrace->setReadOnly(true);
    mFixStackTrace->setPlaceholderText(tr("(auto-populated from post window errors)"));
    layout->addWidget(mFixStackTrace, 1);

    QHBoxLayout* btnRow = new QHBoxLayout;
    btnRow->addStretch();
    mSystemMsgBtnFix = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnFix, &QPushButton::clicked, this, &AiAssistWidget::onFixSysClicked);
    btnRow->addWidget(mSystemMsgBtnFix);

    mFixBtn = new QPushButton(tr("Fix"));
    connect(mFixBtn, &QPushButton::clicked, this, &AiAssistWidget::onFixClicked);
    btnRow->addWidget(mFixBtn);
    layout->addLayout(btnRow);

    return tab;
}

QWidget* AiAssistWidget::createRemakeTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Latest run code block:")));
    mRemakeBlock = new QPlainTextEdit;
    mRemakeBlock->setPlaceholderText(tr("(auto-populated when you evaluate code)"));
    layout->addWidget(mRemakeBlock, 1);

    layout->addWidget(new QLabel(tr("How should this be changed?")));
    mRemakePrompt = new QPlainTextEdit;
    mRemakePrompt->setPlaceholderText(tr("Describe the aesthetic changes..."));
    mRemakePrompt->setMaximumHeight(80);
    layout->addWidget(mRemakePrompt);

    QHBoxLayout* btnRow = new QHBoxLayout;
    btnRow->addStretch();
    mSystemMsgBtnRem = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnRem, &QPushButton::clicked, this, &AiAssistWidget::onRemSysClicked);
    btnRow->addWidget(mSystemMsgBtnRem);

    mRemakeBtn = new QPushButton(tr("Send"));
    connect(mRemakeBtn, &QPushButton::clicked, this, &AiAssistWidget::onRemakeClicked);
    btnRow->addWidget(mRemakeBtn);
    layout->addLayout(btnRow);

    return tab;
}

QWidget* AiAssistWidget::createLearnTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Chat:")));
    mLearnHistory = new QPlainTextEdit;
    mLearnHistory->setReadOnly(true);
    mLearnHistory->setPlaceholderText(tr("Ask questions about SuperCollider..."));
    layout->addWidget(mLearnHistory, 1);

    QHBoxLayout* inputRow = new QHBoxLayout;
    mLearnPrompt = new QLineEdit;
    mLearnPrompt->setPlaceholderText(tr("Type your question..."));
    connect(mLearnPrompt, &QLineEdit::returnPressed, this, &AiAssistWidget::onLearnSendClicked);
    inputRow->addWidget(mLearnPrompt);
    
    mSystemMsgBtnLearn = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnLearn, &QPushButton::clicked, this, &AiAssistWidget::onLearnSysClicked);
    inputRow->addWidget(mSystemMsgBtnLearn);

    mLearnSendBtn = new QPushButton(tr("Send"));
    connect(mLearnSendBtn, &QPushButton::clicked, this, &AiAssistWidget::onLearnSendClicked);
    inputRow->addWidget(mLearnSendBtn);
    layout->addLayout(inputRow);

    return tab;
}

QWidget* AiAssistWidget::createAddKbTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Latest run code block:")));
    mKbBlock = new QPlainTextEdit;
    mKbBlock->setPlaceholderText(tr("(auto-populated when you evaluate code)"));
    layout->addWidget(mKbBlock, 1);

    layout->addWidget(new QLabel(tr("Description:")));
    mKbDescription = new QPlainTextEdit;
    mKbDescription->setPlaceholderText(tr("Describe this code block..."));
    mKbDescription->setMaximumHeight(80);
    layout->addWidget(mKbDescription);

    QHBoxLayout* btnRow = new QHBoxLayout;
    mKbAddBtn = new QPushButton(tr("Add"));
    connect(mKbAddBtn, &QPushButton::clicked, this, &AiAssistWidget::onAddKbClicked);
    btnRow->addWidget(mKbAddBtn);
    mKbConsumeBtn = new QPushButton(tr("Consume KB"));
    connect(mKbConsumeBtn, &QPushButton::clicked, this, &AiAssistWidget::onConsumeKbClicked);
    btnRow->addWidget(mKbConsumeBtn);
    
    QPushButton* editBtn = new QPushButton(tr("Edit KB Sources"));
    connect(editBtn, &QPushButton::clicked, this, &AiAssistWidget::onKbSourceEditClicked);
    btnRow->addWidget(editBtn);
    
    btnRow->addStretch();
    layout->addLayout(btnRow);

    return tab;
}

// --- State updates ---

void AiAssistWidget::setLastEvaluatedCode(const QString& code) {
    mLastEvaluatedCode = code;
    mLastStackTrace.clear(); // Clear previous error when new code is evaluated
    updateLatestBlockFields();
}

void AiAssistWidget::onPostWindowText(const QString& text) {
    // Detect error patterns in post window output
    if (text.contains("ERROR:", Qt::CaseInsensitive)
        || text.contains("Exception", Qt::CaseSensitive)
        || text.contains("syntax error", Qt::CaseInsensitive)
        || text.startsWith("!")) {
        // Accumulate error text
        if (mLastStackTrace.length() > 4000)
            mLastStackTrace.clear(); // Prevent unbounded growth
        mLastStackTrace += text;
        updateLatestBlockFields();
    }
}

void AiAssistWidget::updateLatestBlockFields() {
    // Update all read-only "latest block" fields across tabs
    mFixBlock->setPlainText(mLastEvaluatedCode);
    mFixStackTrace->setPlainText(mLastStackTrace);
    mRemakeBlock->setPlainText(mLastEvaluatedCode);
    mKbBlock->setPlainText(mLastEvaluatedCode);
}

// --- Process management ---

QString AiAssistWidget::pythonPath() const {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    
    // Windows venv
    QString venvWin = scriptDir.filePath(".venv/Scripts/python.exe");
    if (QFileInfo::exists(venvWin)) return venvWin;
    
    // Unix venv
    QString venvUnix = scriptDir.filePath(".venv/bin/python");
    if (QFileInfo::exists(venvUnix)) return venvUnix;
    
    // Fallback
    return "python";
}

QString AiAssistWidget::backendScriptPath() const {
    QDir current(QApplication::applicationDirPath());
    // Walk up the directory tree up to 6 levels to find sc-gen-rag
    for (int i = 0; i < 6; ++i) {
        QString testPath = current.filePath("sc-gen-rag/gui_backend.py");
        if (QFileInfo::exists(testPath))
            return QFileInfo(testPath).absoluteFilePath();
        current.cdUp();
    }
    // Last resort: assume it's in the working directory
    return "gui_backend.py";
}

void AiAssistWidget::setProcessingState(bool processing) {
    if (processing) {
        mFullStatusText = tr("Processing...");
        mStatusBtn->setText(mFullStatusText);
    } else {
        mFullStatusText.clear();
        mStatusBtn->setText("");
    }
    // Disable all buttons during processing
    mGenPlanBtn->setEnabled(!processing);
    mGenGenerateBtn->setEnabled(!processing);
    mAppendBtn->setEnabled(!processing);
    mFixBtn->setEnabled(!processing);
    mRemakeBtn->setEnabled(!processing);
    mLearnSendBtn->setEnabled(!processing);
    mKbAddBtn->setEnabled(!processing);
    mKbConsumeBtn->setEnabled(!processing);
}

QJsonObject AiAssistWidget::basePayload() const {
    QJsonObject data;
    Document* doc = Main::instance()->documentManager()->activeDocument();
    if (doc) {
        data["active_file"] = doc->filePath();
    }
    data["model"] = mModelCombo->currentText();
    data["temperature"] = mTempSlider->value() / 10.0;
    return data;
}

void AiAssistWidget::runBackendCommand(const QString& command, const QJsonObject& data,
                                       std::function<void(const QJsonObject&)> callback) {
    if (mCurrentProcess) {
        QMessageBox::warning(this, tr("Busy"), tr("A command is already running. Please wait."));
        return;
    }

    // Merge active file if not present
    Document* doc = Main::instance()->documentManager()->activeDocument();
    QJsonObject finalData = data;
    if (doc && !finalData.contains("active_file")) {
        finalData["active_file"] = doc->filePath();
    }

    // Write input data to a temp file
    QTemporaryFile* tempFile = new QTemporaryFile(QDir::tempPath() + "/sc-ai-XXXXXX.json");
    tempFile->setAutoRemove(true);
    if (!tempFile->open()) {
        QMessageBox::critical(this, tr("Error"), tr("Failed to create temporary file."));
        delete tempFile;
        return;
    }

    QJsonDocument jsonDoc(finalData);
    tempFile->write(jsonDoc.toJson(QJsonDocument::Compact));
    QString tempPath = tempFile->fileName();
    tempFile->close();

    mCurrentCallback = callback;
    mCurrentProcess = new QProcess(this);
    mCurrentOutput.clear();
    mCurrentErrorOutput.clear();

    // Set working directory to the sc-gen-rag folder
    QString scriptPath = backendScriptPath();
    mCurrentProcess->setWorkingDirectory(QFileInfo(scriptPath).absolutePath());

    connect(mCurrentProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &AiAssistWidget::onProcessFinished);

    connect(mCurrentProcess, &QProcess::readyReadStandardError, this, [this]() {
        if (!mCurrentProcess) return;
        QByteArray err = mCurrentProcess->readAllStandardError();
        mCurrentErrorOutput.append(err);
        QString text = QString::fromUtf8(err).trimmed();
        if (!text.isEmpty()) {
            QStringList lines = text.split('\n', Qt::SkipEmptyParts);
            if (!lines.isEmpty()) {
                QString statusText = lines.last().trimmed();
                if (statusText.length() > 60) {
                    statusText = statusText.left(60) + "...";
                }
                QString truncated = statusText.left(30);
                if (statusText.length() > 30) truncated += "...";
                mFullStatusText = statusText;
                mStatusBtn->setText(truncated);
            }
        }
    });

    connect(mCurrentProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        if (!mCurrentProcess) return;
        mCurrentOutput.append(mCurrentProcess->readAllStandardOutput());
    });

    // Clean up temp file when process finishes
    connect(mCurrentProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            tempFile, &QTemporaryFile::deleteLater);

    setProcessingState(true);

    QStringList args;
    args << scriptPath << command << tempPath;
    mCurrentProcess->start(pythonPath(), args);
}

void AiAssistWidget::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    setProcessingState(false);

    if (!mCurrentProcess)
        return;

    QByteArray output = mCurrentOutput;
    QByteArray errOutput = mCurrentErrorOutput;

    mCurrentProcess->deleteLater();
    mCurrentProcess = nullptr;

    if (exitStatus != QProcess::NormalExit || exitCode != 0) {
        QString errorMsg = QString::fromUtf8(errOutput);
        
        // Try parsing JSON output from stdout to see if there is a clean traceback
        QJsonDocument errDoc = QJsonDocument::fromJson(output);
        if (!errDoc.isNull() && errDoc.isObject() && errDoc.object().contains("error")) {
            QString pyErr = errDoc.object()["error"].toString();
            QString trace = errDoc.object()["traceback"].toString();
            errorMsg = pyErr + "\n\n" + trace;
        } else if (errorMsg.isEmpty()) {
            errorMsg = QString::fromUtf8(output);
        }
        
        QMessageBox::warning(this, tr("Backend Error"),
                            tr("Command failed:\n%1").arg(errorMsg.left(800)));
        return;
    }

    // Parse JSON response
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(output, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        QMessageBox::warning(this, tr("Parse Error"),
                            tr("Failed to parse backend response:\n%1\n\nRaw output:\n%2")
                            .arg(parseError.errorString())
                            .arg(QString::fromUtf8(output).left(300)));
        return;
    }

    QJsonObject result = doc.object();

    // Check for error in response
    if (result.contains("error")) {
        QMessageBox::warning(this, tr("Backend Error"),
                            tr("Error: %1").arg(result["error"].toString()));
        return;
    }

    // Call the callback with the result
    if (mCurrentCallback)
        mCurrentCallback(result);
        
    // Look for performance stats appended to the JSON output
    if (result.contains("last_stats")) {
        QJsonObject stats = result["last_stats"].toObject();
        double time_s = stats["time_s"].toDouble();
        double cost = stats["cost"].toDouble();
        double ctx_usage = stats["context_usage_pct"].toDouble();
        
        QString statusMsg = tr("Done: %1s — $%2").arg(time_s).arg(cost, 0, 'f', 5);
        mFullStatusText = statusMsg;
        if (statusMsg.length() > 25) statusMsg = statusMsg.left(25) + "...";
        mStatusBtn->setText(statusMsg);
        
        // Automatically fetch new aggregated session stats to update top button
        tryUpdateSessionStats();
    }
}

// --- Session Stats Handlers ---

void AiAssistWidget::tryUpdateSessionStats() {
    QJsonObject data = basePayload();
    QProcess* proc = new QProcess(this);
    proc->setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    
    QStringList args;
    args << backendScriptPath() << "get_session_stats" << QJsonDocument(data).toJson(QJsonDocument::Compact);
    
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [this, proc](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            QByteArray output = proc->readAllStandardOutput();
            QJsonDocument doc = QJsonDocument::fromJson(output);
            if (!doc.isNull() && doc.isObject()) {
                QJsonObject result = doc.object();
                if (result.contains("session_stats")) {
                    QJsonObject stats = result["session_stats"].toObject();
                    
                    QString costStr = QString::number(stats["total_cost"].toDouble(), 'f', 2);
                    if (stats["any_cost_fb"].toBool()) costStr += " (FB)";
                    mSessionStatsBtn->setText(tr("Session: $%1").arg(costStr));

                    // Eco Label — show 3 key metrics, cache all 5 for the detail dialog
                    mEcoEnergy = stats["total_energy"].toDouble();
                    mEcoGwp = stats["total_gwp"].toDouble();
                    mEcoAdpe = stats["total_adpe"].toDouble();
                    mEcoPe = stats["total_pe"].toDouble();
                    mEcoWcf = stats["total_wcf"].toDouble();
                    mEcoFb = stats["any_eco_fb"].toBool();
                    
                    // Compact label: 3 most relevant metrics
                    QString ecoStr = tr("%1kWh | %2kgCO2 | %3L")
                        .arg(QString::number(mEcoEnergy, 'f', 4))
                        .arg(QString::number(mEcoGwp, 'f', 5))
                        .arg(QString::number(mEcoWcf, 'f', 4));
                    if (mEcoFb) ecoStr += " (FB)";
                    mEcoLabel->setText(ecoStr);

                    // Context Progress Bar - specific to the current model
                    QString currentModel = mModelCombo->currentText();
                    QJsonObject providers = stats["providers"].toObject();
                    if (providers.contains(currentModel)) {
                        QJsonObject p = providers[currentModel].toObject();
                        long inTok = p["in_tokens"].toInt();
                        long outTok = p["out_tokens"].toInt();
                        long totalTok = inTok + outTok;
                        long limit = p["context_limit"].toInt();
                        if (limit > 0) {
                            int pct = (int)((double)totalTok / limit * 100.0);
                            // Clamp to 100 for the progress bar display
                            mContextBar->setValue(qMin(pct, 100));
                            mContextLabel->setText(tr("Ctx: %1k").arg(totalTok / 1000));

                            if (pct >= 100) {
                                // Warning: context budget exceeded
                                mContextBar->setStyleSheet(
                                    "QProgressBar { background-color: #2c3e50; border: none; border-radius: 4px; } "
                                    "QProgressBar::chunk { background-color: #e74c3c; border-radius: 4px; }");
                                mContextLabel->setStyleSheet("color: #e74c3c; font-weight: bold;");
                                mContextLabel->setToolTip(tr(
                                    "\u26a0 Context budget exceeded (%1%%).\n"
                                    "Total tokens (%2) surpass this model's context window (%3).\n\n"
                                    "Each API call is independent so generation will still work,\n"
                                    "but individual prompts approaching the limit may cause\n"
                                    "the model to lose coherence, truncate output, or refuse to generate.\n\n"
                                    "Consider starting a new session or switching models.")
                                    .arg(pct).arg(totalTok).arg(limit));
                            } else if (pct >= 80) {
                                // Approaching limit
                                mContextBar->setStyleSheet(
                                    "QProgressBar { background-color: #2c3e50; border: none; border-radius: 4px; } "
                                    "QProgressBar::chunk { background-color: #f39c12; border-radius: 4px; }");
                                mContextLabel->setStyleSheet("color: #f39c12;");
                                mContextLabel->setToolTip(tr("%1 / %2 tokens used (%3%%)").arg(totalTok).arg(limit).arg(pct));
                            } else {
                                // Normal
                                mContextBar->setStyleSheet(
                                    "QProgressBar { background-color: #2c3e50; border: none; border-radius: 4px; } "
                                    "QProgressBar::chunk { background-color: #3498db; border-radius: 4px; }");
                                mContextLabel->setStyleSheet("color: #7f8c8d;");
                                mContextLabel->setToolTip(tr("%1 / %2 tokens used (%3%%)").arg(totalTok).arg(limit).arg(pct));
                            }
                        }
                    } else {
                        mContextBar->setValue(0);
                        mContextLabel->setText(tr("Ctx: 0k"));
                    }

                    // Total Wait Time
                    double totalTime = stats["total_time"].toDouble();
                    mTotalWaitLabel->setText(tr("Wait: %1s").arg(QString::number(totalTime, 'f', 1)));
                }
            }
        }
        proc->deleteLater();
    });
    
    proc->start(pythonPath(), args);
}

void AiAssistWidget::onSessionStatsClicked() {
    QJsonObject data = basePayload();
    QProcess proc;
    proc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList args;
    args << backendScriptPath() << "get_session_stats" << QJsonDocument(data).toJson(QJsonDocument::Compact);
    proc.start(pythonPath(), args);
    proc.waitForFinished(5000);

    QByteArray output = proc.readAllStandardOutput();
    QJsonDocument doc = QJsonDocument::fromJson(output);
    if (doc.isNull() || !doc.isObject()) {
        QMessageBox::information(this, tr("Session Stats"), tr("No stats data available yet."));
        return;
    }

    QJsonObject result = doc.object();
    QJsonObject stats = result["session_stats"].toObject();
    
    if (stats.isEmpty() || !stats.contains("providers") || stats["providers"].toObject().isEmpty()) {
        QMessageBox::information(this, tr("Session Stats"), tr("No stats measured in this session yet."));
        return;
    }

    double total_cost = stats["total_cost"].toDouble();
    bool any_cost_fb = stats["any_cost_fb"].toBool();
    double total_time = stats["total_time"].toDouble();
    double total_energy = stats["total_energy"].toDouble();
    QJsonObject providers = stats["providers"].toObject();

    Document* activeDoc = Main::instance()->documentManager()->activeDocument();
    QString fileName = activeDoc ? QFileInfo(activeDoc->filePath()).fileName() : tr("Unknown File");

    QString html = "<html><body style='font-family: Segoe UI, sans-serif; font-size: 10pt; color: #e0e0e0; background: #1a1a1a;'>";
    html += QString("<h2 style='color: #6db3f2;'>AI Session Analytics — %1</h2>").arg(fileName);
    
    QString totalCostStr = QString::number(total_cost, 'f', 5);
    if (any_cost_fb) totalCostStr += " (FB)";

    html += QString("<div style='margin-bottom: 20px; font-size: 11pt; border-bottom: 2px solid #555; padding-bottom: 10px;'>"
                    "<b>Total Accumulative Cost:</b> <span style='color: #a5d6a7;'>$%1</span><br>"
                    "<b>Total Compute Wait Time:</b> <span style='color: #ffcc80;'>%2s</span><br>"
                    "<b>Total Energy Consumed:</b> <span style='color: #81c784;'>%3 kWh</span></div>")
                    .arg(totalCostStr).arg(total_time, 0, 'f', 2).arg(total_energy, 0, 'f', 6);

    QStringList keys = providers.keys();
    for (const QString& providerKey : keys) {
        QJsonObject pStats = providers[providerKey].toObject();
        int calls = pStats["calls"].toInt();
        double pCost = pStats["cost"].toDouble();
        bool pCostFb = pStats["cost_fb"].toBool();
        double pTime = pStats["time"].toDouble();
        int inT = pStats["in_tokens"].toInt();
        int outT = pStats["out_tokens"].toInt();
        double pEnergy = pStats["energy_kwh"].toDouble();
        double pGwp = pStats["gwp_kg"].toDouble();
        int pCtx = pStats["context_limit"].toInt();
        bool pCtxFb = pStats["context_fb"].toBool();

        QString pCostStr = QString::number(pCost, 'f', 5);
        if (pCostFb) pCostStr += " (FB)";
        QString pCtxStr = QString::number(pCtx);
        if (pCtxFb) pCtxStr += " (FB)";

        html += QString(
            "<div style='margin-bottom: 16px; padding: 12px; border: 1px solid #444; border-radius: 6px; background: #2a2a2a;'>"
            "<div style='color: #6db3f2; font-weight: bold; font-size: 11pt; margin-bottom: 6px;'>%1</div>"
            "<table style='color: #e0e0e0; width: 100%; border-collapse: collapse; font-size: 9pt;'>"
            "<tr><td style='width: 35%; color: #aaa;'>Generations:</td><td>%2</td></tr>"
            "<tr><td style='width: 35%; color: #aaa;'>Tokens I/O | Limit:</td><td>%3 / %4 | <b>%5</b></td></tr>"
            "<tr><td style='width: 35%; color: #aaa;'>Compute Time:</td><td><b>%6s</b></td></tr>"
            "<tr><td style='width: 35%; color: #aaa;'>Energy | Carbon:</td><td>%7 kWh | %8 kgCO2eq</td></tr>"
            "<tr><td style='width: 35%; color: #aaa;'>Estimated Cost:</td><td style='color: #a5d6a7;'><b>$%9</b></td></tr>"
            "</table></div>"
        ).arg(providerKey).arg(calls).arg(inT).arg(outT).arg(pCtxStr).arg(pTime, 0, 'f', 2)
         .arg(pEnergy, 0, 'f', 6).arg(pGwp, 0, 'f', 6).arg(pCostStr);
    }

    QDialog dialog(this);
    dialog.setWindowTitle(tr("AI Session Analytics Report"));
    dialog.setMinimumSize(600, 500);
    QVBoxLayout* layout = new QVBoxLayout(&dialog);
    QTextBrowser* view = new QTextBrowser;
    view->setHtml(html);
    layout->addWidget(view);
    
    QPushButton* closeBtn = new QPushButton(tr("Close"));
    connect(closeBtn, &QPushButton::clicked, &dialog, &QDialog::accept);
    layout->addWidget(closeBtn);
    
    dialog.exec();
}

void AiAssistWidget::onSustainabilityClicked() {
    QDialog dialog(this);
    dialog.setWindowTitle(tr("Environmental Impact — Session Details"));
    dialog.resize(540, 560);
    QVBoxLayout* layout = new QVBoxLayout(&dialog);

    QTextBrowser* browser = new QTextBrowser;
    QString html = "<html><body style='font-family: Segoe UI, sans-serif; font-size: 10pt; color: #e0e0e0; background: #1a1a1a;'>";

    // --- Current session measurements ---
    html += "<h2 style='color: #27ae60;'>Session Measurements</h2>";
    
    QString fbNote = mEcoFb 
        ? "<span style='color: #f39c12;'>(FB) Some values are fallback estimates</span>" 
        : "<span style='color: #27ae60;'>All values measured by EcoLogits</span>";
    html += "<p>" + fbNote + "</p>";

    html += "<table style='width: 100%; border-collapse: collapse; margin-bottom: 16px;'>"
            "<tr style='border-bottom: 1px solid #333;'>"
            "<th style='text-align: left; padding: 6px; color: #aaa;'>Metric</th>"
            "<th style='text-align: right; padding: 6px; color: #aaa;'>Value</th>"
            "<th style='text-align: left; padding: 6px; color: #aaa;'>Unit</th></tr>";

    auto addRow = [&](const QString& color, const QString& name, double value, const QString& unit) {
        html += QString("<tr>"
            "<td style='padding: 6px; border-left: 3px solid %1;'><b>%2</b></td>"
            "<td style='text-align: right; padding: 6px; font-family: Consolas, monospace;'>%3</td>"
            "<td style='padding: 6px; color: #999;'>%4</td></tr>")
            .arg(color, name, QString::number(value, 'e', 4), unit);
    };

    addRow("#27ae60", "Energy",  mEcoEnergy, "kWh");
    addRow("#f39c12", "GWP",     mEcoGwp,    "kgCO2eq");
    addRow("#9b59b6", "ADPe",    mEcoAdpe,   "kgSbeq");
    addRow("#e74c3c", "PE",      mEcoPe,     "MJ");
    addRow("#3498db", "WCF",     mEcoWcf,    "L");

    html += "</table>";

    // --- Glossary ---
    html += "<hr style='border-color: #333;'/>";
    html += "<h2 style='color: #27ae60;'>Metric Definitions</h2>";
    
    html += "<div style='margin-bottom: 12px; padding: 10px; background-color: #252525; border-left: 4px solid #27ae60;'>"
            "<b>Energy Consumption (kWh)</b><br/>"
            "<span style='font-size: 9pt; color: #ccc;'>Electricity used by the servers during model inference. "
            "Higher complexity models or longer prompts increase this value.</span></div>";

    html += "<div style='margin-bottom: 12px; padding: 10px; background-color: #252525; border-left: 4px solid #f39c12;'>"
            "<b>GWP — Global Warming Potential (kgCO2eq)</b><br/>"
            "<span style='font-size: 9pt; color: #ccc;'>Carbon footprint including greenhouse gas emissions "
            "from the energy used and the embodied impact of hardware.</span></div>";

    html += "<div style='margin-bottom: 12px; padding: 10px; background-color: #252525; border-left: 4px solid #9b59b6;'>" 
            "<b>ADPe — Abiotic Depletion Potential (kgSbeq)</b><br/>"
            "<span style='font-size: 9pt; color: #ccc;'>Depletion of rare minerals and metals (cobalt, lithium, etc.) "
            "used in manufacturing GPUs and server hardware.</span></div>";

    html += "<div style='margin-bottom: 12px; padding: 10px; background-color: #252525; border-left: 4px solid #e74c3c;'>" 
            "<b>PE — Primary Energy (MJ)</b><br/>"
            "<span style='font-size: 9pt; color: #ccc;'>Total energy from all sources including renewable and non-renewable. "
            "Broader than Energy (kWh) as it includes supply chain conversion losses.</span></div>";

    html += "<div style='margin-bottom: 12px; padding: 10px; background-color: #252525; border-left: 4px solid #3498db;'>"
            "<b>WCF — Water Consumption Footprint (L)</b><br/>"
            "<span style='font-size: 9pt; color: #ccc;'>Freshwater used for cooling data centers and "
            "in the production of the electricity consumed.</span></div>";

    html += "<hr style='border-color: #333;'/>";
    html += "<p style='font-size: 8.5pt; color: #7f8c8d;'><i>Metrics powered by EcoLogits v0.10+ with google-genai, openai, and anthropic providers.<br/>"
            "Values for Gemini are approximate (model architecture not publicly released).</i></p>";
    html += "</body></html>";

    browser->setHtml(html);
    layout->addWidget(browser);
    
    QPushButton* closeBtn = new QPushButton(tr("Close"));
    connect(closeBtn, &QPushButton::clicked, &dialog, &QDialog::accept);
    layout->addWidget(closeBtn);
    
    dialog.exec();
}

void AiAssistWidget::onStatusClicked() {
    if (!mFullStatusText.isEmpty()) {
        QMessageBox::information(this, tr("Status Detail"), mFullStatusText);
    }
}

// --- Auto-Execute ---

void AiAssistWidget::onAutoExecuteToggled(bool checked) {
    if (checked) {
        QMessageBox::warning(this, tr("Warning"),
                            tr("This will make SuperCollider automatically evaluate new lines added to the file. This should be used carefully."));
    }
    Main::instance()->documentManager()->setAutoEvaluateEnabled(checked);
}

// --- Generate tab handlers ---

void AiAssistWidget::onPlanClicked() {
    QString prompt = mGenPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    QJsonObject data;
    data["prompt"] = prompt;
    data["use_kb"] = mGenUseKb->isChecked();
    data["include_ending"] = mGenIncludeEnding->isChecked();
    data["model"] = mModelCombo->currentText();

    runBackendCommand("generate_plan", data, [this](const QJsonObject& result) {
        mGenPlanOutput->setPlainText(result["plan"].toString());
    });
}

void AiAssistWidget::onGenerateClicked() {
    QString plan = mGenPlanOutput->toPlainText().trimmed();
    if (plan.isEmpty()) return;

    QJsonObject data;
    data["plan"] = plan;
    data["prompt"] = mGenPrompt->toPlainText().trimmed();
    data["use_kb"] = mGenUseKb->isChecked();
    data["include_ending"] = mGenIncludeEnding->isChecked();
    data["model"] = mModelCombo->currentText();

    runBackendCommand("generate_code", data, [this](const QJsonObject& result) {
        // Insert generated code into the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                cursor.insertText("\n\n" + code);
            }
        }
        mFullStatusText = tr("Code generated and written");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Design tab handlers ---

void AiAssistWidget::onDesignPlanClicked() {
    QString prompt = mDesignPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    QJsonObject data;
    data["prompt"] = prompt;
    data["use_kb"] = mDesignUseKb->isChecked();
    data["model"] = mModelCombo->currentText();
    data["mode"] = "design";

    runBackendCommand("generate_plan", data, [this](const QJsonObject& result) {
        mDesignPlanOutput->setPlainText(result["plan"].toString());
    });
}

void AiAssistWidget::onDesignGenerateClicked() {
    QString plan = mDesignPlanOutput->toPlainText().trimmed();
    if (plan.isEmpty()) return;

    QJsonObject data;
    data["plan"] = plan;
    data["prompt"] = mDesignPrompt->toPlainText().trimmed();
    data["use_kb"] = mDesignUseKb->isChecked();
    data["model"] = mModelCombo->currentText();
    data["mode"] = "design";

    runBackendCommand("generate_code", data, [this](const QJsonObject& result) {
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                cursor.insertText("\n\n" + code);
            }
        }
        mFullStatusText = tr("Design generated and written");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Append tab handler ---

void AiAssistWidget::onAppendClicked() {
    QString prompt = mAppendPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    QJsonObject data;
    data["prompt"] = prompt;
    data["composition_state"] = mCompositionState;
    data["use_code_context"] = mAppendUseCodeContext->isChecked();
    data["model"] = mModelCombo->currentText();

    runBackendCommand("append", data, [this](const QJsonObject& result) {
        // Insert appended code into the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                cursor.insertText("\n\n" + code);
            }
        }
        // Update composition state
        if (result.contains("new_composition_state"))
            mCompositionState = result["new_composition_state"].toString();
        mAppendPrompt->clear();
        mFullStatusText = tr("Block appended");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Fix tab handler ---

void AiAssistWidget::onFixClicked() {
    QString block = mFixBlock->toPlainText().trimmed();
    QString error = mFixStackTrace->toPlainText().trimmed();
    if (block.isEmpty()) return;

    QJsonObject data;
    data["block"] = block;
    data["error"] = error;
    data["model"] = mModelCombo->currentText();

    runBackendCommand("fix", data, [this, block](const QJsonObject& result) {
        // Replace the old block with the fixed code in the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QString docText = doc->textDocument()->toPlainText();
                if (docText.contains(block.trimmed())) {
                    docText.replace(block.trimmed(), code.trimmed());
                    QTextCursor cursor(doc->textDocument());
                    cursor.select(QTextCursor::Document);
                    cursor.insertText(docText);
                }
            }
        }
        mFullStatusText = tr("Fix applied");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Remake tab handler ---

void AiAssistWidget::onRemakeClicked() {
    QString block = mRemakeBlock->toPlainText().trimmed();
    QString prompt = mRemakePrompt->toPlainText().trimmed();
    if (block.isEmpty() || prompt.isEmpty()) return;

    QJsonObject data;
    data["block"] = block;
    data["prompt"] = prompt;
    data["model"] = mModelCombo->currentText();

    runBackendCommand("remake", data, [this, block](const QJsonObject& result) {
        // Replace the old block with the remade code in the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QString docText = doc->textDocument()->toPlainText();
                if (docText.contains(block.trimmed())) {
                    docText.replace(block.trimmed(), code.trimmed());
                    QTextCursor cursor(doc->textDocument());
                    cursor.select(QTextCursor::Document);
                    cursor.insertText(docText);
                }
            }
        }
        mRemakePrompt->clear();
        mFullStatusText = tr("Block remade");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Learn tab handler ---

void AiAssistWidget::onLearnSendClicked() {
    QString prompt = mLearnPrompt->text().trimmed();
    if (prompt.isEmpty()) return;

    // Append user message to chat history display
    mLearnChatHistory += "\n\n**You:** " + prompt;
    mLearnHistory->setPlainText(mLearnChatHistory);

    QJsonObject data;
    data["prompt"] = prompt;
    data["history"] = mLearnChatHistory;
    data["model"] = mModelCombo->currentText();

    mLearnPrompt->clear();

    runBackendCommand("learn", data, [this](const QJsonObject& result) {
        QString response = result["response"].toString();
        mLearnChatHistory += "\n\n**Assistant:** " + response;
        mLearnHistory->setPlainText(mLearnChatHistory);
        // Scroll to bottom
        QScrollBar* scrollBar = mLearnHistory->verticalScrollBar();
        scrollBar->setValue(scrollBar->maximum());
    });
}

// --- Add to KB tab handlers ---

void AiAssistWidget::onAddKbClicked() {
    QString block = mKbBlock->toPlainText().trimmed();
    QString description = mKbDescription->toPlainText().trimmed();
    if (block.isEmpty()) return;

    QJsonObject data;
    data["block"] = block;
    data["description"] = description;

    runBackendCommand("add_kb", data, [this](const QJsonObject& result) {
        mKbDescription->clear();
        mFullStatusText = tr("Added to knowledge base");
        mStatusBtn->setText(mFullStatusText);
    });
}

void AiAssistWidget::onConsumeKbClicked() {
    QJsonObject data;

    runBackendCommand("consume_kb", data, [this](const QJsonObject& result) {
        QString status = result["status"].toString();
        if (status == "error") {
            QMessageBox::warning(this, tr("KB Ingestion Error"),
                                tr("Error: %1").arg(result["error"].toString()));
        } else {
            mFullStatusText = tr("Knowledge base re-ingested");
            mStatusBtn->setText(mFullStatusText);
        }
    });
}

// --- Prompt History ---

void AiAssistWidget::onPromptHistoryClicked() {
    QJsonObject data;
    // Use a synchronous process call for immediate UI feedback
    QProcess proc;
    proc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList args;

    // Write JSON payload with active_file to temp file
    QTemporaryFile tempFile(QDir::tempPath() + "/sc-ai-XXXXXX.json");
    tempFile.setAutoRemove(true);
    if (!tempFile.open()) return;
    QJsonObject payload = basePayload();
    tempFile.write(QJsonDocument(payload).toJson(QJsonDocument::Compact));
    tempFile.close();

    args << backendScriptPath() << "get_prompt_history" << tempFile.fileName();
    proc.start(pythonPath(), args);
    proc.waitForFinished(5000);

    QByteArray output = proc.readAllStandardOutput();
    QJsonDocument doc = QJsonDocument::fromJson(output);
    if (doc.isNull() || !doc.isObject()) {
        QMessageBox::information(this, tr("Prompt History"), tr("No session data available yet."));
        return;
    }

    QJsonObject result = doc.object();
    QJsonArray entries = result["entries"].toArray();
    if (entries.isEmpty()) {
        QMessageBox::information(this, tr("Prompt History"), tr("No interactions recorded in this session yet."));
        return;
    }

    // Build a formatted HTML view
    QString html = "<html><body style='font-family: Segoe UI, sans-serif; font-size: 10pt;'>";
    html += "<h2>Session Prompt History</h2>";

    for (int i = 0; i < entries.size(); ++i) {
        QJsonObject entry = entries[i].toObject();
        QString timestamp = entry["timestamp"].toString();
        QString command = entry["command"].toString();
        QString model = entry["model"].toString();
        QString userPrompt = entry["user_prompt"].toString();
        QString response = entry["response"].toString();

        // Truncate very long fields for readability
        if (userPrompt.length() > 800)
            userPrompt = userPrompt.left(800) + "\n...";
        if (response.length() > 1200)
            response = response.left(1200) + "\n...";

        // Escape HTML
        userPrompt = userPrompt.toHtmlEscaped().replace("\n", "<br>");
        response = response.toHtmlEscaped().replace("\n", "<br>");

        html += QString(
            "<div style='margin-bottom: 16px; padding: 10px; "
            "border: 1px solid #444; border-radius: 6px; background: #2a2a2a;'>"
            "<div style='color: #aaa; font-size: 9pt;'>%1 &nbsp;|&nbsp; "
            "<span style='color: #6db3f2; font-weight: bold;'>%2</span> &nbsp;|&nbsp; %3</div>"
            "<div style='margin-top: 8px; color: #e0e0e0;'><b>Prompt:</b><br>"
            "<span style='color: #ccc;'>%4</span></div>"
            "<div style='margin-top: 8px; color: #e0e0e0;'><b>Response:</b><br>"
            "<pre style='white-space: pre-wrap; color: #b5cea8; background: #1e1e1e; "
            "padding: 6px; border-radius: 4px; font-size: 9pt;'>%5</pre></div>"
            "</div>"
        ).arg(timestamp, command, model, userPrompt, response);
    }

    html += "</body></html>";

    // Show in a dialog
    QDialog dlg(this);
    dlg.setWindowTitle(tr("Prompt History — %1 interactions").arg(entries.size()));
    dlg.resize(700, 500);
    QVBoxLayout* layout = new QVBoxLayout(&dlg);

    QTextBrowser* browser = new QTextBrowser;
    browser->setHtml(html);
    browser->setOpenExternalLinks(false);
    layout->addWidget(browser);

    QPushButton* closeBtn = new QPushButton(tr("Close"));
    connect(closeBtn, &QPushButton::clicked, &dlg, &QDialog::accept);
    layout->addWidget(closeBtn);

    dlg.exec();
}

void AiAssistWidget::handleIdeShutdown() {
    // Auto-save session state for the current file before shutdown
    Document* activeDoc = Main::instance()->documentManager()->activeDocument();
    if (activeDoc && !activeDoc->filePath().isEmpty()) {
        saveSessionFor(activeDoc->filePath());
    }

    QString backendScript = backendScriptPath();
    QString scriptDir = QFileInfo(backendScript).absolutePath();
    QString pendingPath = scriptDir + "/use-logs/.pending_fixes.json";
    bool processFixes = false;

    if (QFile::exists(pendingPath)) {
        QMessageBox::StandardButton res = QMessageBox::question(
            nullptr,
            tr("Offline Learnings pending"),
            tr("Do you want this session's fixes to be processed and incorporated into the system improvements logic?\n\n(This will run before closing.)"),
            QMessageBox::Yes | QMessageBox::No,
            QMessageBox::Yes
        );
        processFixes = (res == QMessageBox::Yes);
    }
    
    QJsonObject data;
    data["process_fixes"] = processFixes;
    QJsonDocument doc(data);
    
    QString tempPath = QDir::tempPath() + "/sc_gen_shutdown_" + QUuid::createUuid().toString(QUuid::WithoutBraces) + ".json";
    QFile tempFile(tempPath);
    if (tempFile.open(QIODevice::WriteOnly)) {
        tempFile.write(doc.toJson(QJsonDocument::Compact));
        tempFile.close();
    }
    
    QStringList args;
    args << backendScriptPath() << "save_session_log" << tempPath;
    
    QProcess proc;
    proc.setWorkingDirectory(scriptDir);
    
    if (processFixes) {
        // Show a blocking progress dialog while learnings are processed
        QProgressDialog progress(tr("Processing session learnings..."), QString(), 0, 0, nullptr);
        progress.setWindowTitle(tr("Closing — Learning"));
        progress.setWindowModality(Qt::ApplicationModal);
        progress.setCancelButton(nullptr);
        progress.setMinimumDuration(0);
        progress.show();
        QApplication::processEvents();
        
        proc.start(pythonPath(), args);
        while (!proc.waitForFinished(500)) {
            QApplication::processEvents();
        }
        progress.close();
    } else {
        QProcess::startDetached(pythonPath(), args, scriptDir);
    }
}

void AiAssistWidget::onKbSourceEditClicked() {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    QString kbDir = scriptDir.filePath("knowledge_base");
    
    QDir dir(kbDir);
    QStringList scdFiles = dir.entryList(QStringList() << "*.scd" << "*.md" << "*.txt", QDir::Files);
    
    if (scdFiles.isEmpty()) {
        QMessageBox::information(this, tr("Knowledge Base"), tr("No source files found in knowledge_base folder."));
        return;
    }
    
    QDialog dlg(this);
    dlg.setWindowTitle(tr("Knowledge Base Source Editor"));
    dlg.resize(800, 500);
    
    QHBoxLayout* mainLay = new QHBoxLayout(&dlg);
    
    // File list on the left
    QListWidget* fileList = new QListWidget;
    fileList->setFixedWidth(200);
    for (const QString& file : scdFiles) {
        fileList->addItem(file);
    }
    mainLay->addWidget(fileList);
    
    // Editor on the right
    QVBoxLayout* rightLay = new QVBoxLayout;
    QPlainTextEdit* editor = new QPlainTextEdit;
    editor->setPlaceholderText(tr("Select a file from the list to edit it."));
    rightLay->addWidget(editor);
    
    // Save button
    QPushButton* saveBtn = new QPushButton(tr("Save"));
    rightLay->addWidget(saveBtn);
    mainLay->addLayout(rightLay);
    
    QString currentFilePath;
    
    // Connect file selection
    QObject::connect(fileList, &QListWidget::currentTextChanged, [&](const QString& fileName) {
        currentFilePath = dir.filePath(fileName);
        QFile f(currentFilePath);
        if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
            editor->setPlainText(QString::fromUtf8(f.readAll()));
        }
    });
    
    // Connect save
    QObject::connect(saveBtn, &QPushButton::clicked, [&]() {
        if (currentFilePath.isEmpty()) return;
        QFile f(currentFilePath);
        if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
            f.write(editor->toPlainText().toUtf8());
            QMessageBox::information(&dlg, tr("Saved"), tr("File saved successfully."));
        }
    });
    
    // Select first file
    if (fileList->count() > 0)
        fileList->setCurrentRow(0);
    
    dlg.exec();
}

// --- System Message Slot Implementations ---

QString AiAssistWidget::systemMessagesDir() const {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    return scriptDir.filePath("system_messages");
}

void AiAssistWidget::onGenSysClicked() {
    QString base = systemMessagesDir();
    QList<QPair<QString, QString>> files;
    files << qMakePair(QString("Base Instructions"), base + "/base/system-instruction.md");
    files << qMakePair(QString("Improvements"), base + "/improvements/system-improvements.md");
    files << qMakePair(QString("Plan"), base + "/generate/system-instruction-oneshot-plan.md");
    files << qMakePair(QString("Generate"), base + "/generate/system-instruction-oneshot-gen.md");
    SystemMessageDialog dlg(files, this);
    dlg.exec();
}

void AiAssistWidget::onDesignSysClicked() {
    QString base = systemMessagesDir();
    QList<QPair<QString, QString>> files;
    files << qMakePair(QString("Plan (Design)"), base + "/design/system-instruction-oneshot-plan-design.md");
    files << qMakePair(QString("Generate (Design)"), base + "/design/system-instruction-oneshot-gen-design.md");
    SystemMessageDialog dlg(files, this);
    dlg.exec();
}

void AiAssistWidget::onAppSysClicked() {
    QString base = systemMessagesDir();
    QList<QPair<QString, QString>> files;
    files << qMakePair(QString("Base Instructions"), base + "/base/system-instruction.md");
    files << qMakePair(QString("Incremental"), base + "/append/system-instruction-incremental.md");
    SystemMessageDialog dlg(files, this);
    dlg.exec();
}

void AiAssistWidget::onFixSysClicked() {
    QString base = systemMessagesDir();
    QList<QPair<QString, QString>> files;
    files << qMakePair(QString("Base Instructions"), base + "/base/system-instruction.md");
    files << qMakePair(QString("Improvements"), base + "/improvements/system-improvements.md");
    files << qMakePair(QString("Fix"), base + "/fix/system-instruction-fix.md");
    SystemMessageDialog dlg(files, this);
    dlg.exec();
}

void AiAssistWidget::onRemSysClicked() {
    QString base = systemMessagesDir();
    QList<QPair<QString, QString>> files;
    files << qMakePair(QString("Base Instructions"), base + "/base/system-instruction.md");
    files << qMakePair(QString("Remake"), base + "/remake/system-instruction-remake.md");
    SystemMessageDialog dlg(files, this);
    dlg.exec();
}

void AiAssistWidget::onLearnSysClicked() {
    QString base = systemMessagesDir();
    QList<QPair<QString, QString>> files;
    files << qMakePair(QString("Base Instructions"), base + "/base/system-instruction.md");
    files << qMakePair(QString("Ask"), base + "/learn/system-instruction-learn.md");
    SystemMessageDialog dlg(files, this);
    dlg.exec();
}

} // namespace ScIDE
