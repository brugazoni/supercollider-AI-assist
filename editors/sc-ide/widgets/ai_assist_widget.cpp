/*
    SuperCollider Qt IDE — AI Assist Widget
    Tabbed interface for sc-gen-rag integration.
*/

#include "ai_assist_widget.hpp"

#include <QDialog>
#include <QTreeWidget>
#include <QLineEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QMessageBox>

class OpenRouterBrowserDialog : public QDialog {
public:
    class ModelItem : public QTreeWidgetItem {
    public:
        ModelItem(QTreeWidget* parent) : QTreeWidgetItem(parent) {}
        bool operator<(const QTreeWidgetItem& other) const override {
            int col = treeWidget()->sortColumn();
            if (col == 2) { // Context length
                return data(col, Qt::UserRole).toInt() < other.data(col, Qt::UserRole).toInt();
            } else if (col == 3 || col == 4) { // Prices
                return data(col, Qt::UserRole).toDouble() < other.data(col, Qt::UserRole).toDouble();
            }
            return QTreeWidgetItem::operator<(other);
        }
    };

    OpenRouterBrowserDialog(const QJsonArray& models, QWidget* parent = nullptr) 
        : QDialog(parent), mModels(models) 
    {
        setWindowTitle(tr("OpenRouter Model Browser"));
        resize(900, 600);

        QVBoxLayout* layout = new QVBoxLayout(this);

        QHBoxLayout* searchLayout = new QHBoxLayout;
        searchLayout->addWidget(new QLabel(tr("Search:")));
        mSearchBox = new QLineEdit;
        mSearchBox->setPlaceholderText(tr("Type to filter by name or ID..."));
        searchLayout->addWidget(mSearchBox);
        layout->addLayout(searchLayout);

        mTree = new QTreeWidget;
        mTree->setHeaderLabels({tr("Provider"), tr("Model"), tr("Context"), tr("Input ($/1M)"), tr("Output ($/1M)"), tr("ID")});
        mTree->setAlternatingRowColors(true);
        mTree->setSelectionBehavior(QAbstractItemView::SelectRows);
        mTree->setSelectionMode(QAbstractItemView::SingleSelection);
        mTree->setSortingEnabled(true);
        mTree->setRootIsDecorated(false); // Make it look like a flat table
        
        mTree->header()->resizeSection(0, 120);
        mTree->header()->resizeSection(1, 280);
        mTree->header()->resizeSection(2, 90);
        mTree->header()->resizeSection(3, 90);
        mTree->header()->resizeSection(4, 90);
        
        layout->addWidget(mTree);

        QHBoxLayout* btnLayout = new QHBoxLayout;
        btnLayout->addStretch();
        QPushButton* cancelBtn = new QPushButton(tr("Cancel"));
        QPushButton* selectBtn = new QPushButton(tr("Select"));
        selectBtn->setDefault(true);
        btnLayout->addWidget(cancelBtn);
        btnLayout->addWidget(selectBtn);
        layout->addLayout(btnLayout);

        connect(mSearchBox, &QLineEdit::textChanged, [this](const QString& text){
            populateTree(text);
        });

        connect(cancelBtn, &QPushButton::clicked, this, &QDialog::reject);
        connect(selectBtn, &QPushButton::clicked, [this]() {
            acceptSelection();
        });
        connect(mTree, &QTreeWidget::itemDoubleClicked, [this](QTreeWidgetItem* item, int) {
            if (item) {
                acceptSelection();
            }
        });

        populateTree("");
        mTree->sortByColumn(0, Qt::AscendingOrder); // Default sort by Provider
    }

    QString selectedModelId() const { return mSelectedId; }

private:
    QTreeWidget* mTree;
    QLineEdit* mSearchBox;
    QString mSelectedId;
    QJsonArray mModels;

    void populateTree(const QString& filter) {
        mTree->clear();

        QString f = filter.toLower();

        for (const QJsonValue& val : mModels) {
            QJsonObject m = val.toObject();
            QString id = m["id"].toString();
            QString name = m["name"].toString();
            
            if (!f.isEmpty() && !id.toLower().contains(f) && !name.toLower().contains(f)) {
                continue;
            }

            QString provider = "Other";
            int slashIdx = id.indexOf('/');
            if (slashIdx > 0) {
                provider = id.left(slashIdx);
                provider[0] = provider[0].toUpper();
            }

            ModelItem* mItem = new ModelItem(mTree);
            mItem->setText(0, provider);
            mItem->setText(1, name);
            
            int ctx = m["context_length"].toInt();
            QString ctxStr = ctx >= 1000 ? QString::number(ctx / 1000) + "k" : QString::number(ctx);
            mItem->setText(2, ctxStr);
            mItem->setData(2, Qt::UserRole, ctx);
            
            double priceIn = m["price_in"].toDouble();
            double priceOut = m["price_out"].toDouble();
            mItem->setText(3, priceIn < 0 ? "Auto" : QString::number(priceIn, 'f', 2));
            mItem->setData(3, Qt::UserRole, priceIn);
            mItem->setText(4, priceOut < 0 ? "Auto" : QString::number(priceOut, 'f', 2));
            mItem->setData(4, Qt::UserRole, priceOut);
            
            mItem->setText(5, id);
            mItem->setData(0, Qt::UserRole, id);
        }
    }

    void acceptSelection() {
        QTreeWidgetItem* item = mTree->currentItem();
        if (!item) {
            return;
        }
        mSelectedId = item->data(0, Qt::UserRole).toString();
        accept();
    }
};


#include "post_window.hpp"
#include "main_window.hpp"
#include "multi_editor.hpp"
#include "prompt_nav_bar.hpp"
#include "../core/doc_manager.hpp"
#include "../core/main.hpp"
#include <QTextCursor>

#include <QApplication>
#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QScrollBar>
#include <QProgressBar>
#include <QFormLayout>
#include <QGridLayout>
#include <QInputDialog>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTemporaryFile>
#include <QDateTime>
#include <QMenu>
#include <QMessageBox>
#include <QDialog>
#include <QList>
#include <QPair>
#include <QTextBrowser>
#include <QFileDialog>
#include <QUuid>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QRegularExpression>
#include <QProcessEnvironment>
#include <QSet>
#include <QThread>
#include <QRandomGenerator>


namespace ScIDE {

static QString comboModelId(const QComboBox* combo) {
    if (!combo) return QString();
    int idx = combo->currentIndex();
    QString text = combo->currentText().trimmed();
    return (idx >= 0 && text == combo->itemText(idx))
               ? combo->itemData(idx).toString()
               : text;
}

static void fillOpenRouterCombo(QComboBox* combo, const QJsonArray& models, const QString& selectId) {
    if (!combo) return;
    combo->blockSignals(true);
    combo->clear();
    if (models.isEmpty()) {
        combo->addItem("openai/gpt-6-luna - $0.10/$0.50", "openai/gpt-6-luna");
        combo->addItem("openai/gpt-6.1-sol - $2.00/$10.00", "openai/gpt-6.1-sol");
    } else {
        for (const QJsonValue& v : models) {
            QJsonObject m = v.toObject();
            QString id = m["id"].toString();
            double priceIn = m["price_in"].toDouble();
            double priceOut = m["price_out"].toDouble();
            QString label = QString("%1 - %2/%3")
                                .arg(id)
                                .arg(priceIn < 0 ? "Auto" : "$" + QString::number(priceIn, 'f', 2))
                                .arg(priceOut < 0 ? "Auto" : "$" + QString::number(priceOut, 'f', 2));
            combo->addItem(label, id);
        }
    }
    int idx = selectId.isEmpty() ? -1 : combo->findData(selectId);
    combo->setCurrentIndex(idx);
    if (idx < 0 && !selectId.isEmpty()) {
        combo->setEditText(selectId);
    }
    if (combo->lineEdit()) {
        combo->lineEdit()->setPlaceholderText(QObject::tr("Select an OpenRouter model..."));
    }
    combo->blockSignals(false);
}

class OpenRouterDefaultsDialog : public QDialog {
public:
    OpenRouterDefaultsDialog(const QJsonArray& models,
                             const QString& currentFast,
                             const QString& currentBetter,
                             QWidget* parent = nullptr)
        : QDialog(parent), mModels(models)
    {
        setWindowTitle(tr("OpenRouter Default Slots"));
        resize(620, 180);

        QVBoxLayout* layout = new QVBoxLayout(this);
        QLabel* info = new QLabel(tr("Choose the default OpenRouter models for the Fast and Better quick-switch slots:"));
        info->setWordWrap(true);
        layout->addWidget(info);

        QFormLayout* form = new QFormLayout;

        auto makeSlotRow = [&](const QString& initialId, QComboBox*& outCombo) {
            QHBoxLayout* row = new QHBoxLayout;
            outCombo = new QComboBox;
            outCombo->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
            outCombo->setEditable(true);
            outCombo->setInsertPolicy(QComboBox::NoInsert);
            fillOpenRouterCombo(outCombo, mModels, initialId);
            row->addWidget(outCombo);

            QPushButton* browseBtn = new QPushButton(tr("Browse..."));
            browseBtn->setEnabled(!mModels.isEmpty());
            connect(browseBtn, &QPushButton::clicked, this, [this, outCombo]() {
                OpenRouterBrowserDialog dlg(mModels, this);
                if (dlg.exec() == QDialog::Accepted) {
                    QString id = dlg.selectedModelId();
                    if (!id.isEmpty()) {
                        int idx = outCombo->findData(id);
                        outCombo->setCurrentIndex(idx);
                        if (idx < 0) outCombo->setEditText(id);
                    }
                }
            });
            row->addWidget(browseBtn);
            return row;
        };

        form->addRow(tr("Fast slot:"), makeSlotRow(currentFast, mFastCombo));
        form->addRow(tr("Better slot:"), makeSlotRow(currentBetter, mBetterCombo));
        layout->addLayout(form);

        QHBoxLayout* btnLayout = new QHBoxLayout;
        QPushButton* resetBtn = new QPushButton(tr("Reset (Luna / Sol)"));
        connect(resetBtn, &QPushButton::clicked, this, [this]() {
            auto setCombo = [](QComboBox* combo, const QString& id) {
                int idx = combo->findData(id);
                combo->setCurrentIndex(idx);
                if (idx < 0) combo->setEditText(id);
            };
            setCombo(mFastCombo, QStringLiteral("openai/gpt-6-luna"));
            setCombo(mBetterCombo, QStringLiteral("openai/gpt-6.1-sol"));
        });
        btnLayout->addWidget(resetBtn);
        btnLayout->addStretch();

        QPushButton* cancelBtn = new QPushButton(tr("Cancel"));
        QPushButton* saveBtn = new QPushButton(tr("Save Defaults"));
        saveBtn->setDefault(true);
        connect(cancelBtn, &QPushButton::clicked, this, &QDialog::reject);
        connect(saveBtn, &QPushButton::clicked, this, &QDialog::accept);
        btnLayout->addWidget(cancelBtn);
        btnLayout->addWidget(saveBtn);
        layout->addLayout(btnLayout);
    }

    QString fastModelId() const { return comboModelId(mFastCombo); }
    QString betterModelId() const { return comboModelId(mBetterCombo); }

private:
    QJsonArray mModels;
    QComboBox* mFastCombo = nullptr;
    QComboBox* mBetterCombo = nullptr;
};

// SystemMessageDialog removed — replaced by reusable openSysMessageEditor()

AiAssistWidget::AiAssistWidget(PostWindow* postWindow, QWidget* parent)
    : QWidget(parent)
    , mPostWindow(postWindow)
    , mLastActiveDocument(nullptr)
    , mCurrentProcess(nullptr)
{
    mErrorCheckTimer = new QTimer(this);
    mErrorCheckTimer->setSingleShot(true);
    connect(mErrorCheckTimer, &QTimer::timeout, this, &AiAssistWidget::onErrorCheckTimeout);

    mXPostErrorFixTimer = new QTimer(this);
    mXPostErrorFixTimer->setSingleShot(true);
    connect(mXPostErrorFixTimer, &QTimer::timeout, this, &AiAssistWidget::onMainServerErrorAutoFix);

    QVBoxLayout* mainLayout = new QVBoxLayout(this);
    mainLayout->setContentsMargins(0, 0, 0, 0);
    mainLayout->setSpacing(2);

    QButtonGroup* providerGroup = new QButtonGroup(this);

    // === Row 1: Model, Temperature, Thinking ===
    QHBoxLayout* row1 = new QHBoxLayout;
    row1->setContentsMargins(4, 2, 4, 0);
    row1->setSpacing(4);

    mProviderDirectRadio = new QRadioButton(tr("Direct:"));
    mProviderDirectRadio->setChecked(true);
    providerGroup->addButton(mProviderDirectRadio);
    row1->addWidget(mProviderDirectRadio);
    
    mModelCombo = new QComboBox;
    mModelCombo->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
    row1->addWidget(mModelCombo);
    connect(mModelCombo, &QComboBox::currentTextChanged, this, &AiAssistWidget::onModelChanged);

    row1->addSpacing(6);
    row1->addWidget(new QLabel(tr("T:")));
    mTempSlider = new QSlider(Qt::Horizontal);
    mTempSlider->setRange(0, 20);
    mTempSlider->setValue(7);
    mTempSlider->setFixedWidth(60);
    row1->addWidget(mTempSlider);
    mTempLabel = new QLabel(tr("0.7"));
    mTempLabel->setFixedWidth(22);
    row1->addWidget(mTempLabel);
    connect(mTempSlider, &QSlider::valueChanged, this, &AiAssistWidget::onTemperatureSliderChanged);

    row1->addSpacing(6);
    row1->addWidget(new QLabel(tr("Think:")));
    mThinkingCombo = new QComboBox;
    mThinkingCombo->addItem(tr("Off"), 0);
    mThinkingCombo->addItem(tr("1k"), 1024);
    mThinkingCombo->addItem(tr("4k"), 4096);
    mThinkingCombo->addItem(tr("8k"), 8192);
    mThinkingCombo->addItem(tr("16k"), 16384);
    mThinkingCombo->setToolTip(tr("Extended reasoning budget (Claude 3.7 native)."));
    mThinkingCombo->setFixedWidth(55);
    row1->addWidget(mThinkingCombo);

    mainLayout->addLayout(row1);

    // === Row 1b: OpenRouter model selector (Fast / Better slots) ===
    loadOpenRouterDefaults();

    QHBoxLayout* row1b = new QHBoxLayout;
    row1b->setContentsMargins(4, 0, 4, 0);
    row1b->setSpacing(4);

    mProviderOpenRouterRadio = new QRadioButton(tr("OR:"));
    providerGroup->addButton(mProviderOpenRouterRadio);
    row1b->addWidget(mProviderOpenRouterRadio);

    QButtonGroup* orSlotGroup = new QButtonGroup(this);
    orSlotGroup->setExclusive(true);

    QString slotBtnStyle =
        "QPushButton { padding: 2px 6px; font-size: 11px; border: 1px solid #555; border-radius: 3px; }"
        "QPushButton:checked { background-color: #2980b9; color: white; border-color: #3498db; font-weight: bold; }";

    mOpenRouterFastBtn = new QPushButton(tr("Fast"));
    mOpenRouterFastBtn->setCheckable(true);
    mOpenRouterFastBtn->setChecked(true);
    mOpenRouterFastBtn->setStyleSheet(slotBtnStyle);
    orSlotGroup->addButton(mOpenRouterFastBtn, 0);
    row1b->addWidget(mOpenRouterFastBtn);

    mOpenRouterBetterBtn = new QPushButton(tr("Better"));
    mOpenRouterBetterBtn->setCheckable(true);
    mOpenRouterBetterBtn->setStyleSheet(slotBtnStyle);
    orSlotGroup->addButton(mOpenRouterBetterBtn, 1);
    row1b->addWidget(mOpenRouterBetterBtn);

    mOpenRouterCombo = new QComboBox;
    mOpenRouterCombo->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);
    mOpenRouterCombo->setEditable(true);
    mOpenRouterCombo->setInsertPolicy(QComboBox::NoInsert);
    // Seed with the default Fast / Better models so it's usable while fetching
    fillOpenRouterCombo(mOpenRouterCombo, QJsonArray(), mOpenRouterFastModel);
    mOpenRouterCombo->setToolTip(tr("OpenRouter model for the active Fast/Better slot\nRequires OPENROUTER_API_KEY in API settings.\nSelecting a model here automatically switches to OpenRouter."));
    row1b->addWidget(mOpenRouterCombo);

    mOpenRouterBrowseBtn = new QPushButton(tr("Browse..."));
    mOpenRouterBrowseBtn->setToolTip(tr("Browse all OpenRouter models"));
    row1b->addWidget(mOpenRouterBrowseBtn);

    mOpenRouterDefaultsBtn = new QPushButton(tr("Defaults..."));
    mOpenRouterDefaultsBtn->setToolTip(tr("Define default Fast and Better models from OpenRouter choices"));
    row1b->addWidget(mOpenRouterDefaultsBtn);

    updateOpenRouterSlotTooltips();

    connect(mOpenRouterFastBtn, &QPushButton::clicked, this, [this]() {
        selectOpenRouterSlot(0, true);
    });
    connect(mOpenRouterBetterBtn, &QPushButton::clicked, this, [this]() {
        selectOpenRouterSlot(1, true);
    });

    // Auto-switch provider radio when user interacts with either combo.
    // QComboBox::activated is emitted only for user picks (never for
    // programmatic changes such as session restore), and — unlike
    // currentIndexChanged — it also fires when the user re-picks the item that
    // is already current. That matters for the OR combo: after the model list
    // is loaded, picking the visible item would otherwise never flip the radio.
    connect(mModelCombo, QOverload<int>::of(&QComboBox::activated),
            this, [this](int) {
        mProviderDirectRadio->setChecked(true);
    });

    connect(mOpenRouterCombo, QOverload<int>::of(&QComboBox::activated),
            this, [this](int index) {
        if (index >= 0) {
            mProviderOpenRouterRadio->setChecked(true);
        }
    });

    connect(mOpenRouterCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, [this](int index) {
        if (index >= 0) {
            mProviderOpenRouterRadio->setChecked(true);
        }
        QString selected = comboModelId(mOpenRouterCombo);
        if (!selected.isEmpty()) {
            if (mActiveOpenRouterSlot == 0) mOpenRouterFastModel = selected;
            else mOpenRouterBetterModel = selected;
            updateOpenRouterSlotTooltips();
        }
        onOpenRouterModelChanged(index);
    });

    // Also auto-switch when user types in the editable OR combo and store in active slot
    connect(mOpenRouterCombo->lineEdit(), &QLineEdit::textEdited, this, [this](const QString& text) {
        mProviderOpenRouterRadio->setChecked(true);
        QString trimmed = text.trimmed();
        if (mActiveOpenRouterSlot == 0) mOpenRouterFastModel = trimmed;
        else mOpenRouterBetterModel = trimmed;
        updateOpenRouterSlotTooltips();
    });

    connect(mOpenRouterBrowseBtn, &QPushButton::clicked,
            this, &AiAssistWidget::onOpenRouterBrowseClicked);
    connect(mOpenRouterDefaultsBtn, &QPushButton::clicked,
            this, &AiAssistWidget::onOpenRouterDefaultsClicked);

    mainLayout->addLayout(row1b);

    // === Row 2: Utility actions ===
    QHBoxLayout* row2 = new QHBoxLayout;
    row2->setContentsMargins(4, 0, 4, 0);
    row2->setSpacing(4);

    mPromptHistoryBtn = new QPushButton(tr("History"));
    mPromptHistoryBtn->setToolTip(tr("View prompt history for this session."));
    connect(mPromptHistoryBtn, &QPushButton::clicked, this, &AiAssistWidget::onPromptHistoryClicked);
    row2->addWidget(mPromptHistoryBtn);

    mImportSessionBtn = new QPushButton(tr("Import"));
    mImportSessionBtn->setToolTip(tr("Load a previous AI session (.ai-session.json)."));
    connect(mImportSessionBtn, &QPushButton::clicked, this, &AiAssistWidget::onImportSessionClicked);
    row2->addWidget(mImportSessionBtn);

    mBootupBtn = new QPushButton(tr("Audio"));
    mBootupBtn->setToolTip(tr("Open the SuperCollider audio bootstrap script to select output devices."));
    connect(mBootupBtn, &QPushButton::clicked, this, &AiAssistWidget::onBootupClicked);
    row2->addWidget(mBootupBtn);

    mApiKeysBtn = new QPushButton(tr("API"));
    mApiKeysBtn->setToolTip(tr("Manage LLM API Keys for the SC agent."));
    connect(mApiKeysBtn, &QPushButton::clicked, this, &AiAssistWidget::onApiKeysClicked);
    row2->addWidget(mApiKeysBtn);

    row2->addStretch();

    mStatusBtn = new QPushButton;
    mStatusBtn->setFlat(true);
    mStatusBtn->setStyleSheet("QPushButton { color: #aaa; font-size: 10px; padding: 0px 4px; border: none; }"
                              "QPushButton:hover { color: white; }");
    mStatusBtn->setToolTip(tr("Click to view full status message."));
    connect(mStatusBtn, &QPushButton::clicked, this, &AiAssistWidget::onStatusClicked);
    row2->addWidget(mStatusBtn);

    mCancelBtn = new QPushButton(tr("Cancel"));
    mCancelBtn->setToolTip(tr("Cancel the currently running AI prompt or queued requests."));
    mCancelBtn->setEnabled(false);
    mCancelBtn->setStyleSheet(
        "QPushButton { background-color: #c0392b; color: white; font-weight: bold; font-size: 10px; padding: 2px 8px; border-radius: 3px; border: none; }"
        "QPushButton:hover { background-color: #e74c3c; }"
        "QPushButton:disabled { background-color: transparent; color: #555; border: 1px solid #444; font-weight: normal; }");
    connect(mCancelBtn, &QPushButton::clicked, this, &AiAssistWidget::onCancelClicked);
    row2->addWidget(mCancelBtn);

    mainLayout->addLayout(row2);

    // === Row 3: Session cost, eco, context, wait ===
    QHBoxLayout* row3 = new QHBoxLayout;
    row3->setContentsMargins(4, 0, 4, 0);
    row3->setSpacing(4);

    mSessionStatsBtn = new QPushButton(tr("$0.00"));
    mSessionStatsBtn->setToolTip(tr("Session cost — click for breakdown per model."));
    mSessionStatsBtn->setStyleSheet("QPushButton { padding: 1px 4px; }");
    connect(mSessionStatsBtn, &QPushButton::clicked, this, &AiAssistWidget::onSessionStatsClicked);
    row3->addWidget(mSessionStatsBtn);

    mSustainabilityBtn = new QPushButton(tr("i"));
    mSustainabilityBtn->setFixedSize(18, 18);
    mSustainabilityBtn->setToolTip(tr("View Eco-Impact metric definitions (Energy, GWP, ADPe, PE, WCF)"));
    mSustainabilityBtn->setStyleSheet("QPushButton { color: white; background-color: #2980b9; border-radius: 9px; font-weight: bold; font-size: 10px; }");
    connect(mSustainabilityBtn, &QPushButton::clicked, this, &AiAssistWidget::onSustainabilityClicked);
    row3->addWidget(mSustainabilityBtn);

    mEcoLabel = new QPushButton(tr("Eco: --"));
    mEcoLabel->setToolTip(tr("Environmental impact — click for details."));
    mEcoLabel->setStyleSheet(
        "QPushButton { background-color: #27ae60; color: white; padding: 1px 5px; border-radius: 3px; border: none; font-size: 10px; }"
        "QPushButton:hover { background-color: #2ecc71; }");
    connect(mEcoLabel, &QPushButton::clicked, this, &AiAssistWidget::onSustainabilityClicked);
    row3->addWidget(mEcoLabel);

    row3->addStretch();

    mContextLabel = new QLabel(tr("Ctx: 0k"));
    mContextLabel->setStyleSheet("color: #7f8c8d; font-size: 10px;");
    row3->addWidget(mContextLabel);

    mContextBar = new QProgressBar;
    mContextBar->setRange(0, 100);
    mContextBar->setValue(0);
    mContextBar->setFixedHeight(6);
    mContextBar->setFixedWidth(60);
    mContextBar->setTextVisible(false);
    mContextBar->setStyleSheet("QProgressBar { background-color: #2c3e50; border: none; border-radius: 3px; } "
                               "QProgressBar::chunk { background-color: #3498db; border-radius: 3px; }");
    mContextBar->setToolTip(tr("Cumulative context token usage for this session.\n"
                               "This tracks total tokens consumed across all calls.\n"
                               "Individual calls are sent independently to the API,\n"
                               "so exceeding 100%% does not block further generation\n"
                               "but may indicate heavy session usage."));
    row3->addWidget(mContextBar);

    mTotalWaitLabel = new QLabel(tr("Wait: 0.0s"));
    mTotalWaitLabel->setToolTip(tr("Total time spent waiting for LLM responses this session."));
    mTotalWaitLabel->setStyleSheet("QLabel { color: #f39c12; font-size: 10px; }");
    row3->addWidget(mTotalWaitLabel);

    mainLayout->addLayout(row3);

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
    if (modelProc.waitForFinished(15000)) {
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
        mModelCombo->addItem("gemini/gemini-3.8-flash");
        mModelCombo->addItem("gemini/gemini-3.1-pro-preview");
        mModelCombo->addItem("ollama/qwen3:4b");
        mModelCombo->addItem("anthropic/claude-3-7-sonnet");
        mModelCombo->addItem("openai/gpt-4o");
        mModelCombo->addItem("deepseek/deepseek-chat");
    }
    
    // NOTE: init_session and initial stats fetch are deferred to connectDocumentSignals()
    // where the real active document is known (avoids orphaned/wrong session logs).
    
    // Start the persistent daemon and parallel validation server
    startDaemon();
    startValidationServer();
}

AiAssistWidget::~AiAssistWidget() {
    stopValidationServer();
    if (mDaemonProcess) {
        if (mDaemonProcess->state() == QProcess::Running) {
            QJsonObject cmd;
            cmd["command"] = QStringLiteral("stop_dictation");
            QJsonDocument jsonDoc(cmd);
            mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
            
            mDaemonProcess->closeWriteChannel();
            
            if (!mDaemonProcess->waitForFinished(3000)) {
                mDaemonProcess->kill();
                mDaemonProcess->waitForFinished(1000);
            }
        }
        delete mDaemonProcess;
    }
}

QString AiAssistWidget::currentModelKey() const {
    if (mProviderOpenRouterRadio && mProviderOpenRouterRadio->isChecked()) {
        // If the edit text still matches the selected list item, use its data (ID).
        // Otherwise the user typed/edited the text manually (e.g. a raw ID such as
        // "~google/gemini-flash-latest"), so use the typed text. Note that typing in an
        // editable QComboBox does NOT change currentIndex, so checking the index alone
        // would silently send the previously selected model instead.
        QString orKey = comboModelId(mOpenRouterCombo);
        if (!orKey.isEmpty())
            return "openrouter:" + orKey;
    }
    return mModelCombo->currentText();
}

void AiAssistWidget::updateOpenRouterSlotTooltips() {
    if (mOpenRouterFastBtn) {
        mOpenRouterFastBtn->setToolTip(
            tr("Fast slot: %1\nClick to switch to the Fast OpenRouter model.").arg(mOpenRouterFastModel));
    }
    if (mOpenRouterBetterBtn) {
        mOpenRouterBetterBtn->setToolTip(
            tr("Better slot: %1\nClick to switch to the Better OpenRouter model.").arg(mOpenRouterBetterModel));
    }
}

void AiAssistWidget::applyOpenRouterModelToCombo(const QString& modelId, bool triggerModelChanged) {
    if (!mOpenRouterCombo) return;
    int idx = modelId.isEmpty() ? -1 : mOpenRouterCombo->findData(modelId);
    mOpenRouterCombo->blockSignals(true);
    mOpenRouterCombo->setCurrentIndex(idx);
    if (idx < 0 && !modelId.isEmpty()) {
        mOpenRouterCombo->setEditText(modelId);
    }
    mOpenRouterCombo->blockSignals(false);
    if (triggerModelChanged && idx >= 0) {
        onOpenRouterModelChanged(idx);
    }
}

void AiAssistWidget::selectOpenRouterSlot(int slot, bool activateProvider) {
    mActiveOpenRouterSlot = (slot == 1) ? 1 : 0;
    if (mOpenRouterFastBtn) mOpenRouterFastBtn->setChecked(mActiveOpenRouterSlot == 0);
    if (mOpenRouterBetterBtn) mOpenRouterBetterBtn->setChecked(mActiveOpenRouterSlot == 1);

    const QString& targetModel = (mActiveOpenRouterSlot == 0) ? mOpenRouterFastModel : mOpenRouterBetterModel;
    applyOpenRouterModelToCombo(targetModel, true);
    if (activateProvider && mProviderOpenRouterRadio) {
        mProviderOpenRouterRadio->setChecked(true);
    }
    updateOpenRouterSlotTooltips();
}

void AiAssistWidget::saveOpenRouterDefaults() {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    QString filePath = scriptDir.filePath("openrouter_slots.json");

    QJsonObject obj;
    obj["fast_model"] = mOpenRouterFastModel;
    obj["better_model"] = mOpenRouterBetterModel;

    QFile f(filePath);
    if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        f.write(QJsonDocument(obj).toJson(QJsonDocument::Indented));
    }
}

void AiAssistWidget::loadOpenRouterDefaults() {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    QString filePath = scriptDir.filePath("openrouter_slots.json");

    QFile f(filePath);
    if (!f.exists() || !f.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) return;
    QJsonObject obj = doc.object();

    QString fast = obj["fast_model"].toString().trimmed();
    QString better = obj["better_model"].toString().trimmed();
    if (!fast.isEmpty()) mOpenRouterFastModel = fast;
    if (!better.isEmpty()) mOpenRouterBetterModel = better;
}

void AiAssistWidget::populateOpenRouterCombo(const QJsonArray& models) {
    mOpenRouterModels = models;

    // Work out which model should be selected after repopulating:
    // a model restored from a session takes priority, otherwise keep the active slot's model.
    QString wanted = mPendingOpenRouterModel;
    if (wanted.isEmpty()) {
        wanted = (mActiveOpenRouterSlot == 0) ? mOpenRouterFastModel : mOpenRouterBetterModel;
        if (wanted.isEmpty()) {
            wanted = comboModelId(mOpenRouterCombo);
        }
        if (wanted.isEmpty()) {
            wanted = QStringLiteral("openai/gpt-6-luna");
        }
    }

    // Do NOT silently pre-select item 0: an implicitly selected item looks
    // "chosen" in the UI while the Direct provider is still active, and picking
    // that same item would not emit currentIndexChanged.
    fillOpenRouterCombo(mOpenRouterCombo, mOpenRouterModels, wanted);

    mPendingOpenRouterModel.clear();
    // Intentionally no onOpenRouterModelChanged() here: this only re-applies an
    // existing/restored selection, so the user's (or session's) temperature is kept.

    mFullStatusText = QString("OpenRouter: %1 models loaded").arg(mOpenRouterModels.size());
    mStatusBtn->setText(mFullStatusText);
}

void AiAssistWidget::fetchOpenRouterModels() {
    // Run asynchronously in its own lightweight QProcess so it never sets mCurrentProcess
    // during daemon startup and never blocks or rejects early user commands.
    QProcess* proc = new QProcess(this);
    proc->setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList args;
    args << backendScriptPath() << "list_openrouter_models" << "{}";
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, proc](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            QJsonDocument doc = QJsonDocument::fromJson(proc->readAllStandardOutput());
            if (!doc.isNull() && doc.isObject()) {
                QJsonObject result = doc.object();
                if (result.contains("error") && !result["error"].toString().isEmpty()) {
                    if (!mDaemonBusy) {
                        mFullStatusText = "OpenRouter: " + result["error"].toString();
                        mStatusBtn->setText(mFullStatusText.left(30) + (mFullStatusText.length() > 30 ? "..." : ""));
                    }
                } else {
                    populateOpenRouterCombo(result["models"].toArray());
                }
            }
        }
        proc->deleteLater();
    });
    proc->start(pythonPath(), args);
}

void AiAssistWidget::onOpenRouterBrowseClicked() {
    auto openDialog = [this]() {
        if (mOpenRouterModels.isEmpty()) {
            QMessageBox::warning(this, tr("No Models"), tr("No OpenRouter models found. Please ensure your API key is set."));
            return;
        }
        OpenRouterBrowserDialog dlg(mOpenRouterModels, this);
        if (dlg.exec() == QDialog::Accepted) {
            QString id = dlg.selectedModelId();
            if (!id.isEmpty()) {
                if (mActiveOpenRouterSlot == 0) mOpenRouterFastModel = id;
                else mOpenRouterBetterModel = id;
                applyOpenRouterModelToCombo(id, true);
                mProviderOpenRouterRadio->setChecked(true);
                updateOpenRouterSlotTooltips();
            }
        }
    };

    if (mOpenRouterModels.isEmpty()) {
        mFullStatusText = "Fetching OpenRouter models...";
        mStatusBtn->setText(mFullStatusText);
        runBackendCommand("list_openrouter_models", QJsonObject(), [this, openDialog](const QJsonObject& result) {
            if (result.contains("error") && !result["error"].toString().isEmpty()) {
                mFullStatusText = "OpenRouter: " + result["error"].toString();
                mStatusBtn->setText(mFullStatusText.left(30) + (mFullStatusText.length() > 30 ? "..." : ""));
                return;
            }
            populateOpenRouterCombo(result["models"].toArray());
            openDialog();
        });
    } else {
        openDialog();
    }
}

void AiAssistWidget::onOpenRouterDefaultsClicked() {
    auto openDialog = [this]() {
        OpenRouterDefaultsDialog dlg(mOpenRouterModels, mOpenRouterFastModel, mOpenRouterBetterModel, this);
        if (dlg.exec() == QDialog::Accepted) {
            QString newFast = dlg.fastModelId();
            QString newBetter = dlg.betterModelId();
            if (!newFast.isEmpty()) mOpenRouterFastModel = newFast;
            if (!newBetter.isEmpty()) mOpenRouterBetterModel = newBetter;
            saveOpenRouterDefaults();
            updateOpenRouterSlotTooltips();

            const QString& activeModel = (mActiveOpenRouterSlot == 0) ? mOpenRouterFastModel : mOpenRouterBetterModel;
            applyOpenRouterModelToCombo(activeModel, mProviderOpenRouterRadio && mProviderOpenRouterRadio->isChecked());

            mFullStatusText = tr("Saved OpenRouter defaults (Fast: %1, Better: %2)")
                                  .arg(mOpenRouterFastModel, mOpenRouterBetterModel);
            mStatusBtn->setText(mFullStatusText.left(45) + (mFullStatusText.length() > 45 ? "..." : ""));
        }
    };

    if (mOpenRouterModels.isEmpty()) {
        mFullStatusText = "Fetching OpenRouter models...";
        mStatusBtn->setText(mFullStatusText);
        runBackendCommand("list_openrouter_models", QJsonObject(), [this, openDialog](const QJsonObject& result) {
            if (result.contains("error") && !result["error"].toString().isEmpty()) {
                mFullStatusText = "OpenRouter: " + result["error"].toString();
                mStatusBtn->setText(mFullStatusText.left(30) + (mFullStatusText.length() > 30 ? "..." : ""));
            } else {
                populateOpenRouterCombo(result["models"].toArray());
            }
            openDialog();
        });
    } else {
        openDialog();
    }
}

void AiAssistWidget::onOpenRouterModelChanged(int index) {
    if (index < 0) return;
    
    QString modelId = mOpenRouterCombo->currentData().toString();
    for (const QJsonValue& v : mOpenRouterModels) {
        QJsonObject m = v.toObject();
        if (m["id"].toString() == modelId) {
            double defaultTemp = m.value("default_temp").toDouble(0.7);
            double maxTemp = m.value("max_temp").toDouble(2.0);
            mTempSlider->blockSignals(true);
            mTempSlider->setRange(0, maxTemp * 10);
            mTempSlider->setValue(defaultTemp * 10);
            mTempLabel->setText(QString::number(defaultTemp, 'f', 1));
            mTempSlider->blockSignals(false);
            break;
        }
    }
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
    connect(dm, &DocumentManager::opened, this, &AiAssistWidget::onDocumentShown);
    connect(dm, &DocumentManager::closed, this, &AiAssistWidget::onDocumentClosed);

    // Catch-up: the initial document may have been shown before we connected,
    // so restore its session now if one exists on disk.
    Document* current = dm->activeDocument();
    if (current) {
        onDocumentShown(current, -1, 0);
    }

    // Clear any stale .pending_rag_blocks.json left behind by an abnormal exit of a previous IDE run
    QString staleRagPath = QFileInfo(backendScriptPath()).absolutePath() + "/use-logs/.pending_rag_blocks.json";
    if (QFile::exists(staleRagPath)) {
        QFile::remove(staleRagPath);
    }

    // Init the session log with the real active file (deferred from constructor)
    QProcess initProc;
    initProc.setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList initArgs;
    QJsonObject initData = basePayload();
    initArgs << backendScriptPath() << "init_session" << QJsonDocument(initData).toJson(QJsonDocument::Compact);
    initProc.start(pythonPath(), initArgs);
    initProc.waitForFinished(3000);

    // Initial fetch of session stats
    tryUpdateSessionStats();
    fetchOpenRouterModels();

    // Fire-and-forget: sync pending session logs to Google Docs.
    // Heap-allocated so the process survives past this function's scope.
    // If Google OAuth re-auth is needed, the browser flow has unlimited time.
    QProcess* syncProc = new QProcess(this);
    syncProc->setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList syncArgs;
    syncArgs << backendScriptPath() << "sync_to_drive" << QJsonDocument(QJsonObject()).toJson(QJsonDocument::Compact);
    connect(syncProc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            syncProc, &QProcess::deleteLater);
    syncProc->start(pythonPath(), syncArgs);
}

QString AiAssistWidget::sessionFilePath(Document* doc) const {
    if (!doc) return QString();
    QString path = doc->filePath();
    if (path.isEmpty()) {
        QString uuidStr = QString::fromLatin1(doc->id());
        QString scriptDir = QFileInfo(backendScriptPath()).absolutePath();
        return scriptDir + "/use-logs/.untitled_" + uuidStr + ".ai-session.json";
    }
    return path + ".ai-session.json";
}

bool AiAssistWidget::hasSessionContent() const {
    return !mGenPrompt->toPlainText().trimmed().isEmpty()
        || !mGenPlanOutput->toPlainText().trimmed().isEmpty()
        || !mDesignPrompt->toPlainText().trimmed().isEmpty()
        || !mDesignPlanOutput->toPlainText().trimmed().isEmpty()
        || !mComposePrompt->toPlainText().trimmed().isEmpty()
        || !mComposePlanOutput->toPlainText().trimmed().isEmpty()
        || !mCustomPrompt->toPlainText().trimmed().isEmpty()
        || !mCompositionState.isEmpty()
        || !mLearnChatHistory.isEmpty()
        || !mAppendPrompt->toPlainText().trimmed().isEmpty()
        || !mXPrompt->toPlainText().trimmed().isEmpty()
        || !mLearnHistory->toPlainText().trimmed().isEmpty();
}

bool AiAssistWidget::hasApiKeyForCurrentModel() {
    QString provider;
    if (mProviderOpenRouterRadio && mProviderOpenRouterRadio->isChecked()) {
        provider = "openrouter";
    } else {
        QString modelName = currentModelKey();
        if (mModelConfig.contains(modelName)) {
            provider = mModelConfig[modelName]["provider"].toString();
        }
        if (provider.isEmpty() && modelName.contains('/')) {
            provider = modelName.section('/', 0, 0).toLower();
        }
    }

    if (provider.isEmpty()) return true; // Can't validate, assume ok
    provider = provider.toLower().trimmed();
    if (provider == "ollama") return true; // Local Ollama needs no API key

    QStringList candidateKeys;
    if (provider == "gemini") {
        candidateKeys << "GEMINI_API_KEY" << "GOOGLE_API_KEY";
    } else if (provider == "openrouter") {
        candidateKeys << "OPENROUTER_API_KEY";
    } else if (provider == "anthropic") {
        candidateKeys << "ANTHROPIC_API_KEY";
    } else if (provider == "openai") {
        candidateKeys << "OPENAI_API_KEY";
    } else if (provider == "deepseek") {
        candidateKeys << "DEEPSEEK_API_KEY";
    } else {
        candidateKeys << provider.toUpper() + "_API_KEY";
    }

    // 1. Check system and process environment variables first
    for (const QString& key : candidateKeys) {
        QString envVal = QString::fromLocal8Bit(qgetenv(key.toUtf8().constData())).trimmed();
        if (!envVal.isEmpty()) return true;
        envVal = QProcessEnvironment::systemEnvironment().value(key).trimmed();
        if (!envVal.isEmpty()) return true;
    }

    // 2. Check .env file(s) - both sc-gen-rag/.env and root workspace .env
    QStringList envPaths;
    QString backendScript = backendScriptPath();
    envPaths << QFileInfo(backendScript).absolutePath() + QDir::separator() + ".env";
    QDir parentDir = QFileInfo(backendScript).dir();
    parentDir.cdUp();
    envPaths << parentDir.filePath(".env");

    for (const QString& envPath : envPaths) {
        QFile file(envPath);
        if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&file);
            while (!in.atEnd()) {
                QString line = in.readLine().trimmed();
                if (line.startsWith(QChar(0xFEFF)))
                    line = line.mid(1).trimmed();
                if (line.isEmpty() || line.startsWith('#'))
                    continue;
                if (line.startsWith("export ", Qt::CaseInsensitive))
                    line = line.mid(7).trimmed();

                int eqIdx = line.indexOf('=');
                if (eqIdx == -1) continue;

                QString k = line.left(eqIdx).trimmed();
                QString v = line.mid(eqIdx + 1).trimmed();
                if ((v.startsWith('"') && v.endsWith('"') && v.length() >= 2) ||
                    (v.startsWith(QChar('\'')) && v.endsWith(QChar('\'')) && v.length() >= 2)) {
                    v = v.mid(1, v.length() - 2).trimmed();
                }

                for (const QString& targetKey : candidateKeys) {
                    if (k.compare(targetKey, Qt::CaseInsensitive) == 0 && !v.isEmpty()) {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

void AiAssistWidget::saveSessionFor(Document* doc) {
    if (!doc) return;
    
    QJsonObject session;
    session["gen_prompt"] = mGenPrompt->toPlainText();
    session["gen_plan"] = mGenPlanOutput->toPlainText();
    session["gen_use_kb"] = mGenUseKb->isChecked();
    session["gen_include_ending"] = mGenIncludeEnding->isChecked();
    session["design_prompt"] = mDesignPrompt->toPlainText();
    session["design_plan"] = mDesignPlanOutput->toPlainText();
    session["design_use_kb"] = mDesignUseKb->isChecked();
    session["append_prompt"] = mAppendPrompt->toPlainText();
    session["append_use_kb"] = mAppendUseKb->isChecked();
    session["append_log"] = mAutoAppendLog->toHtml();
    session["append_block_index"] = mDictationBlockIndex;
    
    session["x_append_prompt"] = mXPrompt->toPlainText();
    session["x_append_use_kb"] = mXUseKbCheck->isChecked();
    session["x_append_auto_execute"] = mXAutoExecuteCheck->isChecked();
    session["x_append_lean_prompt"] = mXLeanPromptCheck ? mXLeanPromptCheck->isChecked() : false;
    session["x_append_auto_fix"] = mXAutoFixCheck ? mXAutoFixCheck->isChecked() : false;
    session["x_append_auto_fix_attempts"] = mXAutoFixAttemptsCombo ? mXAutoFixAttemptsCombo->currentData().toInt() : 1;
    session["x_append_auto_append"] = mXAutoAppendCheck->isChecked();
    session["x_append_log"] = mXAutoAppendLog->toHtml();
    session["x_append_block_index"] = mXDictationBlockIndex;
    QString xMode = "append";
    if (mXComposeRadio->isChecked()) xMode = "compose";
    else if (mXDesignRadio->isChecked()) xMode = "design";
    else if (mXGenerateRadio->isChecked()) xMode = "generate";
    session["x_append_mode"] = xMode;
    session["composition_state"] = mCompositionState;
    session["learn_history"] = mLearnHistory->toPlainText();
    session["learn_chat_history"] = mLearnChatHistory;
    session["model"] = currentModelKey();
    session["openrouter_fast_model"] = mOpenRouterFastModel;
    session["openrouter_better_model"] = mOpenRouterBetterModel;
    session["openrouter_active_slot"] = mActiveOpenRouterSlot;
    session["temperature"] = mTempSlider->value();
    session["remake_prompt"] = mRemakePrompt->toPlainText();
    session["kb_description"] = mKbDescription->toPlainText();
    session["compose_prompt"] = mComposePrompt->toPlainText();
    session["compose_plan"] = mComposePlanOutput->toPlainText();
    session["compose_use_kb"] = mComposeUseKb->isChecked();

    session["custom_prompt"] = mCustomPrompt->toPlainText();
    session["custom_use_kb"] = mCustomUseKb->isChecked();
    session["custom_sys_msgs"] = QJsonArray::fromStringList(mCustomSelectedSysMsgs);
    session["gen_plan_sys_msgs"] = QJsonArray::fromStringList(mGenPlanSysMsgs);
    session["gen_code_sys_msgs"] = QJsonArray::fromStringList(mGenCodeSysMsgs);
    session["design_plan_sys_msgs"] = QJsonArray::fromStringList(mDesignPlanSysMsgs);
    session["design_code_sys_msgs"] = QJsonArray::fromStringList(mDesignCodeSysMsgs);
    session["compose_plan_sys_msgs"] = QJsonArray::fromStringList(mComposePlanSysMsgs);
    session["compose_code_sys_msgs"] = QJsonArray::fromStringList(mComposeCodeSysMsgs);
    session["append_sys_msgs"] = QJsonArray::fromStringList(mAppendSysMsgs);
    session["fix_sys_msgs"] = QJsonArray::fromStringList(mFixSysMsgs);
    session["remake_sys_msgs"] = QJsonArray::fromStringList(mRemakeSysMsgs);
    session["learn_sys_msgs"] = QJsonArray::fromStringList(mLearnSysMsgs);

    if (PromptNavBar* navBar = promptNavBar()) {
        session["prompt_blocks"] = navBar->serializeForDocument(doc);
    }

    // Enrich with Stats Labels state
    session["stats_cost_text"] = mSessionStatsBtn->text();
    session["stats_eco_text"] = mEcoLabel->text();
    session["stats_wait_text"] = mTotalWaitLabel->text();
    session["stats_ctx_text"] = mContextLabel->text();
    session["stats_ctx_value"] = mContextBar->value();

    QString savePath = sessionFilePath(doc);
    // Write session sidecar immediately so UI state is guaranteed to be persisted even on fast IDE shutdown
    {
        QFile f(savePath);
        if (f.open(QIODevice::WriteOnly)) {
            f.write(QJsonDocument(session).toJson());
        }
    }

    // Fetch and embed the raw markdown log asynchronously for perfect re-import
    QProcess* proc = new QProcess(this);
    proc->setWorkingDirectory(QFileInfo(backendScriptPath()).absolutePath());
    QStringList args;
    QJsonObject data = basePayload();
    data["active_file"] = doc->filePath();
    args << backendScriptPath() << "get_raw_session_log" << QJsonDocument(data).toJson(QJsonDocument::Compact);

    // Pass session data to lambda to enrich with raw_log when process finishes
    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [proc, session, savePath]() mutable {
        QJsonDocument jsonDoc = QJsonDocument::fromJson(proc->readAllStandardOutput());
        if (!jsonDoc.isNull() && jsonDoc.isObject()) {
            session["raw_log"] = jsonDoc.object()["raw_log"].toString();
        }

        QFile f(savePath);
        if (f.open(QIODevice::WriteOnly)) {
            f.write(QJsonDocument(session).toJson());
        }
        proc->deleteLater();
    });

    proc->start(pythonPath(), args);
}

void AiAssistWidget::restoreSessionFor(const QString& filePath, bool forceNavRestore) {
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
    if (session.contains("append_use_kb")) mAppendUseKb->setChecked(session["append_use_kb"].toBool(true));
    if (session.contains("append_log")) mAutoAppendLog->setHtml(session["append_log"].toString());
    if (session.contains("append_block_index")) mDictationBlockIndex = session["append_block_index"].toInt();

    mXPrompt->setPlainText(session["x_append_prompt"].toString());
    if (session.contains("x_append_use_kb")) mXUseKbCheck->setChecked(session["x_append_use_kb"].toBool(true));
    if (session.contains("x_append_auto_execute")) mXAutoExecuteCheck->setChecked(session["x_append_auto_execute"].toBool(true));
    if (mXLeanPromptCheck && session.contains("x_append_lean_prompt")) mXLeanPromptCheck->setChecked(session["x_append_lean_prompt"].toBool(false));
    if (mXAutoFixCheck && session.contains("x_append_auto_fix")) mXAutoFixCheck->setChecked(session["x_append_auto_fix"].toBool(false));
    if (mXAutoFixAttemptsCombo && session.contains("x_append_auto_fix_attempts")) {
        int att = qBound(1, session["x_append_auto_fix_attempts"].toInt(1), 5);
        int idx = mXAutoFixAttemptsCombo->findData(att);
        if (idx >= 0) mXAutoFixAttemptsCombo->setCurrentIndex(idx);
    }
    if (session.contains("x_append_auto_append")) mXAutoAppendCheck->setChecked(session["x_append_auto_append"].toBool(false));
    if (session.contains("x_append_log")) mXAutoAppendLog->setHtml(session["x_append_log"].toString());
    if (session.contains("x_append_block_index")) mXDictationBlockIndex = session["x_append_block_index"].toInt();
    if (session.contains("x_append_mode")) {
        QString xMode = session["x_append_mode"].toString();
        if (xMode == "compose") mXComposeRadio->setChecked(true);
        else if (xMode == "design") mXDesignRadio->setChecked(true);
        else if (xMode == "generate") mXGenerateRadio->setChecked(true);
        else mXAppendRadio->setChecked(true);
    }
    mCompositionState = session["composition_state"].toString();
    mLearnHistory->setPlainText(session["learn_history"].toString());
    mLearnChatHistory = session["learn_chat_history"].toString();
    mRemakePrompt->setPlainText(session["remake_prompt"].toString());
    mKbDescription->setPlainText(session["kb_description"].toString());
    mComposePrompt->setPlainText(session["compose_prompt"].toString());
    mComposePlanOutput->setPlainText(session["compose_plan"].toString());
    if (session.contains("compose_use_kb")) mComposeUseKb->setChecked(session["compose_use_kb"].toBool(true));

    mCustomPrompt->setPlainText(session["custom_prompt"].toString());
    if (session.contains("custom_use_kb")) mCustomUseKb->setChecked(session["custom_use_kb"].toBool(true));
    if (session.contains("custom_sys_msgs")) {
        QJsonArray msgs = session["custom_sys_msgs"].toArray();
        mCustomSelectedSysMsgs.clear();
        for (int i = 0; i < msgs.size(); ++i) {
            mCustomSelectedSysMsgs.append(msgs[i].toString());
        }
    }

    // Helper to restore a QStringList from a JSON array key
    auto restoreSysMsgs = [&](const QString& key, QStringList& target) {
        if (session.contains(key)) {
            QJsonArray arr = session[key].toArray();
            target.clear();
            for (int i = 0; i < arr.size(); ++i) target.append(arr[i].toString());
        }
    };
    restoreSysMsgs("gen_plan_sys_msgs", mGenPlanSysMsgs);
    restoreSysMsgs("gen_code_sys_msgs", mGenCodeSysMsgs);
    restoreSysMsgs("design_plan_sys_msgs", mDesignPlanSysMsgs);
    restoreSysMsgs("design_code_sys_msgs", mDesignCodeSysMsgs);
    restoreSysMsgs("compose_plan_sys_msgs", mComposePlanSysMsgs);
    restoreSysMsgs("compose_code_sys_msgs", mComposeCodeSysMsgs);
    restoreSysMsgs("append_sys_msgs", mAppendSysMsgs);
    restoreSysMsgs("fix_sys_msgs", mFixSysMsgs);
    restoreSysMsgs("remake_sys_msgs", mRemakeSysMsgs);
    restoreSysMsgs("learn_sys_msgs", mLearnSysMsgs);
    
    // Restore labels
    if (session.contains("stats_cost_text")) mSessionStatsBtn->setText(session["stats_cost_text"].toString());
    if (session.contains("stats_eco_text")) mEcoLabel->setText(session["stats_eco_text"].toString());
    if (session.contains("stats_wait_text")) mTotalWaitLabel->setText(session["stats_wait_text"].toString());
    if (session.contains("stats_ctx_text")) mContextLabel->setText(session["stats_ctx_text"].toString());
    if (session.contains("stats_ctx_value")) mContextBar->setValue(session["stats_ctx_value"].toInt());

    if (session.contains("openrouter_fast_model")) {
        QString fast = session["openrouter_fast_model"].toString().trimmed();
        if (!fast.isEmpty()) mOpenRouterFastModel = fast;
    }
    if (session.contains("openrouter_better_model")) {
        QString better = session["openrouter_better_model"].toString().trimmed();
        if (!better.isEmpty()) mOpenRouterBetterModel = better;
    }
    if (session.contains("openrouter_active_slot")) {
        mActiveOpenRouterSlot = (session["openrouter_active_slot"].toInt() == 1) ? 1 : 0;
    }
    if (mOpenRouterFastBtn) mOpenRouterFastBtn->setChecked(mActiveOpenRouterSlot == 0);
    if (mOpenRouterBetterBtn) mOpenRouterBetterBtn->setChecked(mActiveOpenRouterSlot == 1);

    QString model = session["model"].toString();
    if (model.startsWith("openrouter:")) {
        // The OR model list is fetched asynchronously and is usually still empty
        // during the initial restore, so also stash the ID for populateOpenRouterCombo().
        QString orId = model.mid(QString("openrouter:").length());
        if (mActiveOpenRouterSlot == 0) mOpenRouterFastModel = orId;
        else mOpenRouterBetterModel = orId;

        int orIdx = mOpenRouterCombo->findData(orId);
        applyOpenRouterModelToCombo(orId, orIdx >= 0);
        if (orIdx < 0) {
            mPendingOpenRouterModel = orId;
        }
        mProviderOpenRouterRadio->setChecked(true);
    } else {
        const QString& slotModel = (mActiveOpenRouterSlot == 0) ? mOpenRouterFastModel : mOpenRouterBetterModel;
        applyOpenRouterModelToCombo(slotModel, false);
        int mainIdx = mModelCombo->findText(model);
        if (mainIdx >= 0) {
            mModelCombo->setCurrentIndex(mainIdx);
            mProviderDirectRadio->setChecked(true);
        }
    }
    updateOpenRouterSlotTooltips();
    
    if (session.contains("temperature")) {
        mTempSlider->setValue(session["temperature"].toInt());
    }

    if (session.contains("prompt_blocks") && session["prompt_blocks"].isArray()) {
        if (PromptNavBar* navBar = promptNavBar()) {
            Document* activeDoc = Main::instance()->documentManager()->activeDocument();
            if (activeDoc)
                navBar->restoreFromJsonArray(activeDoc, session["prompt_blocks"].toArray(), forceNavRestore);
        }
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

    // Refresh live stats from the Python backend so labels show current values
    tryUpdateSessionStats();
}

void AiAssistWidget::onDocumentSaved(Document* doc) {
    if (!doc) return;
    saveSessionFor(doc);
}

void AiAssistWidget::onDocumentShown(Document* doc, int pos, int selLen) {
    Q_UNUSED(pos);
    Q_UNUSED(selLen);
    
    if (!doc) return;

    // If switching to a different file, save the outgoing session first
    if (mLastActiveDocument && mLastActiveDocument != doc) {
        saveSessionFor(mLastActiveDocument);
    }

    // Switch context: clear fields then restore from sidecar if it exists
    if (doc != mLastActiveDocument) {
        clearSessionFields();
        QString jsonPath = sessionFilePath(doc);
        if (QFileInfo::exists(jsonPath)) {
            restoreSessionFor(jsonPath);
        }
    }

    mLastActiveDocument = doc;
}

void AiAssistWidget::clearSessionFields() {
    // Prompts and plans
    mGenPrompt->clear();
    mGenPlanOutput->clear();
    mGenUseKb->setChecked(false);
    mGenIncludeEnding->setChecked(true);
    mDesignPrompt->clear();
    mDesignPlanOutput->clear();
    mDesignUseKb->setChecked(true);
    mComposePrompt->clear();
    mComposePlanOutput->clear();
    mComposeUseKb->setChecked(true);
    mCustomPrompt->clear();
    mCustomUseKb->setChecked(true);
    mAppendPrompt->clear();
    mAppendUseKb->setChecked(true);
    mAutoAppendLog->clear();
    mAppendQueue.clear();
    mDictationBlockIndex = 0;
    
    mXPrompt->clear();
    mXUseKbCheck->setChecked(true);
    mXAutoExecuteCheck->setChecked(true);
    if (mXLeanPromptCheck) mXLeanPromptCheck->setChecked(false);
    if (mXAutoFixCheck) mXAutoFixCheck->setChecked(false);
    if (mXAutoFixAttemptsCombo) mXAutoFixAttemptsCombo->setCurrentIndex(0);
    mXAutoAppendCheck->setChecked(false);
    mXAutoAppendLog->clear();
    mXAppendQueue.clear();
    mXDictationBlockIndex = 0;
    mXAppendRadio->setChecked(true);
    
    mFixBlock->clear();
    mFixStackTrace->clear();
    mRemakeBlock->clear();
    mRemakePrompt->clear();
    mLearnHistory->clear();
    mLearnChatHistory.clear();
    mKbBlock->clear();
    mKbDescription->clear();
    mCompositionState.clear();

    // Stats
    mSessionStatsBtn->setText(tr("$0.00"));
    mEcoLabel->setText(tr("Eco: --"));
    mTotalWaitLabel->setText(tr("Wait: 0.0s"));
    mContextLabel->setText(tr("Ctx: 0k"));
    mContextBar->setValue(0);
    mFullStatusText.clear();
    mStatusBtn->setText(QString());
    mXLastNavEntryId = 0;
    mXLastNavDoc = nullptr;
}

PromptNavBar* AiAssistWidget::promptNavBar() const {
    MainWindow* mw = MainWindow::instance();
    if (!mw || !mw->multiEditor())
        return nullptr;
    return mw->multiEditor()->promptNavBar();
}

int AiAssistWidget::registerPromptNavBlock(Document* doc, const QString& mode, const QString& prompt,
                                           int insertPos, const QString& codeText, const QString& model) {
    if (PromptNavBar* navBar = promptNavBar())
        return navBar->addEntry(doc, mode, prompt, insertPos, codeText, model);
    return 0;
}

void AiAssistWidget::removePromptNavEntry(Document* doc, int entryId) {
    if (PromptNavBar* navBar = promptNavBar())
        navBar->removeEntry(doc, entryId);
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
        restoreSessionFor(fileName, true);
    }
}

void AiAssistWidget::onBootupClicked() {
    Main::instance()->documentManager()->create();
    Document* doc = Main::instance()->documentManager()->activeDocument();
    if (doc) {
        QTextCursor cursor(doc->textDocument());
        cursor.insertText(
            "//Run this to reference the default options of SuperCollider:\n"
            "o = Server.default.options;\n\n"
            "//Run this command to see all available output devices:\n"
            "ServerOptions.outDevices.inspect;\n\n"
            "//Then, set the exact name of the output device you'd like to use here:\n"
            "o.outDevice_(\"your-output-here\");\n\n"
            "//Do the same for input devices:\n"
            "ServerOptions.inDevices.inspect;\n"
            "o.inDevice_(\"your-input-here\");\n\n"
            "//Then, reboot the server\n"
            "Server.default.reboot;\n\n"
            "// If you run into too much trouble with sample rate mismatch and won't use inputs like a microphone, just the output, you can ignore the input bus for a quick work around:\n"
            "o.numInputBusChannels_(0);\n"
            "Server.default.reboot;\n"
        );
    }
}

void AiAssistWidget::onApiKeysClicked() {
    QDialog dlg(this);
    dlg.setWindowTitle(tr("Manage LLM API Keys"));
    dlg.resize(440, 220);

    QVBoxLayout* layout = new QVBoxLayout(&dlg);
    
    QFormLayout* form = new QFormLayout;
    QLineEdit* geminiInput = new QLineEdit;
    QLineEdit* anthropicInput = new QLineEdit;
    QLineEdit* openaiInput = new QLineEdit;
    QLineEdit* openrouterInput = new QLineEdit;
    QLineEdit* langchainInput = new QLineEdit;
    
    geminiInput->setEchoMode(QLineEdit::PasswordEchoOnEdit);
    anthropicInput->setEchoMode(QLineEdit::PasswordEchoOnEdit);
    openaiInput->setEchoMode(QLineEdit::PasswordEchoOnEdit);
    openrouterInput->setEchoMode(QLineEdit::PasswordEchoOnEdit);
    langchainInput->setEchoMode(QLineEdit::PasswordEchoOnEdit);

    form->addRow(tr("GEMINI_API_KEY:"), geminiInput);
    form->addRow(tr("ANTHROPIC_API_KEY:"), anthropicInput);
    form->addRow(tr("OPENAI_API_KEY:"), openaiInput);
    form->addRow(tr("OPENROUTER_API_KEY:"), openrouterInput);
    form->addRow(tr("LANGCHAIN_API_KEY:"), langchainInput);
    
    layout->addLayout(form);
    
    QString envPath = QFileInfo(backendScriptPath()).absolutePath() + QDir::separator() + ".env";
    QStringList existingLines;
    QFile file(envPath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        while (!in.atEnd()) {
            QString line = in.readLine();
            QString trimmed = line.trimmed();
            if (trimmed.startsWith(QChar(0xFEFF)))
                trimmed = trimmed.mid(1).trimmed();
            
            existingLines.append(line);
            
            int eqIdx = trimmed.indexOf('=');
            if (eqIdx == -1) continue;
            QString k = trimmed.left(eqIdx).trimmed();
            QString v = trimmed.mid(eqIdx + 1).trimmed();
            if ((v.startsWith('"') && v.endsWith('"') && v.length() >= 2) ||
                (v.startsWith(QChar('\'')) && v.endsWith(QChar('\'')) && v.length() >= 2)) {
                v = v.mid(1, v.length() - 2).trimmed();
            }
            
            if (k.compare("GEMINI_API_KEY", Qt::CaseInsensitive) == 0 ||
                k.compare("GOOGLE_API_KEY", Qt::CaseInsensitive) == 0) {
                geminiInput->setText(v);
            } else if (k.compare("ANTHROPIC_API_KEY", Qt::CaseInsensitive) == 0) {
                anthropicInput->setText(v);
            } else if (k.compare("OPENAI_API_KEY", Qt::CaseInsensitive) == 0) {
                openaiInput->setText(v);
            } else if (k.compare("OPENROUTER_API_KEY", Qt::CaseInsensitive) == 0) {
                openrouterInput->setText(v);
            } else if (k.compare("LANGCHAIN_API_KEY", Qt::CaseInsensitive) == 0) {
                langchainInput->setText(v);
            }
        }
        file.close();
    }
    
    if (geminiInput->text().isEmpty()) {
        QString v = QString::fromLocal8Bit(qgetenv("GEMINI_API_KEY")).trimmed();
        if (v.isEmpty()) v = QString::fromLocal8Bit(qgetenv("GOOGLE_API_KEY")).trimmed();
        geminiInput->setText(v);
    }
    if (anthropicInput->text().isEmpty()) {
        anthropicInput->setText(QString::fromLocal8Bit(qgetenv("ANTHROPIC_API_KEY")).trimmed());
    }
    if (openaiInput->text().isEmpty()) {
        openaiInput->setText(QString::fromLocal8Bit(qgetenv("OPENAI_API_KEY")).trimmed());
    }
    if (openrouterInput->text().isEmpty()) {
        openrouterInput->setText(QString::fromLocal8Bit(qgetenv("OPENROUTER_API_KEY")).trimmed());
    }
    if (langchainInput->text().isEmpty()) {
        langchainInput->setText(QString::fromLocal8Bit(qgetenv("LANGCHAIN_API_KEY")).trimmed());
    }
    
    QHBoxLayout* btns = new QHBoxLayout;
    btns->addStretch();
    QPushButton* cancelBtn = new QPushButton(tr("Cancel"));
    QPushButton* saveBtn = new QPushButton(tr("Save"));
    saveBtn->setDefault(true);
    btns->addWidget(cancelBtn);
    btns->addWidget(saveBtn);
    layout->addLayout(btns);
    
    connect(cancelBtn, &QPushButton::clicked, &dlg, &QDialog::reject);
    connect(saveBtn, &QPushButton::clicked, [&]() {
        QMap<QString, QString> newKeys;
        newKeys["GEMINI_API_KEY"] = geminiInput->text().trimmed();
        newKeys["ANTHROPIC_API_KEY"] = anthropicInput->text().trimmed();
        newKeys["OPENAI_API_KEY"] = openaiInput->text().trimmed();
        newKeys["OPENROUTER_API_KEY"] = openrouterInput->text().trimmed();
        newKeys["LANGCHAIN_API_KEY"] = langchainInput->text().trimmed();

        QStringList updatedLines;
        QSet<QString> handledKeys;
        for (const QString& rawLine : existingLines) {
            QString trimmed = rawLine.trimmed();
            if (trimmed.startsWith(QChar(0xFEFF)))
                trimmed = trimmed.mid(1).trimmed();
            int eqIdx = trimmed.indexOf('=');
            if (eqIdx != -1) {
                QString k = trimmed.left(eqIdx).trimmed().toUpper();
                if (newKeys.contains(k)) {
                    handledKeys.insert(k);
                    QString val = newKeys[k];
                    if (!val.isEmpty()) {
                        updatedLines.append(QString("%1=\"%2\"").arg(k, val));
                    }
                    continue;
                }
            }
            updatedLines.append(rawLine);
        }

        for (auto it = newKeys.begin(); it != newKeys.end(); ++it) {
            if (!handledKeys.contains(it.key()) && !it.value().isEmpty()) {
                updatedLines.append(QString("%1=\"%2\"").arg(it.key(), it.value()));
            }
        }

        QFile outFile(envPath);
        if (outFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
            QTextStream out(&outFile);
            for (const QString& l : updatedLines) {
                out << l << "\n";
            }
            outFile.close();

            for (auto it = newKeys.begin(); it != newKeys.end(); ++it) {
                qputenv(it.key().toUtf8().constData(), it.value().toUtf8());
            }

            if (mDaemonProcess) {
                mDaemonProcess->kill();
                mDaemonProcess->waitForFinished(500);
                delete mDaemonProcess;
                mDaemonProcess = nullptr;
                startDaemon();
            }

            QMessageBox::information(&dlg, tr("Saved"), tr("API keys updated globally."));
            dlg.accept();
        } else {
            QMessageBox::critical(&dlg, tr("Error"), tr("Could not write to .env file at ") + envPath);
        }
    });

    dlg.exec();
}

void AiAssistWidget::onDocumentClosed(Document* doc) {
    if (!doc) return;

    bool isActive = (doc == mLastActiveDocument);
    bool hadContent = isActive && hasSessionContent();
    QString fp = doc->filePath();

    // Clear fields and reset tracker if the closed document was the active one
    if (isActive) {
        clearSessionFields();
        mLastActiveDocument = nullptr;
    }

    // Warn if the document was unsaved and had session content
    if (fp.isEmpty() && hadContent) {
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

    // Tab 2: Compose (Fixed Timeline)
    mTabWidget->addTab(createComposeTab(), tr("Compose"));

    // Tab 3: Design (MIDI)
    mTabWidget->addTab(createDesignTab(), tr("Design"));

    // Tab 4: Custom
    mTabWidget->addTab(createCustomTab(), tr("Custom"));

    // Tab 5: Append
    mTabWidget->addTab(createAppendTab(), tr("Append"));

    // Tab 6: Cross-Append (multi-mode voice-driven performance)
    mTabWidget->addTab(createCrossAppendTab(), tr("X-Append"));

    // Tab 3: Fix
    mTabWidget->addTab(createFixTab(), tr("Fix"));

    // Tab 4: Remake
    mTabWidget->addTab(createRemakeTab(), tr("Remake"));

    // Tab 5: Learn -> Ask
    mTabWidget->addTab(createLearnTab(), tr("Ask"));

    // Tab 6: Add to KB
    mTabWidget->addTab(createAddKbTab(), tr("Add to KB"));

    // Initialize per-tab system message defaults
    mGenPlanSysMsgs = QStringList{"base/system-instruction.md", "generate/system-instruction-oneshot-plan.md"};
    mGenCodeSysMsgs = QStringList{"base/system-instruction.md", "improvements/system-improvements.md", "generate/system-instruction-oneshot-gen.md"};
    mDesignPlanSysMsgs = QStringList{"base/system-instruction.md", "design/system-instruction-oneshot-plan-design.md"};
    mDesignCodeSysMsgs = QStringList{"base/system-instruction.md", "improvements/system-improvements.md", "design/system-instruction-oneshot-gen-design.md"};
    mComposePlanSysMsgs = QStringList{"base/system-instruction.md", "compose/system-instruction-compose-plan.md"};
    mComposeCodeSysMsgs = QStringList{"base/system-instruction.md", "improvements/system-improvements.md", "compose/system-instruction-compose-implement.md"};
    mAppendSysMsgs = QStringList{"base/system-instruction.md", "improvements/system-improvements.md", "append/system-instruction-incremental.md"};
    mFixSysMsgs = QStringList{"base/system-instruction.md", "improvements/system-improvements.md", "fix/system-instruction-fix.md"};
    mRemakeSysMsgs = QStringList{"base/system-instruction.md", "improvements/system-improvements.md", "remake/system-instruction-remake.md"};
    mLearnSysMsgs = QStringList{"base/system-instruction.md", "learn/system-instruction-learn.md"};
    // mCustomSelectedSysMsgs stays empty by default

    // Override defaults from persistent JSON file
    loadSysMsgDefaults();
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
    mGenPlanSysBtn = new QPushButton(tr("Plan Msgs"));
    connect(mGenPlanSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onGenPlanSysClicked);
    planRow->addWidget(mGenPlanSysBtn);
    mGenCodeSysBtn = new QPushButton(tr("Code Msgs"));
    connect(mGenCodeSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onGenCodeSysClicked);
    planRow->addWidget(mGenCodeSysBtn);
    
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
    mDesignPlanSysBtn = new QPushButton(tr("Plan Msgs"));
    connect(mDesignPlanSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onDesignPlanSysClicked);
    planRow->addWidget(mDesignPlanSysBtn);
    mDesignCodeSysBtn = new QPushButton(tr("Code Msgs"));
    connect(mDesignCodeSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onDesignCodeSysClicked);
    planRow->addWidget(mDesignCodeSysBtn);
    
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

QWidget* AiAssistWidget::createComposeTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Composition prompt (absolute time):")));
    mComposePrompt = new QPlainTextEdit;
    mComposePrompt->setPlaceholderText(tr("Describe a fixed-length composition with explicit timing..."));
    mComposePrompt->setMaximumHeight(80);
    layout->addWidget(mComposePrompt);

    QHBoxLayout* planRow = new QHBoxLayout;
    mComposeUseKb = new QCheckBox(tr("Use knowledge base"));
    mComposeUseKb->setChecked(true);
    planRow->addWidget(mComposeUseKb);

    planRow->addStretch();
    mComposePlanSysBtn = new QPushButton(tr("Plan Msgs"));
    connect(mComposePlanSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onComposePlanSysClicked);
    planRow->addWidget(mComposePlanSysBtn);
    mComposeCodeSysBtn = new QPushButton(tr("Code Msgs"));
    connect(mComposeCodeSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onComposeCodeSysClicked);
    planRow->addWidget(mComposeCodeSysBtn);

    mComposePlanBtn = new QPushButton(tr("Plan"));
    connect(mComposePlanBtn, &QPushButton::clicked, this, &AiAssistWidget::onComposePlanClicked);
    planRow->addWidget(mComposePlanBtn);
    layout->addLayout(planRow);

    layout->addWidget(new QLabel(tr("Composition plan — timeline & cue sheet (editable):")));
    mComposePlanOutput = new QPlainTextEdit;
    mComposePlanOutput->setPlaceholderText(tr("Cue sheet will appear here after clicking Plan..."));
    layout->addWidget(mComposePlanOutput, 1);

    mComposeGenerateBtn = new QPushButton(tr("Compose"));
    connect(mComposeGenerateBtn, &QPushButton::clicked, this, &AiAssistWidget::onComposeGenerateClicked);
    layout->addWidget(mComposeGenerateBtn);

    return tab;
}

QWidget* AiAssistWidget::createCustomTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("Custom Prompt:")));
    mCustomPrompt = new QPlainTextEdit;
    mCustomPrompt->setPlaceholderText(tr("Type your prompt here..."));
    layout->addWidget(mCustomPrompt, 1);

    QHBoxLayout* row = new QHBoxLayout;
    mCustomUseKb = new QCheckBox(tr("Use knowledge base"));
    mCustomUseKb->setChecked(false);
    row->addWidget(mCustomUseKb);
    
    row->addStretch();
    mCustomSysBtn = new QPushButton(tr("Edit System Messages"));
    connect(mCustomSysBtn, &QPushButton::clicked, this, &AiAssistWidget::onCustomSysEditClicked);
    row->addWidget(mCustomSysBtn);
    layout->addLayout(row);

    mCustomGenerateBtn = new QPushButton(tr("Generate"));
    connect(mCustomGenerateBtn, &QPushButton::clicked, this, &AiAssistWidget::onCustomGenerateClicked);
    layout->addWidget(mCustomGenerateBtn);

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
    
    mAppendUseKb = new QCheckBox(tr("Use KB"));
    mAppendUseKb->setChecked(true);
    mAppendUseKb->setToolTip(tr("Include knowledge base RAG context in the prompt"));
    btnRow->addWidget(mAppendUseKb);

    mAutoAppendCheck = new QCheckBox(tr("Auto-Append"));
    mAutoAppendCheck->setToolTip(tr("Automatically send each dictation block through the Append pipeline"));
    btnRow->addWidget(mAutoAppendCheck);
    
    btnRow->addStretch();
    mSystemMsgBtnApp = new QPushButton(tr("System Messages"));
    connect(mSystemMsgBtnApp, &QPushButton::clicked, this, &AiAssistWidget::onAppSysClicked);
    btnRow->addWidget(mSystemMsgBtnApp);

    mAppendBtn = new QPushButton(tr("Append"));
    connect(mAppendBtn, &QPushButton::clicked, this, &AiAssistWidget::onAppendClicked);
    btnRow->addWidget(mAppendBtn);

    layout->addLayout(btnRow);

    // --- Dictation controls row (second row) ---
    QHBoxLayout* dictRow = new QHBoxLayout;
    dictRow->setContentsMargins(0, 0, 0, 0);

    // Dictation Language selector
    mDictLangCombo = new QComboBox;
    mDictLangCombo->addItem(tr("Português (BR)"), QStringLiteral("pt"));
    mDictLangCombo->addItem(tr("English"), QStringLiteral("en"));
    mDictLangCombo->addItem(tr("Español"), QStringLiteral("es"));
    mDictLangCombo->addItem(tr("Auto-detect"), QStringLiteral(""));
    mDictLangCombo->setCurrentIndex(0); // Default to pt-BR
    mDictLangCombo->setToolTip(tr("Dictation language for speech recognition"));
    dictRow->addWidget(mDictLangCombo);

    // Dictation Model selector
    mDictModelCombo = new QComboBox;
    mDictModelCombo->addItem(tr("large-v3-turbo (best)"), QStringLiteral("large-v3-turbo"));
    mDictModelCombo->addItem(tr("distil-large-v3 (EN only, 2x fast)"), QStringLiteral("distil-large-v3"));
    mDictModelCombo->addItem(tr("medium (accurate)"), QStringLiteral("medium"));
    mDictModelCombo->addItem(tr("small (balanced)"), QStringLiteral("small"));
    mDictModelCombo->addItem(tr("base (fast)"), QStringLiteral("base"));
    mDictModelCombo->addItem(tr("tiny (fastest)"), QStringLiteral("tiny"));
    mDictModelCombo->setCurrentIndex(0); // Default to large-v3-turbo
    mDictModelCombo->setToolTip(tr("Whisper model size — larger = more accurate but slower and uses more RAM"));
    dictRow->addWidget(mDictModelCombo);

    dictRow->addStretch();

    mDictateBtn = new QPushButton(tr("\xF0\x9F\x8E\xA4"));  // 🎤 emoji
    mDictateBtn->setFixedWidth(32);
    mDictateBtn->setToolTip(tr("Voice dictation — click to start/stop microphone transcription"));
    mDictateBtn->setStyleSheet(
        "QPushButton { font-size: 14px; padding: 2px; }"
        "QPushButton:checked { background-color: #c0392b; border: 2px solid #e74c3c; }");
    mDictateBtn->setCheckable(true);
    connect(mDictateBtn, &QPushButton::clicked, this, &AiAssistWidget::onDictateToggled);
    dictRow->addWidget(mDictateBtn);

    mDictateMuteBtn = new QPushButton(tr("\xF0\x9F\x94\x87"));  // 🔇 emoji
    mDictateMuteBtn->setFixedWidth(32);
    mDictateMuteBtn->setToolTip(tr("Mute dictation (pause transcription without stopping)"));
    mDictateMuteBtn->setStyleSheet(
        "QPushButton { font-size: 14px; padding: 2px; }"
        "QPushButton:checked { background-color: #f39c12; border: 2px solid #e67e22; }");
    mDictateMuteBtn->setCheckable(true);
    connect(mDictateMuteBtn, &QPushButton::clicked, this, &AiAssistWidget::onDictateMuteToggled);
    dictRow->addWidget(mDictateMuteBtn);

    layout->addLayout(dictRow);

    // --- Auto-Append Activity Log ---
    QLabel* logLabel = new QLabel(tr("Auto-Append Log:"));
    logLabel->setStyleSheet("QLabel { color: #888; font-size: 9px; margin-top: 2px; }");
    layout->addWidget(logLabel);

    mAutoAppendLog = new QTextEdit;
    mAutoAppendLog->setReadOnly(true);
    mAutoAppendLog->setMaximumHeight(100);
    mAutoAppendLog->setStyleSheet(
        "QTextEdit { background-color: #1a1a2e; color: #aaa; font-family: 'Consolas', 'Courier New', monospace; font-size: 9px; border: 1px solid #333; }");
    mAutoAppendLog->setPlaceholderText(tr("Auto-append pipeline activity will appear here..."));
    layout->addWidget(mAutoAppendLog);

    return tab;
}

// "append" -> "Append" (used for validation button labels / log messages)
static QString xModeLabel(const QString& mode) {
    if (mode.isEmpty()) return mode;
    return mode.left(1).toUpper() + mode.mid(1);
}

QWidget* AiAssistWidget::createCrossAppendTab() {
    QWidget* tab = new QWidget;
    QVBoxLayout* layout = new QVBoxLayout(tab);
    layout->setContentsMargins(4, 4, 4, 4);

    layout->addWidget(new QLabel(tr("What should be added to the performance?")));
    mXPrompt = new QPlainTextEdit;
    mXPrompt->setPlaceholderText(tr("Speak or type — routed through the selected mode..."));
    layout->addWidget(mXPrompt, 1);

    // --- Validation buttons (Send / RAG with "P" presets) + mode selection ---
    // Grid columns: 0 = row label, 1..4 = Append / Compose / Design / Generate.
    // Each Send/RAG cell sits directly above its mode's radio button.
    loadXTestPrompts();
    QGridLayout* modeGrid = new QGridLayout;
    modeGrid->setContentsMargins(0, 0, 0, 0);
    modeGrid->setHorizontalSpacing(6);
    modeGrid->setVerticalSpacing(2);

    const QStringList xModes = { "append", "compose", "design", "generate" };
    for (int i = 0; i < xModes.size(); ++i) {
        const QString& m = xModes[i];
        const QString label = xModeLabel(m);
        modeGrid->addWidget(createXTestCell("send", m, tr("Send %1").arg(label)), 0, i + 1);
        modeGrid->addWidget(createXTestCell("rag", m, tr("RAG %1").arg(label)), 1, i + 1);
    }

    modeGrid->addWidget(new QLabel(tr("Mode:")), 2, 0);

    QButtonGroup* modeGroup = new QButtonGroup(this);
    mXAppendRadio = new QRadioButton(tr("Append"));
    mXAppendRadio->setToolTip(tr("Incremental block — adds a single element to the running composition"));
    mXAppendRadio->setChecked(true);
    modeGroup->addButton(mXAppendRadio);
    modeGrid->addWidget(mXAppendRadio, 2, 1);

    mXComposeRadio = new QRadioButton(tr("Compose"));
    mXComposeRadio->setToolTip(tr("Fixed-timeline composition — plans and implements a full piece with movements"));
    modeGroup->addButton(mXComposeRadio);
    modeGrid->addWidget(mXComposeRadio, 2, 2);

    mXDesignRadio = new QRadioButton(tr("Design"));
    mXDesignRadio->setToolTip(tr("Synthesizer design — creates a playable MIDI instrument"));
    modeGroup->addButton(mXDesignRadio);
    modeGrid->addWidget(mXDesignRadio, 2, 3);

    mXGenerateRadio = new QRadioButton(tr("Generate"));
    mXGenerateRadio->setToolTip(tr("Open-ended generation — creates live-coding blocks"));
    modeGroup->addButton(mXGenerateRadio);
    modeGrid->addWidget(mXGenerateRadio, 2, 4);

    for (int c = 1; c <= 4; ++c)
        modeGrid->setColumnStretch(c, 1);

    connect(mXAppendRadio, &QRadioButton::toggled, this, &AiAssistWidget::onXAppendModeChanged);
    connect(mXComposeRadio, &QRadioButton::toggled, this, &AiAssistWidget::onXAppendModeChanged);
    connect(mXDesignRadio, &QRadioButton::toggled, this, &AiAssistWidget::onXAppendModeChanged);
    connect(mXGenerateRadio, &QRadioButton::toggled, this, &AiAssistWidget::onXAppendModeChanged);

    layout->addLayout(modeGrid);

    // --- Controls row ---
    QHBoxLayout* btnRow = new QHBoxLayout;
    btnRow->setSpacing(6);

    mXAutoExecuteCheck = new QCheckBox(tr("Auto-Execute"));
    mXAutoExecuteCheck->setToolTip(tr("Validate incoming code on the parallel validation server and auto-evaluate in sclang (All modes)"));
    mXAutoExecuteCheck->setChecked(true);
    btnRow->addWidget(mXAutoExecuteCheck);

    mXUseKbCheck = new QCheckBox(tr("Use KB"));
    mXUseKbCheck->setChecked(true);
    mXUseKbCheck->setToolTip(tr("Include knowledge base RAG context in the prompt"));
    btnRow->addWidget(mXUseKbCheck);

    mXLeanPromptCheck = new QCheckBox(tr("Lean Prompt"));
    mXLeanPromptCheck->setChecked(false);
    mXLeanPromptCheck->setToolTip(tr("Use a single-step lean prompt for Compose, Design, and Generate (skipping the separate Plan step, like Append mode). Does not affect original prompts or other tabs."));
    btnRow->addWidget(mXLeanPromptCheck);

    mXAutoFixCheck = new QCheckBox(tr("Auto Fix"));
    mXAutoFixCheck->setChecked(false);
    mXAutoFixCheck->setToolTip(tr("When parallel validation fails, automatically send the failed block and stack trace through the Fix pipeline and re-validate before falling back to RAG"));
    btnRow->addWidget(mXAutoFixCheck);

    mXAutoFixAttemptsCombo = new QComboBox;
    for (int n = 1; n <= 5; ++n) {
        mXAutoFixAttemptsCombo->addItem(QString::number(n), n);
    }
    mXAutoFixAttemptsCombo->setCurrentIndex(0);
    mXAutoFixAttemptsCombo->setFixedWidth(42);
    mXAutoFixAttemptsCombo->setToolTip(tr("Maximum number of Auto Fix attempts (1-5) to generate valid code before falling back to the RAG failsafe"));
    btnRow->addWidget(mXAutoFixAttemptsCombo);

    mXAutoAppendCheck = new QCheckBox(tr("Auto-Append"));
    mXAutoAppendCheck->setToolTip(tr("Automatically route each dictation utterance through the selected mode"));
    btnRow->addWidget(mXAutoAppendCheck);

    btnRow->addStretch();

    mXAppendBtn = new QPushButton(tr("Submit"));
    connect(mXAppendBtn, &QPushButton::clicked, this, &AiAssistWidget::onXAppendClicked);
    btnRow->addWidget(mXAppendBtn);

    layout->addLayout(btnRow);

    // --- Dictation controls row ---
    QHBoxLayout* dictRow = new QHBoxLayout;
    dictRow->setContentsMargins(0, 0, 0, 0);

    mXDictLangCombo = new QComboBox;
    mXDictLangCombo->addItem(tr("Português (BR)"), QStringLiteral("pt"));
    mXDictLangCombo->addItem(tr("English"), QStringLiteral("en"));
    mXDictLangCombo->addItem(tr("Español"), QStringLiteral("es"));
    mXDictLangCombo->addItem(tr("Auto-detect"), QStringLiteral(""));
    mXDictLangCombo->setCurrentIndex(0);
    mXDictLangCombo->setToolTip(tr("Dictation language for speech recognition"));
    dictRow->addWidget(mXDictLangCombo);

    mXDictModelCombo = new QComboBox;
    mXDictModelCombo->addItem(tr("large-v3-turbo (best)"), QStringLiteral("large-v3-turbo"));
    mXDictModelCombo->addItem(tr("distil-large-v3 (EN only, 2x fast)"), QStringLiteral("distil-large-v3"));
    mXDictModelCombo->addItem(tr("medium (accurate)"), QStringLiteral("medium"));
    mXDictModelCombo->addItem(tr("small (balanced)"), QStringLiteral("small"));
    mXDictModelCombo->addItem(tr("base (fast)"), QStringLiteral("base"));
    mXDictModelCombo->addItem(tr("tiny (fastest)"), QStringLiteral("tiny"));
    mXDictModelCombo->setCurrentIndex(0);
    mXDictModelCombo->setToolTip(tr("Whisper model size — larger = more accurate but slower"));
    dictRow->addWidget(mXDictModelCombo);

    dictRow->addStretch();

    mXDictateBtn = new QPushButton(tr("\xF0\x9F\x8E\xA4"));  // 🎤 emoji
    mXDictateBtn->setFixedWidth(32);
    mXDictateBtn->setToolTip(tr("Voice dictation — click to start/stop microphone transcription"));
    mXDictateBtn->setStyleSheet(
        "QPushButton { font-size: 14px; padding: 2px; }"
        "QPushButton:checked { background-color: #c0392b; border: 2px solid #e74c3c; }");
    mXDictateBtn->setCheckable(true);
    connect(mXDictateBtn, &QPushButton::clicked, this, &AiAssistWidget::onXDictateToggled);
    dictRow->addWidget(mXDictateBtn);

    mXDictateMuteBtn = new QPushButton(tr("\xF0\x9F\x94\x87"));  // 🔇 emoji
    mXDictateMuteBtn->setFixedWidth(32);
    mXDictateMuteBtn->setToolTip(tr("Mute dictation (pause transcription without stopping)"));
    mXDictateMuteBtn->setStyleSheet(
        "QPushButton { font-size: 14px; padding: 2px; }"
        "QPushButton:checked { background-color: #f39c12; border: 2px solid #e67e22; }");
    mXDictateMuteBtn->setCheckable(true);
    connect(mXDictateMuteBtn, &QPushButton::clicked, this, &AiAssistWidget::onXDictateMuteToggled);
    dictRow->addWidget(mXDictateMuteBtn);

    layout->addLayout(dictRow);

    // --- Parallel Validation Server status & observable console ---
    QHBoxLayout* valRow = new QHBoxLayout;
    valRow->setContentsMargins(0, 2, 0, 0);
    valRow->setSpacing(4);

    QLabel* valTitle = new QLabel(tr("Val Server (57111):"));
    valTitle->setStyleSheet("QLabel { color: #888; font-size: 9px; font-weight: bold; }");
    valRow->addWidget(valTitle);

    mValServerStatusLabel = new QLabel(tr("Booting..."));
    mValServerStatusLabel->setStyleSheet(
        "QLabel { background-color: #2c3e50; color: #f39c12; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
    mValServerStatusLabel->setToolTip(tr("Parallel SuperCollider validation server status (isolated sclang + muted server on UDP port 57111)"));
    valRow->addWidget(mValServerStatusLabel);

    valRow->addStretch();

    mValServerConsoleToggleBtn = new QPushButton(tr("Val Console"));
    mValServerConsoleToggleBtn->setCheckable(true);
    mValServerConsoleToggleBtn->setChecked(false);
    mValServerConsoleToggleBtn->setStyleSheet("QPushButton { font-size: 9px; padding: 1px 6px; }");
    mValServerConsoleToggleBtn->setToolTip(tr("Show/hide live stdout & stderr from the parallel validation server"));
    valRow->addWidget(mValServerConsoleToggleBtn);

    mValServerRestartBtn = new QPushButton(tr("Restart Val"));
    mValServerRestartBtn->setStyleSheet("QPushButton { font-size: 9px; padding: 1px 6px; }");
    mValServerRestartBtn->setToolTip(tr("Restart the parallel SuperCollider validation server"));
    connect(mValServerRestartBtn, &QPushButton::clicked, this, [this]() {
        mXAutoAppendLog->append("<span style='color:#f39c12;'>[VAL-SERVER]</span> Restarting parallel validation server...");
        stopValidationServer();
        startValidationServer();
    });
    valRow->addWidget(mValServerRestartBtn);

    layout->addLayout(valRow);

    mValServerConsole = new QTextEdit;
    mValServerConsole->setReadOnly(true);
    mValServerConsole->setMaximumHeight(95);
    mValServerConsole->setVisible(false);
    mValServerConsole->setStyleSheet(
        "QTextEdit { background-color: #111822; color: #7fb3d5; font-family: 'Consolas', 'Courier New', monospace; font-size: 9px; border: 1px solid #2c3e50; }");
    mValServerConsole->setPlaceholderText(tr("Parallel validation server (port 57111) output will appear here..."));
    connect(mValServerConsoleToggleBtn, &QPushButton::toggled, mValServerConsole, &QWidget::setVisible);
    layout->addWidget(mValServerConsole);

    // --- Activity Log ---
    QLabel* logLabel = new QLabel(tr("Cross-Append Log:"));
    logLabel->setStyleSheet("QLabel { color: #888; font-size: 9px; margin-top: 2px; }");
    layout->addWidget(logLabel);

    mXAutoAppendLog = new QTextEdit;
    mXAutoAppendLog->setReadOnly(true);
    mXAutoAppendLog->setMaximumHeight(120);
    mXAutoAppendLog->setStyleSheet(
        "QTextEdit { background-color: #1a1a2e; color: #aaa; font-family: 'Consolas', 'Courier New', monospace; font-size: 9px; border: 1px solid #333; }");
    mXAutoAppendLog->setPlaceholderText(tr("Cross-append pipeline activity will appear here..."));
    layout->addWidget(mXAutoAppendLog);

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
    bool isError = false;
    if (text.contains("WARNING:", Qt::CaseInsensitive) || text.contains("INFO:", Qt::CaseInsensitive)) {
        // Ignore warnings and info logs
        isError = false;
    } else if (text.contains("ERROR:", Qt::CaseInsensitive)
        || text.contains("Exception", Qt::CaseSensitive)
        || text.contains("syntax error", Qt::CaseInsensitive)
        || text.startsWith("!")) {
        isError = true;
    }
    
    if (isError) {
        // Always accumulate error text first so Fix tab & Auto-Fix have the full trace
        if (mLastStackTrace.length() > 4000)
            mLastStackTrace.clear(); // Prevent unbounded growth
        mLastStackTrace += text;
        updateLatestBlockFields();

        if (mWaitingForErrorCheck && !mRagFallbackCode.isEmpty()) {
            mWaitingForErrorCheck = false;
            mErrorCheckTimer->stop();

            // If this is an X-Append evaluation with Auto-Fix enabled and attempts remaining,
            // defer the RAG failsafe and route through Auto-Fix instead (waiting 80ms to collect
            // all lines of the stack trace from sclang/scsynth).
            if (mXErrorCheckInFlight && mXAutoFixCheck && mXAutoFixCheck->isChecked()
                && mXCurrentFixAttempt < mXCurrentMaxFixAttempts) {
                if (mXPostErrorFixTimer)
                    mXPostErrorFixTimer->start(80);
                return;
            }

            mXErrorCheckInFlight = false;
            applyRagFallback();
        }
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
    if (mDesignPlanBtn) mDesignPlanBtn->setEnabled(!processing);
    if (mDesignGenerateBtn) mDesignGenerateBtn->setEnabled(!processing);
    mComposePlanBtn->setEnabled(!processing);
    mComposeGenerateBtn->setEnabled(!processing);
    mCustomGenerateBtn->setEnabled(!processing);
    mAppendBtn->setEnabled(!processing);
    if (mXAppendBtn) mXAppendBtn->setEnabled(!processing);
    mFixBtn->setEnabled(!processing);
    mRemakeBtn->setEnabled(!processing);
    mLearnSendBtn->setEnabled(!processing);
    mKbAddBtn->setEnabled(!processing);
    mKbConsumeBtn->setEnabled(!processing);
    updateCancelButtonState();
}

void AiAssistWidget::updateCancelButtonState() {
    if (!mCancelBtn) return;
    const bool active = mDaemonBusy
                     || (mCurrentProcess != nullptr)
                     || mValidationBusy
                     || mXErrorCheckInFlight
                     || mWaitingForErrorCheck
                     || !mAppendQueue.isEmpty()
                     || !mXAppendQueue.isEmpty();
    mCancelBtn->setEnabled(active);
}

void AiAssistWidget::onCancelClicked() {
    const bool hasActiveWork = mDaemonBusy
        || (mCurrentProcess != nullptr)
        || mValidationBusy
        || mXErrorCheckInFlight
        || mWaitingForErrorCheck
        || !mAppendQueue.isEmpty()
        || !mXAppendQueue.isEmpty();
    if (!hasActiveWork) {
        setProcessingState(false);
        return;
    }

    const int cancelledReqId = mActiveRequestId;
    mActiveRequestId = 0;
    mCurrentCallback = nullptr;
    mDaemonBusy = false;

    mAppendQueue.clear();
    mXAppendQueue.clear();
    mRagVerifyInFlight = false;

    if (mErrorCheckTimer) {
        mErrorCheckTimer->stop();
    }
    mWaitingForErrorCheck = false;
    mXErrorCheckInFlight = false;
    mXLastInsertedChunk.clear();
    mRagFallbackCode.clear();
    mPendingFallbackMode.clear();

    if (mValidationBusy) {
        mValidationBusy = false;
        mValidationCallback = nullptr;
        if (mValidationTimeoutTimer) {
            mValidationTimeoutTimer->stop();
        }
        if (mValServerStatusLabel) {
            mValServerStatusLabel->setText(tr("Cancelled"));
            mValServerStatusLabel->setStyleSheet(
                "QLabel { background-color: #2c3e50; color: #f39c12; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
        }
    }

    if (mXActivePromptId != 0) {
        finishXPromptTimer(QStringLiteral("#95a5a6"));
    }

    if (mCurrentProcess) {
        QProcess* proc = mCurrentProcess;
        mCurrentProcess = nullptr;
        disconnect(proc, nullptr, this, nullptr);
        proc->kill();
        proc->deleteLater();
    }

    if (mDaemonProcess && mDaemonProcess->state() == QProcess::Running) {
        QJsonObject cancelCmd;
        cancelCmd["command"] = QStringLiteral("cancel");
        if (cancelledReqId != 0) {
            cancelCmd["request_id"] = cancelledReqId;
        }
        mDaemonProcess->write(QJsonDocument(cancelCmd).toJson(QJsonDocument::Compact) + "\n");
    }

    setProcessingState(false);
    mFullStatusText = tr("Cancelled");
    mStatusBtn->setText(mFullStatusText);
    if (mAutoAppendLog) {
        mAutoAppendLog->append(QString("<span style='color:#e67e22;'>[CANCELLED]</span> Prompt cancelled by user."));
    }
    if (mXAutoAppendLog) {
        mXAutoAppendLog->append(QString("<span style='color:#e67e22;'>[CANCELLED]</span> Prompt cancelled by user."));
    }
    qDebug() << "[AiAssist] Prompt cancelled by user, request_id:" << cancelledReqId;
}

QJsonObject AiAssistWidget::basePayload() const {
    QJsonObject data;
    Document* doc = Main::instance()->documentManager()->activeDocument();
    if (doc) {
        data["active_file"] = doc->filePath();
    }
    data["model"] = currentModelKey();
    data["temperature"] = mTempSlider->value() / 10.0;
    data["thinking"] = mThinkingCombo->currentData().toInt();
    return data;
}

void AiAssistWidget::startDaemon() {
    if (mDaemonProcess) return;

    mDaemonProcess = new QProcess(this);
    mDaemonOutputBuffer.clear();
    mDaemonReady = false;
    mDaemonBusy = false;

    QString scriptPath = backendScriptPath();
    mDaemonProcess->setWorkingDirectory(QFileInfo(scriptPath).absolutePath());

    connect(mDaemonProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &AiAssistWidget::onDaemonFinished);

    connect(mDaemonProcess, &QProcess::readyReadStandardError, this, [this]() {
        if (!mDaemonProcess) return;
        
        // ALWAYS read the buffer to prevent IPC pipe deadlock!
        // If we don't read it, the OS pipe buffer fills up and Python's print() calls block forever.
        QByteArray err = mDaemonProcess->readAllStandardError();
        
        // Skip updating the UI status text while an API call is in progress
        // (prevents RealtimeSTT prints like "speak now" from overwriting
        //  the "Processing..." or result status text)
        if (mDaemonBusy) return;
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

    connect(mDaemonProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        if (!mDaemonProcess) return;
        mDaemonOutputBuffer.append(mDaemonProcess->readAllStandardOutput());
        
        // Process newline-delimited JSON
        int newlineIdx;
        while ((newlineIdx = mDaemonOutputBuffer.indexOf('\n')) != -1) {
            QByteArray line = mDaemonOutputBuffer.left(newlineIdx);
            mDaemonOutputBuffer.remove(0, newlineIdx + 1);
            if (!line.trimmed().isEmpty()) {
                handleDaemonResponse(line);
            }
        }
    });

    mFullStatusText = tr("Starting AI daemon...");
    mStatusBtn->setText(mFullStatusText);
    
    QStringList args;
    args << scriptPath << "serve";
    qDebug() << "[AutoAppend] Starting daemon:" << pythonPath() << args;
    mDaemonProcess->start(pythonPath(), args);
    qDebug() << "[AutoAppend] Daemon process started, pid:" << mDaemonProcess->processId();
}

void AiAssistWidget::onDaemonFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    // Capture any remaining stderr before the process is destroyed
    QString lastStderr;
    if (mDaemonProcess) {
        lastStderr = QString::fromUtf8(mDaemonProcess->readAllStandardError()).trimmed();
    }

    mDaemonReady = false;
    mDaemonBusy = false;
    mActiveRequestId = 0;
    mCurrentCallback = nullptr;
    mAppendQueue.clear();
    mXAppendQueue.clear();
    mRagVerifyInFlight = false;
    mWaitingForErrorCheck = false;
    mXErrorCheckInFlight = false;
    if (mErrorCheckTimer) mErrorCheckTimer->stop();
    if (mXActivePromptId != 0) finishXPromptTimer(QStringLiteral("#e74c3c"));
    setProcessingState(false);

    // Reset dictation state if it was active
    if (mDictating) {
        mDictating = false;
        mDictateBtn->setChecked(false);
        mDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
    }

    // Dismiss dictation loading dialog if it's open
    if (mDictationLoadingDialog) {
        mDictationLoadingDialog->accept();
        mDictationLoadingDialog->deleteLater();
        mDictationLoadingDialog = nullptr;
    }

    mDaemonProcess->deleteLater();
    mDaemonProcess = nullptr;

    QString crashInfo = exitStatus == QProcess::CrashExit
        ? tr("AI daemon CRASHED (signal/segfault)")
        : tr("AI daemon exited with code %1").arg(exitCode);

    if (!lastStderr.isEmpty()) {
        // Show last 500 chars of stderr to help diagnose
        QString stderrTail = lastStderr.right(500);
        crashInfo += tr("\n\nLast stderr:\n%1").arg(stderrTail);
    }

    qDebug() << "[AutoAppend] DAEMON DIED:" << crashInfo;
    mAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[DAEMON CRASH]</span> %1")
        .arg(crashInfo.left(200).toHtmlEscaped()));

    mFullStatusText = tr("AI daemon stopped unexpectedly.");
    mStatusBtn->setText(mFullStatusText);

    // Show detailed error to user
    QMessageBox::critical(this, tr("AI Daemon Crashed"), crashInfo);
}

void AiAssistWidget::handleDaemonResponse(const QByteArray& jsonLine) {
    QJsonDocument doc = QJsonDocument::fromJson(jsonLine);
    if (doc.isNull() || !doc.isObject()) {
        // If we were waiting for a response and got garbled JSON, recover
        if (mDaemonBusy) {
            qWarning() << "AiAssist: garbled daemon response while busy, resetting state:" << jsonLine.left(200);
            mDaemonBusy = false;
            mActiveRequestId = 0;
            mCurrentCallback = nullptr;
            if (mXActivePromptId != 0) {
                finishXPromptTimer(QStringLiteral("#e74c3c"));
            }
            setProcessingState(false);
            processAppendQueue();
            processXAppendQueue();
            processRagVerifyQueue();
        }
        return;
    }
    QJsonObject result = doc.object();

    // --- Daemon ready handshake ---
    if (!mDaemonReady && result.contains("status") && result["status"].toString() == "ready") {
        mDaemonReady = true;
        mFullStatusText = tr("AI daemon ready.");
        mStatusBtn->setText(mFullStatusText);
        qDebug() << "[AutoAppend] Daemon READY, pid:" << (mDaemonProcess ? mDaemonProcess->processId() : 0);
        processAppendQueue();
        processXAppendQueue();
        return;
    }

    // --- Voice dictation streaming messages ---
    if (result.contains("type")) {
        QString type = result["type"].toString();

        if (type == "dictation_final") {
            QString block = result["text"].toString();
            if (block.trimmed().isEmpty()) return;
            mLastDictationBlock = block;
            
            bool isCrossAppend = (mTabWidget->tabText(mTabWidget->currentIndex()) == tr("X-Append"));
            
            if (isCrossAppend) {
                ++mXDictationBlockIndex;
                qDebug() << "[CrossAppend] dictation_final received, block #" << mXDictationBlockIndex << ", text:" << block.left(80);

                QString current = mXPrompt->toPlainText();
                if (!current.isEmpty())
                    current += QString("\n%1) \u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\n").arg(mXDictationBlockIndex);
                current += block;
                mXPrompt->setPlainText(current);
                QTextCursor cursor = mXPrompt->textCursor();
                cursor.movePosition(QTextCursor::End);
                mXPrompt->setTextCursor(cursor);

                if (mXAutoAppendCheck->isChecked()) {
                    mXAutoAppendLog->append(QString("<span style='color:#5dade2;'>[Block #%1] Enqueued:</span> <span style='color:#ddd;'>%2</span>")
                        .arg(mXDictationBlockIndex).arg(block.left(100).toHtmlEscaped()));
                    
                    QString mode = "append";
                    if (mXComposeRadio->isChecked()) mode = "compose";
                    else if (mXDesignRadio->isChecked()) mode = "design";
                    else if (mXGenerateRadio->isChecked()) mode = "generate";
                    
                    mXAppendQueue.enqueue({ block, mode, XJobKind::Dictation, QDateTime::currentMSecsSinceEpoch() });
                    qDebug() << "[CrossAppend] Enqueued block #" << mXDictationBlockIndex << ", queue size:" << mXAppendQueue.size();
                    processXAppendQueue(true);
                }
            } else {
                ++mDictationBlockIndex;
                qDebug() << "[AutoAppend] dictation_final received, block #" << mDictationBlockIndex << ", text:" << block.left(80);

                QString current = mAppendPrompt->toPlainText();
                if (!current.isEmpty())
                    current += QString("\n%1) \u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\n").arg(mDictationBlockIndex);
                current += block;
                mAppendPrompt->setPlainText(current);
                QTextCursor cursor = mAppendPrompt->textCursor();
                cursor.movePosition(QTextCursor::End);
                mAppendPrompt->setTextCursor(cursor);

                if (mAutoAppendCheck->isChecked()) {
                    mAutoAppendLog->append(QString("<span style='color:#5dade2;'>[Block #%1] Enqueued:</span> <span style='color:#ddd;'>%2</span>")
                        .arg(mDictationBlockIndex).arg(block.left(100).toHtmlEscaped()));
                    mAppendQueue.enqueue(block);
                    qDebug() << "[AutoAppend] Enqueued block #" << mDictationBlockIndex << ", queue size:" << mAppendQueue.size();
                    processAppendQueue();
                }
            }
        }
        
        if (type == "dictation_partial") {
            QString partialText = result["text"].toString();
            if (partialText.trimmed().isEmpty()) return;

            QString truncated = partialText;
            if (truncated.length() > 50)
                truncated = truncated.left(50) + "...";
            mFullStatusText = QString::fromUtf8("\xF0\x9F\x97\xA3 ") + truncated; // 🗣
            mStatusBtn->setText(mFullStatusText);
            mStatusBtn->setStyleSheet(
                "QPushButton { color: #5dade2; font-size: 10px; padding: 0px 4px; border: none; font-weight: bold; }");
            return;
        }

        if (type == "dictation_started" || type == "dictation_listening") {
            mDictationModelLoaded = true;
            mFullStatusText = tr("Listening...");
            mStatusBtn->setText(mFullStatusText);
            mStatusBtn->setStyleSheet("QPushButton { color: #ff4444; font-size: 10px; padding: 0px 4px; border: none; font-weight: bold; }");
            if (mDictationLoadingDialog) {
                mDictationLoadingDialog->accept();
                mDictationLoadingDialog->deleteLater();
                mDictationLoadingDialog = nullptr;
            }
            return;
        }

        if (type == "dictation_transcribing") {
            mFullStatusText = tr("Transcribing...");
            mStatusBtn->setText(mFullStatusText);
            // Change color to an orange/yellow to indicate transcription
            mStatusBtn->setStyleSheet("QPushButton { color: #f39c12; font-size: 10px; padding: 0px 4px; border: none; font-weight: bold; }");
            return;
        }

        if (type == "dictation_stopped") {
            mDictating = false;
            mDictateBtn->setChecked(false);
            mDictateMuteBtn->setChecked(false);
            mDictationMuted = false;
            mFullStatusText = tr("Dictation stopped.");
            mStatusBtn->setText(mFullStatusText);
            mStatusBtn->setStyleSheet("QPushButton { color: #aaa; font-size: 10px; padding: 0px 4px; border: none; }");
            if (mDictationLoadingDialog) {
                mDictationLoadingDialog->accept();
                mDictationLoadingDialog->deleteLater();
                mDictationLoadingDialog = nullptr;
            }
            return;
        }

        if (type == "dictation_error") {
            mDictating = false;
            mDictateBtn->setChecked(false);
            mDictateMuteBtn->setChecked(false);
            mDictationMuted = false;
            mFullStatusText = tr("Dictation error.");
            mStatusBtn->setText(mFullStatusText);
            mStatusBtn->setStyleSheet("QPushButton { color: #e74c3c; font-size: 10px; padding: 0px 4px; border: none; }");
            if (mDictationLoadingDialog) {
                mDictationLoadingDialog->accept();
                mDictationLoadingDialog->deleteLater();
                mDictationLoadingDialog = nullptr;
            }
            QString errMsg = result["error"].toString();
            mAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[DICTATION ERROR]</span> %1").arg(errMsg.left(200).toHtmlEscaped()));
            QMessageBox::critical(this, tr("Dictation Error"),
                                  tr("Failed to start dictation:\n\n%1").arg(errMsg));
            return;
        }
        
        if (type == "debug") {
            qDebug() << "[Dictation Debug]" << result["msg"].toString();
            return;
        }

        if (type == "command_cancelled") {
            qDebug() << "[AiAssist] Daemon acknowledged cancellation for request_id:"
                     << result.value("request_id").toInt();
            return;
        }

        // Catch-all for any other streaming messages to ensure they don't fall through
        // and prematurely trigger the command callback with a partial payload.
        return;
    }
    if (result.contains("composition_state")) {
        mCompositionState = result["composition_state"].toString();
    }

    // --- Skip unsolicited dictation / fire-and-forget command responses ---
    // start_dictation/stop_dictation/reset_composition_state are sent via raw mDaemonProcess->write()
    // without a request_id, whereas every runBackendCommand sets an integer request_id > 0.
    if (result.value("request_id").toInt(0) == 0 && result.contains("status")
        && !result.contains("error") && !result.contains("code")
        && !result.contains("plan") && !result.contains("last_stats") && !result.contains("models")
        && !result.contains("session_stats") && !result.contains("raw_log")) {
        qDebug() << "[AutoAppend] Dropped unsolicited status response:"
                 << result["status"].toString()
                 << "| daemonBusy:" << mDaemonBusy;
        return;
    }

    // --- Regular command responses ---
    if (mDaemonBusy) {
        const int respReqId = result.value("request_id").toInt(0);
        if (mActiveRequestId != 0 && respReqId != 0 && respReqId != mActiveRequestId) {
            qDebug() << "[AiAssist] Dropping stale daemon response for request_id:" << respReqId
                     << "(active:" << mActiveRequestId << ")";
            return;
        }

        mDaemonBusy = false;
        mActiveRequestId = 0;
        setProcessingState(false);
        qDebug() << "[AutoAppend] Command response received, mDaemonBusy -> false"
                 << "| hasError:" << result.contains("error")
                 << "| hasCode:" << result.contains("code")
                 << "| hasCallback:" << (mCurrentCallback != nullptr);
        
        if (result.contains("error")) {
            QString errMsg = result["error"].toString();
            mAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[ERROR]</span> %1").arg(errMsg.left(200).toHtmlEscaped()));
            if (mXActivePromptId != 0) {
                double errSec = finishXPromptTimer(QStringLiteral("#e74c3c"));
                if (mXAutoAppendLog) {
                    mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[ERROR]</span> (%1s) %2")
                        .arg(errSec, 0, 'f', 1).arg(errMsg.left(200).toHtmlEscaped()));
                }
                mCurrentCallback = nullptr;
                processXAppendQueue();
            }
            QMessageBox::critical(this, tr("Backend Error"),
                                  errMsg + "\n\n" + result["traceback"].toString());
        } else if (mCurrentCallback) {
            auto cb = std::move(mCurrentCallback);
            mCurrentCallback = nullptr;
            cb(result);
        }

        if (result.contains("last_stats")) {
            mFullStatusText = tr("Ready");
            mStatusBtn->setText(mFullStatusText);
            tryUpdateSessionStats();
        }

        // Drain any queued auto-append / X-Append blocks now that the daemon is free
        processAppendQueue();
        processXAppendQueue();
        processRagVerifyQueue();
    } else {
        qDebug() << "[AutoAppend] WARNING: response received but mDaemonBusy was false."
                 << "Keys:" << result.keys();
    }
}

void AiAssistWidget::runBackendCommand(const QString& command, const QJsonObject& data,
                                       std::function<void(const QJsonObject&)> callback) {
    if (mDaemonBusy || mCurrentProcess) {
        qDebug() << "[AutoAppend] runBackendCommand REJECTED:" << command
                 << "| mDaemonBusy:" << mDaemonBusy
                 << "| mCurrentProcess:" << (mCurrentProcess != nullptr);
        mAutoAppendLog->append(QString("<span style='color:#f39c12;'>[BLOCKED]</span> Command '%1' rejected — daemon busy").arg(command));
        QMessageBox::warning(this, tr("Busy"), tr("A command is already running. Please wait."));
        return;
    }

    // Merge base payload data (active file, model, temperature) into finalData
    QJsonObject finalData = data;
    QJsonObject base = basePayload();
    for (auto it = base.begin(); it != base.end(); ++it) {
        if (!finalData.contains(it.key())) {
            finalData[it.key()] = it.value();
        }
    }
    
    // Add command routing key for the daemon
    finalData["command"] = command;

    if (!mDaemonProcess || !mDaemonReady) {
        // Fallback for sync commands or if daemon failed to start
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
                    if (statusText.length() > 60) statusText = statusText.left(60) + "...";
                    mFullStatusText = statusText;
                    mStatusBtn->setText(statusText.left(30) + (statusText.length() > 30 ? "..." : ""));
                }
            }
        });

        connect(mCurrentProcess, &QProcess::readyReadStandardOutput, this, [this]() {
            if (!mCurrentProcess) return;
            mCurrentOutput.append(mCurrentProcess->readAllStandardOutput());
        });

        connect(mCurrentProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                tempFile, &QTemporaryFile::deleteLater);

        setProcessingState(true);
        QStringList args;
        args << scriptPath << command << tempPath;
        mCurrentProcess->start(pythonPath(), args);
        return;
    }

    // Fast path: Use persistent daemon
    mActiveRequestId = ++mRequestSeq;
    finalData["request_id"] = mActiveRequestId;
    mCurrentCallback = callback;
    mDaemonBusy = true;
    setProcessingState(true);
    
    QJsonDocument jsonDoc(finalData);
    QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact) + "\n";
    qDebug() << "[AutoAppend] Sending daemon command:" << command
             << "| payload size:" << payload.size() << "bytes";
    mDaemonProcess->write(payload);
}

void AiAssistWidget::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus) {
    if (!mCurrentProcess) {
        setProcessingState(false);
        return;
    }

    QByteArray output = mCurrentOutput;
    QByteArray errOutput = mCurrentErrorOutput;

    mCurrentProcess->deleteLater();
    mCurrentProcess = nullptr;
    setProcessingState(false);

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
    if (mCurrentCallback) {
        auto cb = std::move(mCurrentCallback);
        mCurrentCallback = nullptr;
        cb(result);
    }
        
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
                    QString currentModel = currentModelKey();
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
    data["model"] = currentModelKey();
    data["sys_msgs"] = QJsonArray::fromStringList(mGenPlanSysMsgs);

    runBackendCommand("generate_plan", data, [this](const QJsonObject& result) {
        mGenPlanOutput->setPlainText(result["plan"].toString());
    });
}

void AiAssistWidget::onGenerateClicked() {
    QString plan = mGenPlanOutput->toPlainText().trimmed();
    if (plan.isEmpty()) return;

    const QString usedModel = currentModelKey();
    QString prompt = mGenPrompt->toPlainText().trimmed();
    QJsonObject data;
    data["plan"] = plan;
    data["prompt"] = prompt;
    data["use_kb"] = mGenUseKb->isChecked();
    data["include_ending"] = mGenIncludeEnding->isChecked();
    data["model"] = usedModel;
    data["sys_msgs"] = QJsonArray::fromStringList(mGenCodeSysMsgs);

    runBackendCommand("generate_code", data, [this, prompt, usedModel](const QJsonObject& result) {
        // Insert generated code into the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
                const QString headerLine = PromptNavBar::formatHeaderComment(QStringLiteral("generate"), navIdx, prompt, usedModel);
                const QString blockWithHeader = headerLine + QStringLiteral("\n") + code.trimmed();
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                int codeStartPos = cursor.position() + 2;
                cursor.insertText("\n\n" + blockWithHeader);
                registerPromptNavBlock(doc, QStringLiteral("generate"), prompt, codeStartPos, blockWithHeader, usedModel);
            }
            enqueueRagCandidate(code, prompt, QStringLiteral("generate"), false);
        }
        mFullStatusText = tr("Code generated and written");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Compose tab handlers ---

void AiAssistWidget::onComposePlanClicked() {
    QString prompt = mComposePrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    QJsonObject data;
    data["prompt"] = prompt;
    data["use_kb"] = mComposeUseKb->isChecked();
    data["model"] = currentModelKey();
    data["mode"] = "compose";
    data["sys_msgs"] = QJsonArray::fromStringList(mComposePlanSysMsgs);

    runBackendCommand("generate_plan", data, [this](const QJsonObject& result) {
        mComposePlanOutput->setPlainText(result["plan"].toString());
    });
}

void AiAssistWidget::onComposeGenerateClicked() {
    QString plan = mComposePlanOutput->toPlainText().trimmed();
    if (plan.isEmpty()) return;

    const QString usedModel = currentModelKey();
    QString prompt = mComposePrompt->toPlainText().trimmed();
    QJsonObject data;
    data["plan"] = plan;
    data["prompt"] = prompt;
    data["use_kb"] = mComposeUseKb->isChecked();
    data["model"] = usedModel;
    data["mode"] = "compose";
    data["sys_msgs"] = QJsonArray::fromStringList(mComposeCodeSysMsgs);

    runBackendCommand("generate_code", data, [this, prompt, usedModel](const QJsonObject& result) {
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
                const QString headerLine = PromptNavBar::formatHeaderComment(QStringLiteral("compose"), navIdx, prompt, usedModel);
                const QString blockWithHeader = headerLine + QStringLiteral("\n") + code.trimmed();
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                int codeStartPos = cursor.position() + 2;
                cursor.insertText("\n\n" + blockWithHeader);
                registerPromptNavBlock(doc, QStringLiteral("compose"), prompt, codeStartPos, blockWithHeader, usedModel);
            }
            enqueueRagCandidate(code, prompt, QStringLiteral("compose"), false);
        }
        mFullStatusText = tr("Composition generated and written");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Custom tab handlers ---

void AiAssistWidget::onCustomGenerateClicked() {
    QString prompt = mCustomPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    const QString usedModel = currentModelKey();
    QJsonObject data;
    data["prompt"] = prompt;
    data["use_kb"] = mCustomUseKb->isChecked();
    data["model"] = usedModel;
    data["sys_msgs"] = QJsonArray::fromStringList(mCustomSelectedSysMsgs);
    data["mode"] = "custom";

    runBackendCommand("custom_generate", data, [this, prompt, usedModel](const QJsonObject& result) {
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
                const QString headerLine = PromptNavBar::formatHeaderComment(QStringLiteral("custom"), navIdx, prompt, usedModel);
                const QString blockWithHeader = headerLine + QStringLiteral("\n") + code.trimmed();
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                int codeStartPos = cursor.position() + 2;
                cursor.insertText("\n\n" + blockWithHeader);
                registerPromptNavBlock(doc, QStringLiteral("custom"), prompt, codeStartPos, blockWithHeader, usedModel);
            }
            enqueueRagCandidate(code, prompt, QStringLiteral("custom"), false);
        }
        mFullStatusText = tr("Custom snippet generated and written");
        mStatusBtn->setText(mFullStatusText);
    });
}

void AiAssistWidget::onCustomSysEditClicked() {
    openSysMessageEditor(mCustomSelectedSysMsgs);
}

void AiAssistWidget::openSysMessageEditor(QStringList& selectedList) {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    QDir sysDir(scriptDir.filePath("system_messages"));
    
    if (!sysDir.exists()) sysDir.mkpath(".");
    
    // Gather files retaining relative paths
    QStringList relativeFiles;
    QDirIterator it(sysDir.absolutePath(), QStringList() << "*.md" << "*.txt",
                    QDir::Files, QDirIterator::Subdirectories);
    while (it.hasNext()) {
        it.next();
        relativeFiles.append(sysDir.relativeFilePath(it.filePath()));
    }
    
    // Ordered list where checked items are at the top in their saved order
    QStringList orderedFiles;
    for (const QString& sel : selectedList) {
        if (relativeFiles.contains(sel)) {
            orderedFiles.append(sel);
            relativeFiles.removeAll(sel);
        }
    }
    orderedFiles.append(relativeFiles);
    
    QDialog dlg(this);
    dlg.setWindowTitle(tr("Custom System Messages (Drag to re-order)"));
    dlg.resize(1000, 700);
    
    QVBoxLayout* entireLay = new QVBoxLayout(&dlg);
    
    // Top half: Editor
    QHBoxLayout* mainLay = new QHBoxLayout;
    entireLay->addLayout(mainLay, 2);
    
    // List on left
    QVBoxLayout* leftLay = new QVBoxLayout;
    QListWidget* fileList = new QListWidget;
    fileList->setFixedWidth(300);
    fileList->setDragDropMode(QAbstractItemView::InternalMove);
    for (const QString& file : orderedFiles) {
        QListWidgetItem* item = new QListWidgetItem(file, fileList);
        item->setFlags(item->flags() | Qt::ItemIsUserCheckable | Qt::ItemIsDragEnabled);
        item->setCheckState(selectedList.contains(file) ? Qt::Checked : Qt::Unchecked);
    }
    leftLay->addWidget(fileList);
    
    QPushButton* newBtn = new QPushButton(tr("New Message..."));
    leftLay->addWidget(newBtn);
    mainLay->addLayout(leftLay);
    
    // Editor and Save button on right
    QVBoxLayout* rightLay = new QVBoxLayout;
    QPlainTextEdit* editor = new QPlainTextEdit;
    editor->setPlaceholderText(tr("Select a file from the list to edit its content here.\nLines will not be wrapped automatically."));
    editor->setLineWrapMode(QPlainTextEdit::NoWrap);
    rightLay->addWidget(editor);
    
    QPushButton* saveBtn = new QPushButton(tr("Save File"));
    rightLay->addWidget(saveBtn);
    mainLay->addLayout(rightLay);
    
    // Bottom half: Preview
    entireLay->addWidget(new QLabel(tr("Prompt Preview (concatenation order matches list order):")));
    QPlainTextEdit* previewEditor = new QPlainTextEdit;
    previewEditor->setReadOnly(true);
    previewEditor->setStyleSheet("background-color: #222; color: #ccc;");
    entireLay->addWidget(previewEditor, 1);
    
    QString currentFilePath;
    
    auto updatePreview = [&]() {
        QString fullPreview = "";
        for(int i = 0; i < fileList->count(); ++i) {
            QListWidgetItem* item = fileList->item(i);
            if(item->checkState() == Qt::Checked) {
                QString path = sysDir.filePath(item->text());
                QFile f(path);
                if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
                    if (!fullPreview.isEmpty()) fullPreview += "\n\n=== ADDITIONAL INSTRUCTION ===\n\n";
                    fullPreview += QString::fromUtf8(f.readAll()).trimmed();
                }
            }
        }
        previewEditor->setPlainText(fullPreview);
    };

    QObject::connect(fileList, &QListWidget::itemChanged, updatePreview);
    QObject::connect(fileList->model(), &QAbstractItemModel::rowsMoved, updatePreview);
    
    QObject::connect(fileList, &QListWidget::currentTextChanged, [&](const QString& fileName) {
        currentFilePath = sysDir.filePath(fileName);
        QFile f(currentFilePath);
        if (f.open(QIODevice::ReadOnly | QIODevice::Text)) {
            editor->setPlainText(QString::fromUtf8(f.readAll()));
        } else {
            editor->clear();
        }
    });

    QObject::connect(newBtn, &QPushButton::clicked, [&]() {
        bool ok;
        QString text = QInputDialog::getText(&dlg, tr("New Custom Message"),
                                             tr("Enter filename (e.g. custom/my_new_rule.md):"), QLineEdit::Normal,
                                             "custom/new_rule.md", &ok);
        if (ok && !text.isEmpty()) {
            QFile newFile(sysDir.filePath(text));
            QFileInfo fi(newFile);
            sysDir.mkpath(fi.absolutePath()); 
            if (newFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
                newFile.write("Write your custom rules here...");
                newFile.close();
                QListWidgetItem* item = new QListWidgetItem(text, fileList);
                item->setFlags(item->flags() | Qt::ItemIsUserCheckable | Qt::ItemIsDragEnabled);
                item->setCheckState(Qt::Checked);
                fileList->setCurrentItem(item);
                updatePreview();
            }
        }
    });
    
    QObject::connect(saveBtn, &QPushButton::clicked, [&]() {
        if (currentFilePath.isEmpty()) return;
        QFile f(currentFilePath);
        if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
            f.write(editor->toPlainText().toUtf8());
            QMessageBox::information(&dlg, tr("Saved"), tr("File saved successfully."));
            updatePreview();
        } else {
            QMessageBox::warning(&dlg, tr("Error"), tr("Could not save to file."));
        }
    });

    if (fileList->count() > 0) {
        fileList->setCurrentRow(0);
    }
    updatePreview();
    
    // Accept / Cancel row
    QHBoxLayout* bottomBtnRow = new QHBoxLayout;
    bottomBtnRow->addStretch();
    QPushButton* cancelBtn = new QPushButton(tr("Cancel"));
    QPushButton* acceptBtn = new QPushButton(tr("Accept Checked"));
    bottomBtnRow->addWidget(cancelBtn);
    bottomBtnRow->addWidget(acceptBtn);
    entireLay->addLayout(bottomBtnRow);
    
    QObject::connect(cancelBtn, &QPushButton::clicked, &dlg, &QDialog::reject);
    QObject::connect(acceptBtn, &QPushButton::clicked, [&]() {
        selectedList.clear();
        for(int i = 0; i < fileList->count(); ++i) {
            QListWidgetItem* item = fileList->item(i);
            if(item->checkState() == Qt::Checked) {
                selectedList.append(item->text());
            }
        }
        // Persist as new default
        saveSysMsgDefaults();
        dlg.accept();
    });

    dlg.exec();
}

// --- Design tab handlers ---

void AiAssistWidget::onDesignPlanClicked() {
    QString prompt = mDesignPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    QJsonObject data;
    data["prompt"] = prompt;
    data["use_kb"] = mDesignUseKb->isChecked();
    data["model"] = currentModelKey();
    data["mode"] = "design";
    data["sys_msgs"] = QJsonArray::fromStringList(mDesignPlanSysMsgs);

    runBackendCommand("generate_plan", data, [this](const QJsonObject& result) {
        mDesignPlanOutput->setPlainText(result["plan"].toString());
    });
}

void AiAssistWidget::onDesignGenerateClicked() {
    QString plan = mDesignPlanOutput->toPlainText().trimmed();
    if (plan.isEmpty()) return;

    const QString usedModel = currentModelKey();
    QString prompt = mDesignPrompt->toPlainText().trimmed();
    QJsonObject data;
    data["plan"] = plan;
    data["prompt"] = prompt;
    data["use_kb"] = mDesignUseKb->isChecked();
    data["model"] = usedModel;
    data["mode"] = "design";
    data["sys_msgs"] = QJsonArray::fromStringList(mDesignCodeSysMsgs);

    runBackendCommand("generate_code", data, [this, prompt, usedModel](const QJsonObject& result) {
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
                const QString headerLine = PromptNavBar::formatHeaderComment(QStringLiteral("design"), navIdx, prompt, usedModel);
                const QString blockWithHeader = headerLine + QStringLiteral("\n") + code.trimmed();
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::End);
                int codeStartPos = cursor.position() + 2;
                cursor.insertText("\n\n" + blockWithHeader);
                registerPromptNavBlock(doc, QStringLiteral("design"), prompt, codeStartPos, blockWithHeader, usedModel);
            }
            enqueueRagCandidate(code, prompt, QStringLiteral("design"), false);
        }
        mFullStatusText = tr("Design generated and written");
        mStatusBtn->setText(mFullStatusText);
    });
}

// --- Append tab handler ---

void AiAssistWidget::onAppendClicked() {
    QString prompt = mAppendPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;
    submitAppendForBlock(prompt, false);
}

void AiAssistWidget::onDictateMuteToggled() {
    if (!mDaemonProcess || !mDaemonReady) {
        mDictateMuteBtn->setChecked(false);
        return;
    }

    mDictationMuted = mDictateMuteBtn->isChecked();

    QJsonObject cmd;
    cmd["command"] = QStringLiteral("mute_dictation");
    cmd["muted"] = mDictationMuted;
    QJsonDocument jsonDoc(cmd);
    mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
    
    if (mDictationMuted) {
        mAutoAppendLog->append("<span style='color:#f39c12;'>[DICTATION]</span> Muted");
    } else {
        mAutoAppendLog->append("<span style='color:#f39c12;'>[DICTATION]</span> Unmuted");
    }
}

void AiAssistWidget::submitAppendForBlock(const QString& prompt, bool isAuto) {
    if (prompt.isEmpty()) return;

    if (!hasApiKeyForCurrentModel()) {
        QMessageBox::warning(this, tr("Missing API Key"), tr("No API key found for the selected model/provider. Please configure it in the API settings."));
        return;
    }

    qDebug() << "[AutoAppend] submitAppendForBlock called"
             << "| isAuto:" << isAuto
             << "| prompt:" << prompt.left(80)
             << "| mDaemonBusy:" << mDaemonBusy;

    // runBackendCommand will internally check and set mDaemonBusy = true
    // We just set the UI text here beforehand so it overrides the default "Processing..."
    mFullStatusText = isAuto ? tr("Auto appending...") : tr("Processing...");
    mStatusBtn->setText(mFullStatusText);

    if (isAuto) {
        mAutoAppendLog->append(QString("<span style='color:#f39c12;'>[SENDING]</span> Submitting to LLM: <span style='color:#ddd;'>%1</span>")
            .arg(prompt.left(100).toHtmlEscaped()));
            
        Document* doc = Main::instance()->documentManager()->activeDocument();
        if (doc) {
            QString docText = doc->textDocument()->toPlainText();
            if (!docText.contains("History.clear.start;")) {
                QTextCursor cursor(doc->textDocument());
                cursor.movePosition(QTextCursor::Start);
                QString startCode = "History.clear.start;";
                cursor.insertText(startCode + "\n\n");
                Main::evaluateCode(startCode);

                cursor.movePosition(QTextCursor::End);
                QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
                QString endCode = QString("\n\n//History.end;\n//History.saveStory(\"C:/Users/Bruno Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/sc-files/session-recordings/%1.scd\");\n").arg(timestamp);
                cursor.insertText(endCode);
            }
        }
    }

    const QString usedModel = currentModelKey();
    QJsonObject data = basePayload();
    data["prompt"] = prompt;
    data["composition_state"] = mCompositionState;
    data["use_kb"] = mAppendUseKb->isChecked();
    data["model"] = usedModel;
    data["sys_msgs"] = QJsonArray::fromStringList(mAppendSysMsgs);

    runBackendCommand("append", data, [this, prompt, isAuto, usedModel](const QJsonObject& result) {
        // Insert appended code into the active document
        QString code = result["code"].toString();
        qDebug() << "[AutoAppend] append callback received"
                 << "| hasCode:" << !code.isEmpty()
                 << "| codeLen:" << code.length();

        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
                const QString headerLine = PromptNavBar::formatHeaderComment(QStringLiteral("append"), navIdx, prompt, usedModel);
                const QString blockWithHeader = headerLine + QStringLiteral("\n") + code.trimmed();
                QTextCursor cursor(doc->textDocument());
                QString docText = doc->textDocument()->toPlainText();
                int historyIdx = docText.lastIndexOf("//History.end;");
                int codeStartPos = 0;
                if (historyIdx != -1) {
                    cursor.setPosition(historyIdx);
                    codeStartPos = historyIdx;
                    cursor.insertText(blockWithHeader + "\n\n");
                } else {
                    cursor.movePosition(QTextCursor::End);
                    codeStartPos = cursor.position() + 2;
                    cursor.insertText("\n\n" + blockWithHeader);
                }
                registerPromptNavBlock(doc, QStringLiteral("append"), prompt, codeStartPos, blockWithHeader, usedModel);

                // --- Generate commented-out volume reduction lines ---
                // Extract Ndef names from the generated code: matches Ndef(\name, ...)
                // which indicates a new Ndef definition (not .set/.xset/.clear calls)
                QRegularExpression ndefRx("Ndef\\(\\s*\\\\(\\w+)\\s*,");
                QRegularExpressionMatchIterator it = ndefRx.globalMatch(code);
                QStringList ndefNames;
                while (it.hasNext()) {
                    QRegularExpressionMatch match = it.next();
                    QString name = match.captured(1);
                    if (!ndefNames.contains(name))
                        ndefNames.append(name);
                }
                if (!ndefNames.isEmpty()) {
                    QString quietLines = "// --- Quiet new textures (uncomment to reduce volume to ~1/10) ---\n";
                    for (const QString& name : ndefNames) {
                        quietLines += QString("//Ndef(\\%1).set(\\amp, 0.03);\n").arg(name);
                    }
                    quietLines += "\n";

                    // Insert after the code block
                    QTextCursor endCursor(doc->textDocument());
                    QString updatedText = doc->textDocument()->toPlainText();
                    int quietIdx = updatedText.lastIndexOf("//History.end;");
                    if (quietIdx != -1) {
                        endCursor.setPosition(quietIdx);
                        endCursor.insertText(quietLines);
                    } else {
                        endCursor.movePosition(QTextCursor::End);
                        endCursor.insertText(quietLines);
                    }
                }

                if (mAutoExecuteCheck->isChecked()) {
                    evaluateCodeBlocks(code);
                    emit xAppendEvaluated(QStringLiteral("append"), navIdx, code);
                    mFullStatusText = tr("Block appended and auto-evaluated");
                } else {
                    mFullStatusText = tr("Block appended");
                }
                if (isAuto) {
                    mAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[OK]</span> Code inserted (%1 chars)%2")
                        .arg(code.length())
                        .arg(mAutoExecuteCheck->isChecked() ? " + auto-evaluated" : ""));
                }
            } else {
                qDebug() << "[AutoAppend] WARNING: no active document to insert code into";
                if (isAuto) {
                    mAutoAppendLog->append("<span style='color:#e74c3c;'>[ERROR]</span> No active document");
                }
            }
        } else {
            qDebug() << "[AutoAppend] WARNING: empty code in response";
            if (isAuto) {
                mAutoAppendLog->append("<span style='color:#e74c3c;'>[WARN]</span> LLM returned empty code");
            }
        }
        mStatusBtn->setText(mFullStatusText);
        
        mRagFallbackCode = result["rag_fallback"].toString();
        if (mAutoExecuteCheck->isChecked() && !code.trimmed().isEmpty()) {
            mPendingAppendRagCode = code;
            mPendingAppendRagPrompt = prompt;
            mWaitingForErrorCheck = true;
            mErrorCheckTimer->start(250);
            // We wait to process the next block until the error check clears
        } else {
            if (!code.trimmed().isEmpty()) {
                mRagVerifyQueue.enqueue({ code, prompt, QStringLiteral("append"), false });
            }
            // Drain next queued block if any
            processAppendQueue();
            processXAppendQueue();
            processRagVerifyQueue();
        }
    });
}

void AiAssistWidget::processAppendQueue() {
    if (mAppendQueue.isEmpty()) {
        qDebug() << "[AutoAppend] processAppendQueue: queue empty, nothing to do";
        return;
    }
    if (mDaemonBusy) {
        qDebug() << "[AutoAppend] processAppendQueue: daemon busy, will retry when free"
                 << "| queued:" << mAppendQueue.size();
        mAutoAppendLog->append(QString("<span style='color:#888;'>[WAIT]</span> Daemon busy, %1 block(s) queued")
            .arg(mAppendQueue.size()));
        return;
    }
    if (!mDaemonReady) {
        qDebug() << "[AutoAppend] processAppendQueue: daemon not ready";
        return;
    }

    // Dequeue one block at a time — each dictation block gets its own LLM call.
    // After the callback fires, processAppendQueue() is called again to drain the next.
    QString block = mAppendQueue.dequeue();
    qDebug() << "[AutoAppend] Dequeued block, remaining:" << mAppendQueue.size()
             << "| block:" << block.left(80);
    submitAppendForBlock(block, true);
}

void AiAssistWidget::onDictateToggled() {
    if (!mDaemonProcess || !mDaemonReady) {
        QMessageBox::warning(this, tr("Not Ready"),
                             tr("The AI daemon is not ready yet. Please wait."));
        mDictateBtn->setChecked(false);
        mDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
        return;
    }

    if (!mDictating && !hasApiKeyForCurrentModel()) {
        QMessageBox::warning(this, tr("Missing API Key"), tr("No API key found for the selected model/provider. Please configure it in the API settings before starting dictation."));
        mDictateBtn->setChecked(false);
        mDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
        return;
    }

    if (!mDictating) {
        // Start dictation
        mDictating = true;
        mDictLangCombo->setEnabled(false);
        mDictModelCombo->setEnabled(false);
        mFullStatusText = tr("Starting dictation...");
        mStatusBtn->setText(mFullStatusText);

        // Debug: check daemon process state before writing
        qDebug() << "[AutoAppend] Dictation START requested"
                 << "| autoAppend:" << mAutoAppendCheck->isChecked()
                 << "| daemonState:" << mDaemonProcess->state()
                 << "| daemonPid:" << mDaemonProcess->processId();
        mAutoAppendLog->append("<span style='color:#5dade2;'>[DICTATION]</span> Started");

        if (!mDictationModelLoaded && !mDictationLoadingDialog) {
            mDictationLoadingDialog = new QProgressDialog(tr("Starting microphone... Please wait."), QString(), 0, 0, this);
            mDictationLoadingDialog->setWindowTitle(tr("Voice Dictation"));
            mDictationLoadingDialog->setWindowModality(Qt::WindowModal);
            mDictationLoadingDialog->setCancelButton(nullptr);
            mDictationLoadingDialog->show();
        }

        QJsonObject cmd;
        cmd["command"] = QStringLiteral("start_dictation");
        cmd["model"] = mDictModelCombo->currentData().toString();
        cmd["language"] = mDictLangCombo->currentData().toString();
        QJsonDocument jsonDoc(cmd);
        QByteArray payload = jsonDoc.toJson(QJsonDocument::Compact) + "\n";
        qint64 written = mDaemonProcess->write(payload);
        qDebug() << "[AutoAppend] Wrote start_dictation to stdin:" << written << "bytes of" << payload.size();
    } else {
        // Stop dictation
        mDictating = false;
        mDictLangCombo->setEnabled(true);
        mDictModelCombo->setEnabled(true);
        mFullStatusText = tr("Stopping dictation...");
        mStatusBtn->setText(mFullStatusText);
        qDebug() << "[AutoAppend] Dictation STOP requested";
        mAutoAppendLog->append("<span style='color:#5dade2;'>[DICTATION]</span> Stopped");

        mDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
        mAppendQueue.clear();

        QJsonObject cmd;
        cmd["command"] = QStringLiteral("stop_dictation");
        QJsonDocument jsonDoc(cmd);
        mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
    }
}

// --- Cross-Append tab handlers ---

void AiAssistWidget::onXAppendModeChanged() {
    // Auto-Execute and Parallel Validation are supported across all X-Append modes
    // (append, compose, design, generate).
    mXAutoExecuteCheck->setEnabled(true);
}

QString AiAssistWidget::startXPromptTimer(qint64 startMs) {
    if (mXActivePromptId != 0) {
        finishXPromptTimer(QStringLiteral("#95a5a6"));
    }
    mXActivePromptStartMs = (startMs > 0) ? startMs : QDateTime::currentMSecsSinceEpoch();
    mXActivePromptId = ++mXPromptTimerSeq;
    double initSec = qMax(0.0, (QDateTime::currentMSecsSinceEpoch() - mXActivePromptStartMs) / 1000.0);
    mXActivePromptToken = QString::fromUtf8("[\xE2\x8F\xB1 #%1: %2s]").arg(mXActivePromptId).arg(initSec, 0, 'f', 1);

    if (!mXPromptElapsedTimer) {
        mXPromptElapsedTimer = new QTimer(this);
        mXPromptElapsedTimer->setInterval(100);
        connect(mXPromptElapsedTimer, &QTimer::timeout, this, &AiAssistWidget::updateXPromptTimerDisplay);
    }
    mXPromptElapsedTimer->start(100);

    return QString("<span style='color:#f1c40f; font-weight:bold;'>%1</span>").arg(mXActivePromptToken.toHtmlEscaped());
}

void AiAssistWidget::updateXPromptTimerDisplay() {
    if (mXActivePromptId == 0 || mXActivePromptToken.isEmpty() || !mXAutoAppendLog)
        return;
    double elapsed = qMax(0.0, (QDateTime::currentMSecsSinceEpoch() - mXActivePromptStartMs) / 1000.0);
    QString nextToken = QString::fromUtf8("[\xE2\x8F\xB1 #%1: %2s]").arg(mXActivePromptId).arg(elapsed, 0, 'f', 1);
    if (nextToken == mXActivePromptToken)
        return;

    QTextCursor c = mXAutoAppendLog->document()->find(mXActivePromptToken);
    if (!c.isNull()) {
        c.insertHtml(QString("<span style='color:#f1c40f; font-weight:bold;'>%1</span>").arg(nextToken.toHtmlEscaped()));
        mXActivePromptToken = nextToken;
    }
}

double AiAssistWidget::finishXPromptTimer(const QString& colorHex) {
    if (mXPromptElapsedTimer) {
        mXPromptElapsedTimer->stop();
    }
    if (mXActivePromptId == 0)
        return 0.0;

    double totalSec = qMax(0.0, (QDateTime::currentMSecsSinceEpoch() - mXActivePromptStartMs) / 1000.0);
    QString finalBadge = QString::fromUtf8("[\xE2\x8F\xB1 %1s]").arg(totalSec, 0, 'f', 1);

    if (mXAutoAppendLog && !mXActivePromptToken.isEmpty()) {
        QTextCursor c = mXAutoAppendLog->document()->find(mXActivePromptToken);
        if (!c.isNull()) {
            c.insertHtml(QString("<span style='color:%1; font-weight:bold;'>%2</span>").arg(colorHex, finalBadge.toHtmlEscaped()));
        }
    }

    mXActivePromptId = 0;
    mXActivePromptStartMs = 0;
    mXActivePromptToken.clear();
    return totalSec;
}

void AiAssistWidget::onXAppendClicked() {
    QString prompt = mXPrompt->toPlainText().trimmed();
    if (prompt.isEmpty()) return;

    QString mode = "append";
    if (mXComposeRadio->isChecked()) mode = "compose";
    else if (mXDesignRadio->isChecked()) mode = "design";
    else if (mXGenerateRadio->isChecked()) mode = "generate";

    qint64 nowMs = QDateTime::currentMSecsSinceEpoch();
    if (mDaemonBusy || mCurrentProcess != nullptr || mValidationBusy || mXErrorCheckInFlight || mWaitingForErrorCheck) {
        mXAppendQueue.enqueue({ prompt, mode, XJobKind::Dictation, nowMs });
        mXAutoAppendLog->append(QString("<span style='color:#888;'>[WAIT]</span> Daemon busy, %1 block(s) queued")
            .arg(mXAppendQueue.size()));
        return;
    }

    submitCrossAppendForBlock(prompt, mode, false, nowMs);
}

void AiAssistWidget::submitCrossAppendForBlock(const QString& prompt, const QString& mode, bool isValidation, qint64 enqueuedAtMs) {
    if (prompt.isEmpty()) return;

    if (!hasApiKeyForCurrentModel()) {
        QMessageBox::warning(this, tr("Missing API Key"), tr("No API key found for the selected model/provider. Please configure it in the API settings."));
        return;
    }

    if (mDaemonBusy || mCurrentProcess != nullptr) {
        mXAppendQueue.prepend({ prompt, mode, isValidation ? XJobKind::ValidationSend : XJobKind::Dictation, enqueuedAtMs });
        mXAutoAppendLog->append(QString("<span style='color:#888;'>[WAIT]</span> Daemon busy, %1 block(s) queued")
            .arg(mXAppendQueue.size()));
        return;
    }

    const QString usedModel = currentModelKey();
    const bool useLeanPrompt = (mode != "append") && mXLeanPromptCheck && mXLeanPromptCheck->isChecked();
    const QString modeBadge = useLeanPrompt
        ? (mode.toUpper() + QString::fromUtf8(" \xC2\xB7 LEAN"))
        : mode.toUpper();

    qDebug() << "[CrossAppend] submitCrossAppendForBlock called"
             << "| mode:" << mode
             << "| model:" << usedModel
             << "| lean:" << useLeanPrompt
             << "| validation:" << isValidation
             << "| prompt:" << prompt.left(80)
             << "| mDaemonBusy:" << mDaemonBusy;

    mFullStatusText = isValidation ? tr("Processing Cross-Append (validation)...") : tr("Processing Cross-Append...");
    mStatusBtn->setText(mFullStatusText);

    const QString timerBadgeHtml = startXPromptTimer(enqueuedAtMs);
    if (isValidation) {
        mXAutoAppendLog->append(QString("<span style='color:#9b59b6;'>[VALIDATION - SENDING - %1]</span> <span style='color:#7fb3d5;'>[%2]</span> %3 <span style='color:#ddd;'>%4</span>")
            .arg(modeBadge, usedModel.toHtmlEscaped(), timerBadgeHtml, prompt.left(100).toHtmlEscaped()));
    } else {
        mXAutoAppendLog->append(QString("<span style='color:#f39c12;'>[SENDING - %1]</span> <span style='color:#7fb3d5;'>[%2]</span> %3 <span style='color:#ddd;'>%4</span>")
            .arg(modeBadge, usedModel.toHtmlEscaped(), timerBadgeHtml, prompt.left(100).toHtmlEscaped()));
    }
        
    Document* doc = Main::instance()->documentManager()->activeDocument();
    if (doc) {
        QString docText = doc->textDocument()->toPlainText();
        if (!docText.contains("History.clear.start;")) {
            QTextCursor cursor(doc->textDocument());
            cursor.movePosition(QTextCursor::Start);
            QString startCode = "History.clear.start;";
            cursor.insertText(startCode + "\n\n");
            Main::evaluateCode(startCode);

            cursor.movePosition(QTextCursor::End);
            QString timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
            QString endCode = QString("\n\n//History.end;\n//History.saveStory(\"C:/Users/Bruno Gazoni/Desktop/supercollider-project/supercollider-AI-assist/sc-gen-rag/sc-files/session-recordings/%1.scd\");\n").arg(timestamp);
            cursor.insertText(endCode);
        }
    }

    QJsonObject data = basePayload();
    data["prompt"] = prompt;
    data["mode"] = mode;
    data["lean_prompt"] = useLeanPrompt;
    data["composition_state"] = mCompositionState;
    data["use_kb"] = mXUseKbCheck->isChecked();
    data["model"] = usedModel;
    
    // Pass appropriate sys_msgs depending on the mode (used when lean_prompt is false, or for append)
    if (mode == "append") {
        data["sys_msgs"] = QJsonArray::fromStringList(mAppendSysMsgs);
    } else if (mode == "compose") {
        data["plan_sys_msgs"] = QJsonArray::fromStringList(mComposePlanSysMsgs);
        data["code_sys_msgs"] = QJsonArray::fromStringList(mComposeCodeSysMsgs);
        data["include_ending"] = true; // explicitly asked by user
    } else if (mode == "design") {
        data["plan_sys_msgs"] = QJsonArray::fromStringList(mDesignPlanSysMsgs);
        data["code_sys_msgs"] = QJsonArray::fromStringList(mDesignCodeSysMsgs);
    } else if (mode == "generate") {
        data["plan_sys_msgs"] = QJsonArray::fromStringList(mGenPlanSysMsgs);
        data["code_sys_msgs"] = QJsonArray::fromStringList(mGenCodeSysMsgs);
    }

    const QString okTag = isValidation ? QStringLiteral("[VALIDATION OK]") : QStringLiteral("[OK]");
    mXCurrentPrompt = prompt;
    mXCurrentModel = usedModel;
    runBackendCommand("cross_append", data, [this, mode, prompt, okTag, useLeanPrompt](const QJsonObject& result) {
        QString code = result["code"].toString();
        QString plan = result["plan"].toString(); // empty for append and lean_prompt
        QString fallbackCode = result["rag_fallback"].toString();
        mRagFallbackCode = fallbackCode;
        mPendingFallbackMode = mode;
        
        qDebug() << "[CrossAppend] cross_append callback received"
                 << "| hasCode:" << !code.isEmpty()
                 << "| hasFallback:" << !fallbackCode.isEmpty()
                 << "| mode:" << mode
                 << "| lean:" << useLeanPrompt;
                 
        if (!plan.isEmpty()) {
            mXAutoAppendLog->append(QString("<span style='color:#3498db;'>[PLAN]</span> Generated %1 chars").arg(plan.length()));
            
            // Mirror to original tabs for visualization (only when 2-step plan was used)
            if (mode == "compose") {
                mComposePrompt->setPlainText(prompt);
                mComposePlanOutput->setPlainText(plan);
            } else if (mode == "design") {
                mDesignPrompt->setPlainText(prompt);
                mDesignPlanOutput->setPlainText(plan);
            } else if (mode == "generate") {
                mGenPrompt->setPlainText(prompt);
                mGenPlanOutput->setPlainText(plan);
            }
        } else if (mode == "append") {
            // Mirror to Append tab
            mAppendPrompt->setPlainText(prompt);
        }

        if (code.trimmed().isEmpty()) {
            mXAutoAppendLog->append("<span style='color:#e74c3c;'>[WARN]</span> LLM returned empty code");
            if (!fallbackCode.isEmpty()) {
                QString fbKind = (mode == "design") ? tr("Randomized Subtractive Synth") : tr("RAG Block");
                mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[FALLBACK - %1]</span> Applying %2 fallback due to empty LLM code...")
                    .arg(mode.toUpper()).arg(fbKind));
                runRagFailsafeCode(fallbackCode, mode, [this, mode]() {
                    double totalSec = finishXPromptTimer(QStringLiteral("#e67e22"));
                    mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[FALLBACK OK - %1]</span> Fallback block inserted + evaluated (%2s)")
                        .arg(mode.toUpper()).arg(totalSec, 0, 'f', 1));
                    mRagFallbackCode.clear();
                    processXAppendQueue();
                });
            } else {
                finishXPromptTimer(QStringLiteral("#e74c3c"));
                processXAppendQueue();
            }
            return;
        }

        const int maxFixAttempts = (mXAutoFixCheck && mXAutoFixCheck->isChecked() && mXAutoFixAttemptsCombo)
            ? qBound(1, mXAutoFixAttemptsCombo->currentData().toInt(), 5)
            : 0;
        mXErrorCheckInFlight = false;
        mXLastInsertedChunk.clear();
        mXLastNavEntryId = 0;
        mXLastNavDoc = nullptr;
        validateAndCommitOrFixXAppend(code, mode, okTag, fallbackCode, 0, maxFixAttempts);
    });
}

void AiAssistWidget::onMainServerErrorAutoFix() {
    if (!mXErrorCheckInFlight) return;
    mXErrorCheckInFlight = false;

    const QString candidateCode = mXCurrentCandidateCode;
    const QString mode = mXCurrentMode;
    const QString okTag = mXCurrentOkTag;
    const QString fallbackCode = mRagFallbackCode;
    const int fixAttempt = mXCurrentFixAttempt;
    const int maxFixAttempts = mXCurrentMaxFixAttempts;
    const QString errTrace = mLastStackTrace.trimmed().isEmpty()
        ? tr("Runtime error detected on main server")
        : mLastStackTrace;

    // Remove the broken block (and its quiet lines) that was just inserted into the document
    if (!mXLastInsertedChunk.isEmpty()) {
        Document* doc = Main::instance()->documentManager()->activeDocument();
        if (doc) {
            QString docText = doc->textDocument()->toPlainText();
            int idx = docText.lastIndexOf(mXLastInsertedChunk);
            if (idx != -1) {
                QTextCursor cursor(doc->textDocument());
                cursor.setPosition(idx);
                cursor.setPosition(idx + mXLastInsertedChunk.length(), QTextCursor::KeepAnchor);
                cursor.removeSelectedText();
            }
        }
        mXLastInsertedChunk.clear();
    }
    if (mXLastNavDoc && mXLastNavEntryId > 0) {
        removePromptNavEntry(mXLastNavDoc, mXLastNavEntryId);
        mXLastNavEntryId = 0;
        mXLastNavDoc = nullptr;
    }

    QString firstErrLine = errTrace.trimmed().section('\n', 0, 0).trimmed();
    QString errSummary = firstErrLine.isEmpty() ? tr("Main server runtime error") : firstErrLine.left(220);
    if (fixAttempt == 0) {
        mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[MAIN-SERVER \xE2\x9C\x96]</span> Main server runtime error (%1): <span style='color:#f1948a;'>%2</span>")
            .arg(mode.toUpper()).arg(errSummary.toHtmlEscaped()));
    } else {
        mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[MAIN-SERVER \xE2\x9C\x96]</span> Auto-Fix #%1/%2 main server error (%3): <span style='color:#f1948a;'>%4</span>")
            .arg(fixAttempt).arg(maxFixAttempts).arg(mode.toUpper()).arg(errSummary.toHtmlEscaped()));
    }

    if (fixAttempt >= maxFixAttempts) {
        applyRagFallback();
        return;
    }

    const QString fixModel = currentModelKey();
    mXCurrentModel = fixModel;
    const int nextAttempt = fixAttempt + 1;
    mXAutoAppendLog->append(QString("<span style='color:#f39c12;'>[AUTO-FIX \xF0\x9F\x94\xA7 #%1/%2 - %3]</span> <span style='color:#7fb3d5;'>[%4]</span> Sending failed block + main-server stack trace through Fix pipeline...")
        .arg(nextAttempt).arg(maxFixAttempts).arg(mode.toUpper(), fixModel.toHtmlEscaped()));
    mFullStatusText = tr("Auto-Fix (%1/%2) for %3...").arg(nextAttempt).arg(maxFixAttempts).arg(mode);
    mStatusBtn->setText(mFullStatusText);
    if (mValServerStatusLabel) {
        mValServerStatusLabel->setText(tr("\xF0\x9F\x94\xA7 Auto-Fix #%1/%2").arg(nextAttempt).arg(maxFixAttempts));
        mValServerStatusLabel->setStyleSheet(
            "QLabel { background-color: #7e5109; color: #f8c471; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
    }

    QJsonObject fixData = basePayload();
    fixData["block"] = candidateCode;
    fixData["error"] = errTrace;
    fixData["mode"] = mode;
    fixData["is_cross_append"] = true;
    fixData["model"] = currentModelKey();
    fixData["sys_msgs"] = QJsonArray::fromStringList(mFixSysMsgs);

    runBackendCommand("fix", fixData, [this, candidateCode, mode, okTag, fallbackCode, nextAttempt, maxFixAttempts](const QJsonObject& fixResult) {
        QString fixedCode = fixResult["code"].toString();
        if (fixedCode.trimmed().isEmpty()) {
            mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[AUTO-FIX \xE2\x9C\x96 #%1/%2]</span> Fix pipeline returned empty code.")
                .arg(nextAttempt).arg(maxFixAttempts));
            // Continue with candidateCode so if nextAttempt < maxFixAttempts we still try remaining attempts,
            // and only trigger failsafe when nextAttempt == maxFixAttempts.
            validateAndCommitOrFixXAppend(candidateCode, mode, okTag, fallbackCode, nextAttempt, maxFixAttempts);
            return;
        }
        validateAndCommitOrFixXAppend(fixedCode, mode, okTag, fallbackCode, nextAttempt, maxFixAttempts);
    });
}

void AiAssistWidget::validateAndCommitOrFixXAppend(const QString& candidateCode, const QString& mode,
                                                   const QString& okTag, const QString& fallbackCode,
                                                   int fixAttempt, int maxFixAttempts) {
    if (fixAttempt == 0) {
        mXAutoAppendLog->append(QString("<span style='color:#5dade2;'>[VAL-SERVER \xE2\x96\xB6]</span> Dry-running %1 block (%2 chars) on parallel validation server...")
            .arg(mode.toUpper()).arg(candidateCode.length()));
    } else {
        mXAutoAppendLog->append(QString("<span style='color:#5dade2;'>[VAL-SERVER \xE2\x96\xB6]</span> Re-validating Auto-Fix #%1/%2 (%3, %4 chars) on parallel validation server...")
            .arg(fixAttempt).arg(maxFixAttempts).arg(mode.toUpper()).arg(candidateCode.length()));
    }

    validateCodeOnParallelServer(candidateCode, mode, [this, candidateCode, mode, okTag, fallbackCode, fixAttempt, maxFixAttempts](bool valid, const QString& valError) {
        auto applyFallbackNow = [this, mode, fallbackCode, fixAttempt, maxFixAttempts]() {
            mXErrorCheckInFlight = false;
            if (mValServerStatusLabel) {
                mValServerStatusLabel->setText(tr("\xE2\x9C\x96 Failed (Fallback)"));
                mValServerStatusLabel->setStyleSheet(
                    "QLabel { background-color: #641e16; color: #f1948a; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
            }
            if (fixAttempt > 0 && maxFixAttempts > 0) {
                mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[AUTO-FIX \xE2\x9C\x96]</span> Exhausted %1/%2 Auto-Fix attempt(s) without valid code \xE2\x86\x92 triggering failsafe...")
                    .arg(fixAttempt).arg(maxFixAttempts));
            }
            if (!fallbackCode.isEmpty()) {
                QString fbKind = (mode == "design") ? tr("Randomized Subtractive Synth") : tr("RAG Block");
                mXAutoAppendLog->append(QString("<span style='color:#e67e22;'>[FALLBACK \xE2\x9A\xA1 %1]</span> Skipping broken LLM block and applying %2 (%3 chars)...")
                    .arg(mode.toUpper()).arg(fbKind).arg(fallbackCode.length()));
                mFullStatusText = tr("Validation failed \xE2\x86\x92 applying %1 fallback").arg(mode);
                mStatusBtn->setText(mFullStatusText);
                runRagFailsafeCode(fallbackCode, mode, [this, mode]() {
                    double totalSec = finishXPromptTimer(QStringLiteral("#e67e22"));
                    mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[FALLBACK OK - %1]</span> Fallback block inserted + evaluated (%2s)")
                        .arg(mode.toUpper()).arg(totalSec, 0, 'f', 1));
                    mRagFallbackCode.clear();
                    processXAppendQueue();
                });
            } else {
                finishXPromptTimer(QStringLiteral("#e74c3c"));
                mFullStatusText = tr("Validation failed (no fallback available)");
                mStatusBtn->setText(mFullStatusText);
                processXAppendQueue();
            }
        };

        if (!valid) {
            // Mirror failed block + stack trace into the Fix tab fields
            mLastEvaluatedCode = candidateCode;
            mLastStackTrace = valError;
            if (mFixBlock) mFixBlock->setPlainText(candidateCode);
            if (mFixStackTrace) mFixStackTrace->setPlainText(valError);

            QString firstErrLine = valError.trimmed().section('\n', 0, 0).trimmed();
            QString errSummary = firstErrLine.isEmpty() ? tr("Unknown validation error") : firstErrLine.left(220);
            if (fixAttempt == 0) {
                mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[VAL-SERVER \xE2\x9C\x96]</span> Parallel validation failed (%1): <span style='color:#f1948a;'>%2</span>")
                    .arg(mode.toUpper()).arg(errSummary.toHtmlEscaped()));
            } else {
                mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[VAL-SERVER \xE2\x9C\x96]</span> Auto-Fix #%1/%2 validation failed (%3): <span style='color:#f1948a;'>%4</span>")
                    .arg(fixAttempt).arg(maxFixAttempts).arg(mode.toUpper()).arg(errSummary.toHtmlEscaped()));
            }

            // If Auto Fix is enabled and we still have attempts remaining, route through the Fix pipeline
            if (mXAutoFixCheck && mXAutoFixCheck->isChecked() && fixAttempt < maxFixAttempts) {
                const QString fixModel = currentModelKey();
                mXCurrentModel = fixModel;
                const int nextAttempt = fixAttempt + 1;
                mXAutoAppendLog->append(QString("<span style='color:#f39c12;'>[AUTO-FIX \xF0\x9F\x94\xA7 #%1/%2 - %3]</span> <span style='color:#7fb3d5;'>[%4]</span> Sending failed block + stack trace through Fix pipeline...")
                    .arg(nextAttempt).arg(maxFixAttempts).arg(mode.toUpper(), fixModel.toHtmlEscaped()));
                mFullStatusText = tr("Auto-Fix (%1/%2) for %3...").arg(nextAttempt).arg(maxFixAttempts).arg(mode);
                mStatusBtn->setText(mFullStatusText);
                if (mValServerStatusLabel) {
                    mValServerStatusLabel->setText(tr("\xF0\x9F\x94\xA7 Auto-Fix #%1/%2").arg(nextAttempt).arg(maxFixAttempts));
                    mValServerStatusLabel->setStyleSheet(
                        "QLabel { background-color: #7e5109; color: #f8c471; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
                }

                QJsonObject fixData = basePayload();
                fixData["block"] = candidateCode;
                fixData["error"] = valError;
                fixData["mode"] = mode;
                fixData["is_cross_append"] = true;
                fixData["model"] = currentModelKey();
                fixData["sys_msgs"] = QJsonArray::fromStringList(mFixSysMsgs);

                runBackendCommand("fix", fixData, [this, candidateCode, mode, okTag, fallbackCode, nextAttempt, maxFixAttempts, applyFallbackNow](const QJsonObject& fixResult) {
                    QString fixedCode = fixResult["code"].toString();
                    if (fixedCode.trimmed().isEmpty()) {
                        mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[AUTO-FIX \xE2\x9C\x96 #%1/%2]</span> Fix pipeline returned empty code.")
                            .arg(nextAttempt).arg(maxFixAttempts));
                        if (nextAttempt < maxFixAttempts) {
                            validateAndCommitOrFixXAppend(candidateCode, mode, okTag, fallbackCode, nextAttempt, maxFixAttempts);
                        } else {
                            applyFallbackNow();
                        }
                        return;
                    }
                    validateAndCommitOrFixXAppend(fixedCode, mode, okTag, fallbackCode, nextAttempt, maxFixAttempts);
                });
                return;
            }

            applyFallbackNow();
            return;
        }

        if (fixAttempt > 0) {
            mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[VAL-SERVER \xE2\x9C\x94]</span> Parallel server verified %1 block after Auto-Fix #%2/%3!")
                .arg(mode.toUpper()).arg(fixAttempt).arg(maxFixAttempts));
            if (mValServerStatusLabel) {
                mValServerStatusLabel->setText(tr("\xE2\x9C\x94 Fixed #%1 (57111)").arg(fixAttempt));
            }
        } else {
            mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[VAL-SERVER \xE2\x9C\x94]</span> Parallel server verified %1 block").arg(mode.toUpper()));
        }

        mXLastInsertedChunk.clear();
        mXLastNavEntryId = 0;
        mXLastNavDoc = nullptr;
        Document* doc = Main::instance()->documentManager()->activeDocument();
        if (doc) {
            const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
            const QString usedModel = mXCurrentModel.isEmpty() ? currentModelKey() : mXCurrentModel;
            const QString headerLine = PromptNavBar::formatHeaderComment(mode, navIdx, mXCurrentPrompt, usedModel);
            const QString trimmedCandidate = candidateCode.trimmed();
            const QString blockWithHeader = trimmedCandidate.startsWith(QStringLiteral("/// "))
                ? trimmedCandidate
                : (headerLine + QStringLiteral("\n") + trimmedCandidate);

            QTextCursor cursor(doc->textDocument());
            QString docText = doc->textDocument()->toPlainText();
            int historyIdx = docText.lastIndexOf("//History.end;");
            int codeStartPos = 0;
            QString insertedCodeChunk;
            if (historyIdx != -1) {
                cursor.setPosition(historyIdx);
                codeStartPos = historyIdx;
                insertedCodeChunk = blockWithHeader + "\n\n";
                cursor.insertText(insertedCodeChunk);
            } else {
                cursor.movePosition(QTextCursor::End);
                codeStartPos = cursor.position() + 2;
                insertedCodeChunk = "\n\n" + blockWithHeader;
                cursor.insertText(insertedCodeChunk);
            }
            mXLastNavDoc = doc;
            mXLastNavEntryId = registerPromptNavBlock(doc, mode, mXCurrentPrompt, codeStartPos, blockWithHeader, usedModel);

            // Volume quiet lines injection
            QRegularExpression ndefRx("Ndef\\(\\s*\\\\(\\w+)\\s*,");
            QRegularExpressionMatchIterator it = ndefRx.globalMatch(candidateCode);
            QStringList ndefNames;
            while (it.hasNext()) {
                QRegularExpressionMatch match = it.next();
                QString name = match.captured(1);
                if (!ndefNames.contains(name))
                    ndefNames.append(name);
            }
            QString quietLines;
            if (!ndefNames.isEmpty()) {
                quietLines = "// --- Quiet new textures (uncomment to reduce volume to ~1/10) ---\n";
                for (const QString& name : ndefNames) {
                    quietLines += QString("//Ndef(\\%1).set(\\amp, 0.03);\n").arg(name);
                }
                quietLines += "\n";
                
                QTextCursor endCursor(doc->textDocument());
                QString updatedText = doc->textDocument()->toPlainText();
                int quietIdx = updatedText.lastIndexOf("//History.end;");
                if (quietIdx != -1) {
                    endCursor.setPosition(quietIdx);
                    endCursor.insertText(quietLines);
                } else {
                    endCursor.movePosition(QTextCursor::End);
                    endCursor.insertText(quietLines);
                }
            }
            mXLastInsertedChunk = insertedCodeChunk + quietLines;

            const QString usedModelTag = mXCurrentModel.isEmpty() ? currentModelKey() : mXCurrentModel;
            if (mXAutoExecuteCheck->isChecked()) {
                mLastEvaluatedCode = candidateCode;
                mLastStackTrace.clear();
                updateLatestBlockFields();
                evaluateCodeBlocks(candidateCode);
                emit xAppendEvaluated(mode, navIdx, candidateCode);
                double totalSec = finishXPromptTimer(QStringLiteral("#2ecc71"));
                mFullStatusText = tr("Cross-Append (%1) validated + auto-evaluated (%2s)").arg(mode).arg(totalSec, 0, 'f', 1);
                mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>%1</span> <span style='color:#7fb3d5;'>[%2]</span> Code inserted (%3 chars) + auto-evaluated on main server <span style='color:#2ecc71; font-weight:bold;'>(%4s)</span>")
                    .arg(okTag, usedModelTag.toHtmlEscaped()).arg(candidateCode.length()).arg(totalSec, 0, 'f', 1));
            } else {
                double totalSec = finishXPromptTimer(QStringLiteral("#2ecc71"));
                mFullStatusText = tr("Cross-Append (%1) validated + inserted (%2s)").arg(mode).arg(totalSec, 0, 'f', 1);
                mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>%1</span> <span style='color:#7fb3d5;'>[%2]</span> Code inserted (%3 chars, validated) <span style='color:#2ecc71; font-weight:bold;'>(%4s)</span>")
                    .arg(okTag, usedModelTag.toHtmlEscaped()).arg(candidateCode.length()).arg(totalSec, 0, 'f', 1));
            }
        } else {
            finishXPromptTimer(QStringLiteral("#e74c3c"));
            mXAutoAppendLog->append("<span style='color:#e74c3c;'>[ERROR]</span> No active document");
        }

        mStatusBtn->setText(mFullStatusText);

        if (mXAutoExecuteCheck->isChecked()) {
            mXErrorCheckInFlight = true;
            mXCurrentCandidateCode = candidateCode;
            mXCurrentMode = mode;
            mXCurrentOkTag = okTag;
            mXCurrentFixAttempt = fixAttempt;
            mXCurrentMaxFixAttempts = maxFixAttempts;
            mWaitingForErrorCheck = true;
            mErrorCheckTimer->start(350);
            updateCancelButtonState();
        } else {
            mXErrorCheckInFlight = false;
            mRagVerifyQueue.enqueue({ candidateCode, mXCurrentPrompt, mode, true });
            processXAppendQueue();
            processRagVerifyQueue();
            updateCancelButtonState();
        }
    });
}

void AiAssistWidget::processXAppendQueue(bool logIfBusy) {
    if (mXAppendQueue.isEmpty()) {
        return;
    }
    if (mDaemonBusy || mCurrentProcess != nullptr || mValidationBusy || mXErrorCheckInFlight || mWaitingForErrorCheck) {
        if (logIfBusy) {
            mXAutoAppendLog->append(QString("<span style='color:#888;'>[WAIT]</span> Daemon busy, %1 block(s) queued")
                .arg(mXAppendQueue.size()));
        }
        return;
    }
    if (!mDaemonReady) {
        return;
    }

    XAppendJob job = mXAppendQueue.dequeue();
    if (job.kind == XJobKind::ValidationRag)
        submitXRagValidation(job.prompt, job.mode, job.enqueuedAtMs);
    else
        submitCrossAppendForBlock(job.prompt, job.mode, job.kind == XJobKind::ValidationSend, job.enqueuedAtMs);
}

// --- Cross-Append validation buttons (Send / RAG / P presets) ---

QString AiAssistWidget::xTestPromptsFilePath() const {
    QDir scriptDir(QFileInfo(backendScriptPath()).absolutePath());
    return scriptDir.filePath("xappend_test_prompts.json");
}

QString AiAssistWidget::xCorpusFilePath() const {
    QDir scriptDir(QFileInfo(backendScriptPath()).absolutePath());
    QString p200 = scriptDir.filePath("test-prompts/ptbr_xappend_corpus_200.json");
    if (QFileInfo::exists(p200))
        return p200;
    return scriptDir.filePath("test-prompts/ptbr_xappend_corpus_80.json");
}

bool AiAssistWidget::loadXCorpusFragments() {
    if (!mXCorpusFragments.isEmpty())
        return true;

    const QString path = xCorpusFilePath();
    QFile f(path);
    if (!f.exists() || !f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QMessageBox::warning(this, tr("Corpus Not Found"),
                             tr("Could not open corpus file:\n%1").arg(path));
        return false;
    }

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll(), &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        QMessageBox::warning(this, tr("Invalid Corpus"),
                             tr("Could not parse corpus JSON (%1):\n%2").arg(path, err.errorString()));
        return false;
    }

    const QJsonArray arr = doc.object().value("fragments").toArray();
    for (const QJsonValue& v : arr) {
        if (!v.isObject()) continue;
        const QJsonObject obj = v.toObject();
        if (!obj.value("text").toString().trimmed().isEmpty())
            mXCorpusFragments.append(obj);
    }
    if (mXCorpusFragments.isEmpty()) {
        QMessageBox::warning(this, tr("Empty Corpus"),
                             tr("No valid fragments found in:\n%1").arg(path));
        return false;
    }
    return true;
}

void AiAssistWidget::loadXTestPrompts() {
    // Seed defaults so every button is usable out of the box
    const QString defaultPrompt = QString::fromUtf8("Um oceano \xC3\xA9 um grande corpo de \xC3\xA1gua");
    for (const QString& kind : { QStringLiteral("send"), QStringLiteral("rag") })
        for (const QString& mode : { QStringLiteral("append"), QStringLiteral("compose"),
                                     QStringLiteral("design"), QStringLiteral("generate") })
            mXTestPrompts.insert(kind + "_" + mode, defaultPrompt);

    QFile f(xTestPromptsFilePath());
    if (!f.exists() || !f.open(QIODevice::ReadOnly | QIODevice::Text))
        return;
    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) return;
    QJsonObject obj = doc.object();
    for (auto it = obj.begin(); it != obj.end(); ++it)
        mXTestPrompts.insert(it.key(), it.value().toString());
}

void AiAssistWidget::saveXTestPrompts() {
    QJsonObject obj;
    for (auto it = mXTestPrompts.constBegin(); it != mXTestPrompts.constEnd(); ++it)
        obj[it.key()] = it.value();
    QFile f(xTestPromptsFilePath());
    if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        f.write(QJsonDocument(obj).toJson(QJsonDocument::Indented));
    } else {
        QMessageBox::warning(this, tr("Save Failed"),
                             tr("Could not write preset prompts to:\n%1").arg(xTestPromptsFilePath()));
    }
}

QWidget* AiAssistWidget::createXTestCell(const QString& kind, const QString& mode, const QString& label) {
    QWidget* cell = new QWidget;
    QHBoxLayout* h = new QHBoxLayout(cell);
    h->setContentsMargins(0, 0, 0, 0);
    h->setSpacing(2);

    const QString key = kind + "_" + mode;

    QPushButton* pBtn = new QPushButton(tr("P"));
    pBtn->setFixedWidth(22);
    pBtn->setToolTip(tr("Edit the preset validation prompt for \"%1\"").arg(label));
    connect(pBtn, &QPushButton::clicked, this, [this, key]() { onXTestPresetClicked(key); });
    h->addWidget(pBtn);

    if (kind == "send") {
        QPushButton* diceBtn = new QPushButton(QString::fromUtf8("\xF0\x9F\x8E\xB2"));
        diceBtn->setFixedWidth(24);
        diceBtn->setToolTip(tr("Pick a random prompt from the corpus for \"%1\"").arg(label));
        connect(diceBtn, &QPushButton::clicked, this, [this, key]() { onXTestRandomCorpusClicked(key); });
        h->addWidget(diceBtn);
    }

    QPushButton* actBtn = new QPushButton(label);
    if (kind == "send") {
        actBtn->setToolTip(tr("Send the \"P\" preset through the %1 cross-append flow (as if dictated)")
                               .arg(xModeLabel(mode)));
        connect(actBtn, &QPushButton::clicked, this, [this, mode]() { onXTestSendClicked(mode); });
    } else {
        actBtn->setToolTip(tr("Run the \"P\" preset through the RAG failsafe only (no LLM call)"));
        connect(actBtn, &QPushButton::clicked, this, [this, mode]() { onXTestRagClicked(mode); });
    }
    h->addWidget(actBtn, 1);
    return cell;
}

void AiAssistWidget::onXTestPresetClicked(const QString& key) {
    QString kind = key.section('_', 0, 0);
    QString mode = key.section('_', 1);
    QString title = QString("%1 %2").arg(kind == "rag" ? "RAG" : "Send", xModeLabel(mode));

    QDialog dlg(this);
    dlg.setWindowTitle(tr("Preset Prompt — %1").arg(title));
    dlg.resize(460, 220);
    QVBoxLayout* v = new QVBoxLayout(&dlg);
    v->addWidget(new QLabel(tr("Validation prompt for \"%1\":").arg(title)));
    QPlainTextEdit* edit = new QPlainTextEdit;
    edit->setPlainText(mXTestPrompts.value(key));
    v->addWidget(edit, 1);

    QHBoxLayout* btns = new QHBoxLayout;
    btns->addStretch();
    QPushButton* cancelBtn = new QPushButton(tr("Cancel"));
    QPushButton* saveBtn = new QPushButton(tr("Save"));
    saveBtn->setDefault(true);
    btns->addWidget(cancelBtn);
    btns->addWidget(saveBtn);
    v->addLayout(btns);
    connect(cancelBtn, &QPushButton::clicked, &dlg, &QDialog::reject);
    connect(saveBtn, &QPushButton::clicked, &dlg, &QDialog::accept);

    if (dlg.exec() == QDialog::Accepted) {
        mXTestPrompts.insert(key, edit->toPlainText().trimmed());
        saveXTestPrompts();
        mXAutoAppendLog->append(QString("<span style='color:#9b59b6;'>[VALIDATION]</span> Preset for %1 saved")
                                    .arg(title.toHtmlEscaped()));
    }
}

void AiAssistWidget::onXTestRandomCorpusClicked(const QString& key) {
    if (!loadXCorpusFragments())
        return;

    const int idx = QRandomGenerator::global()->bounded(mXCorpusFragments.size());
    const QJsonObject frag = mXCorpusFragments.at(idx);
    const QString text = frag.value("text").toString().trimmed();
    const int id = frag.value("id").toInt();
    QString genre = frag.value("textual_genre").toString();
    if (genre.isEmpty())
        genre = frag.value("category").toString();
    const QString source = frag.value("source").toString();

    mXTestPrompts.insert(key, text);
    saveXTestPrompts();

    const QString mode = key.section('_', 1);
    const QString title = QString("Send %1").arg(xModeLabel(mode));
    mXAutoAppendLog->append(
        QString("<span style='color:#9b59b6;'>[RANDOM PRESET]</span> %1 \u2192 #%2 [%3] (%4): <span style='color:#ddd;'>%5</span>")
            .arg(title.toHtmlEscaped())
            .arg(id)
            .arg(genre.toHtmlEscaped())
            .arg(source.toHtmlEscaped())
            .arg(text.left(90).toHtmlEscaped()));
}

void AiAssistWidget::appendXHistoryBlock(const QString& block) {
    // Same history formatting as a dictation_final block on the X-Append tab
    ++mXDictationBlockIndex;
    QString current = mXPrompt->toPlainText();
    if (!current.isEmpty())
        current += QString("\n%1) \u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\u2014\n").arg(mXDictationBlockIndex);
    current += block;
    mXPrompt->setPlainText(current);
    QTextCursor cursor = mXPrompt->textCursor();
    cursor.movePosition(QTextCursor::End);
    mXPrompt->setTextCursor(cursor);
}

void AiAssistWidget::onXTestSendClicked(const QString& mode) {
    if (!mDaemonReady) {
        QMessageBox::warning(this, tr("Not Ready"), tr("The AI daemon is not ready yet. Please wait."));
        return;
    }
    if (!hasApiKeyForCurrentModel()) {
        QMessageBox::warning(this, tr("Missing API Key"), tr("No API key found for the selected model/provider. Please configure it in the API settings."));
        return;
    }
    QString prompt = mXTestPrompts.value("send_" + mode).trimmed();
    if (prompt.isEmpty()) {
        QMessageBox::information(this, tr("Empty Preset"),
                                 tr("The \"P\" preset for Send %1 is empty.").arg(xModeLabel(mode)));
        return;
    }
    appendXHistoryBlock(prompt);
    mXAutoAppendLog->append(QString("<span style='color:#9b59b6;'>[VALIDATION #%1] Send %2 enqueued:</span> <span style='color:#ddd;'>%3</span>")
        .arg(mXDictationBlockIndex).arg(xModeLabel(mode)).arg(prompt.left(100).toHtmlEscaped()));
    mXAppendQueue.enqueue({ prompt, mode, XJobKind::ValidationSend, QDateTime::currentMSecsSinceEpoch() });
    processXAppendQueue(true);
}

void AiAssistWidget::onXTestRagClicked(const QString& mode) {
    if (!mDaemonReady) {
        QMessageBox::warning(this, tr("Not Ready"), tr("The AI daemon is not ready yet. Please wait."));
        return;
    }
    QString prompt = mXTestPrompts.value("rag_" + mode).trimmed();
    if (prompt.isEmpty() && mode != "design") {
        QMessageBox::information(this, tr("Empty Preset"),
                                 tr("The \"P\" preset for RAG %1 is empty.").arg(xModeLabel(mode)));
        return;
    }
    if (prompt.isEmpty() && mode == "design") {
        prompt = QStringLiteral("Randomized Subtractive Synthesizer");
    }
    appendXHistoryBlock(prompt);
    mXAutoAppendLog->append(QString("<span style='color:#9b59b6;'>[VALIDATION #%1] RAG %2 enqueued:</span> <span style='color:#ddd;'>%3</span>")
        .arg(mXDictationBlockIndex).arg(xModeLabel(mode)).arg(prompt.left(100).toHtmlEscaped()));
    mXAppendQueue.enqueue({ prompt, mode, XJobKind::ValidationRag, QDateTime::currentMSecsSinceEpoch() });
    processXAppendQueue(true);
}

void AiAssistWidget::submitXRagValidation(const QString& prompt, const QString& mode, qint64 enqueuedAtMs) {
    if (mDaemonBusy || mCurrentProcess != nullptr) {
        mXAppendQueue.prepend({ prompt, mode, XJobKind::ValidationRag, enqueuedAtMs });
        mXAutoAppendLog->append(QString("<span style='color:#888;'>[WAIT]</span> Daemon busy, %1 block(s) queued")
            .arg(mXAppendQueue.size()));
        return;
    }
    mXCurrentPrompt = prompt;
    const bool isDesignSynth = (mode == "design");
    mFullStatusText = isDesignSynth ? tr("Looking up design failsafe / synth fallback...") : tr("RAG validation lookup...");
    mStatusBtn->setText(mFullStatusText);
    const QString timerBadgeHtml = startXPromptTimer(enqueuedAtMs);
    mXAutoAppendLog->append(QString("<span style='color:#9b59b6;'>[VALIDATION - %1 %2]</span> %3 <span style='color:#ddd;'>%4: %5</span>")
        .arg(isDesignSynth ? "DESIGN FAILSAFE" : "RAG",
             mode.toUpper(),
             timerBadgeHtml,
             isDesignSynth ? "Looking up design failsafe / subtractive synth for" : "Looking up failsafe block for",
             prompt.left(100).toHtmlEscaped()));

    QJsonObject data;
    data["prompt"] = prompt;
    data["mode"] = mode;

    runBackendCommand("rag_lookup", data, [this, mode, prompt, isDesignSynth](const QJsonObject& result) {
        QString code = result["code"].toString();
        if (code.trimmed().isEmpty()) {
            finishXPromptTimer(QStringLiteral("#e74c3c"));
            mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[VALIDATION - RAG %1]</span> No fallback block found for this prompt")
                                        .arg(mode.toUpper()));
            mFullStatusText = tr("RAG validation: no match");
            mStatusBtn->setText(mFullStatusText);
            processXAppendQueue();
            return;
        }
        const bool isSubtractiveFallback = isDesignSynth && code.contains(QStringLiteral("subtractiveDesign"));
        const QString appliedKind = isSubtractiveFallback
            ? tr("randomized subtractive synth")
            : (isDesignSynth ? tr("design RAG failsafe block") : tr("RAG block"));
        mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[VALIDATION - FAILSAFE %1]</span> Clearing layers and applying %2 (%3 chars)...")
                                    .arg(mode.toUpper(), appliedKind)
                                    .arg(code.length()));
        runRagFailsafeCode(code, mode, [this, mode, isDesignSynth, isSubtractiveFallback]() {
            double totalSec = finishXPromptTimer(QStringLiteral("#2ecc71"));
            const QString doneKind = isSubtractiveFallback
                ? tr("Randomized subtractive synth")
                : (isDesignSynth ? tr("Design RAG failsafe block") : tr("RAG failsafe block"));
            mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[VALIDATION OK - %1]</span> %2 inserted + evaluated, composition state reset <span style='color:#2ecc71; font-weight:bold;'>(%3s)</span>")
                                        .arg(mode.toUpper(), doneKind)
                                        .arg(totalSec, 0, 'f', 1));
            mFullStatusText = isSubtractiveFallback
                ? tr("Subtractive synth fallback applied (%1s)").arg(totalSec, 0, 'f', 1)
                : tr("RAG validation applied (%1s)").arg(totalSec, 0, 'f', 1);
            mStatusBtn->setText(mFullStatusText);
            processXAppendQueue();
        }, prompt);
    });
}

void AiAssistWidget::onXDictateToggled() {
    if (!mDaemonProcess || !mDaemonReady) {
        QMessageBox::warning(this, tr("Not Ready"), tr("The AI daemon is not ready yet. Please wait."));
        mXDictateBtn->setChecked(false);
        mXDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
        return;
    }
    
    if (!mDictating && !hasApiKeyForCurrentModel()) {
        QMessageBox::warning(this, tr("Missing API Key"), tr("No API key found for the selected model/provider. Please configure it in the API settings before starting dictation."));
        mXDictateBtn->setChecked(false);
        mXDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
        return;
    }

    if (!mDictating) {
        mDictating = true;
        mXDictLangCombo->setEnabled(false);
        mXDictModelCombo->setEnabled(false);
        mFullStatusText = tr("Starting cross-append dictation...");
        mStatusBtn->setText(mFullStatusText);

        mXAutoAppendLog->append("<span style='color:#5dade2;'>[DICTATION]</span> Started");

        if (!mDictationModelLoaded && !mDictationLoadingDialog) {
            mDictationLoadingDialog = new QProgressDialog(tr("Starting microphone... Please wait."), QString(), 0, 0, this);
            mDictationLoadingDialog->setWindowTitle(tr("Voice Dictation"));
            mDictationLoadingDialog->setWindowModality(Qt::WindowModal);
            mDictationLoadingDialog->setCancelButton(nullptr);
            mDictationLoadingDialog->show();
        }

        QJsonObject cmd;
        cmd["command"] = QStringLiteral("start_dictation");
        cmd["model"] = mXDictModelCombo->currentData().toString();
        cmd["language"] = mXDictLangCombo->currentData().toString();
        QJsonDocument jsonDoc(cmd);
        mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
    } else {
        mDictating = false;
        mXDictLangCombo->setEnabled(true);
        mXDictModelCombo->setEnabled(true);
        mFullStatusText = tr("Stopping cross-append dictation...");
        mStatusBtn->setText(mFullStatusText);
        
        mXAutoAppendLog->append("<span style='color:#5dade2;'>[DICTATION]</span> Stopped");

        mXDictateMuteBtn->setChecked(false);
        mDictationMuted = false;
        mXAppendQueue.clear();

        QJsonObject cmd;
        cmd["command"] = QStringLiteral("stop_dictation");
        QJsonDocument jsonDoc(cmd);
        mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
    }
}

void AiAssistWidget::onXDictateMuteToggled() {
    if (!mDaemonProcess || !mDaemonReady) {
        mXDictateMuteBtn->setChecked(false);
        return;
    }
    mDictationMuted = mXDictateMuteBtn->isChecked();

    QJsonObject cmd;
    cmd["command"] = QStringLiteral("mute_dictation");
    cmd["muted"] = mDictationMuted;
    QJsonDocument jsonDoc(cmd);
    mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
    
    if (mDictationMuted) {
        mXAutoAppendLog->append("<span style='color:#f39c12;'>[DICTATION]</span> Muted");
    } else {
        mXAutoAppendLog->append("<span style='color:#f39c12;'>[DICTATION]</span> Unmuted");
    }
}

// --- Fix tab handler ---

void AiAssistWidget::onFixClicked() {
    QString block = mFixBlock->toPlainText().trimmed();
    QString error = mFixStackTrace->toPlainText().trimmed();
    if (block.isEmpty()) return;

    QJsonObject data;
    data["block"] = block;
    data["error"] = error;
    data["model"] = currentModelKey();
    data["sys_msgs"] = QJsonArray::fromStringList(mFixSysMsgs);

    runBackendCommand("fix", data, [this, block, error](const QJsonObject& result) {
        // Replace the old block with the fixed code in the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QString docText = doc->textDocument()->toPlainText();
                QString oldTrimmed = block.trimmed();
                QString newTrimmed = code.trimmed();
                int idx = docText.indexOf(oldTrimmed);
                if (idx != -1) {
                    QTextCursor cursor(doc->textDocument());
                    cursor.setPosition(idx);
                    cursor.setPosition(idx + oldTrimmed.length(), QTextCursor::KeepAnchor);
                    cursor.insertText(newTrimmed);
                    if (PromptNavBar* navBar = promptNavBar())
                        navBar->handleRangeReplaced(doc, idx, oldTrimmed.length(), newTrimmed);
                }
            }
            enqueueRagCandidate(code, error.left(120), QStringLiteral("fix"), false);
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
    data["model"] = currentModelKey();
    data["sys_msgs"] = QJsonArray::fromStringList(mRemakeSysMsgs);

    runBackendCommand("remake", data, [this, block, prompt](const QJsonObject& result) {
        // Replace the old block with the remade code in the active document
        QString code = result["code"].toString();
        if (!code.isEmpty()) {
            Document* doc = Main::instance()->documentManager()->activeDocument();
            if (doc) {
                QString docText = doc->textDocument()->toPlainText();
                QString oldTrimmed = block.trimmed();
                QString newTrimmed = code.trimmed();
                int idx = docText.indexOf(oldTrimmed);
                if (idx != -1) {
                    QTextCursor cursor(doc->textDocument());
                    cursor.setPosition(idx);
                    cursor.setPosition(idx + oldTrimmed.length(), QTextCursor::KeepAnchor);
                    cursor.insertText(newTrimmed);
                    if (PromptNavBar* navBar = promptNavBar())
                        navBar->handleRangeReplaced(doc, idx, oldTrimmed.length(), newTrimmed);
                }
            }
            enqueueRagCandidate(code, prompt, QStringLiteral("remake"), false);
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
    data["model"] = currentModelKey();
    data["sys_msgs"] = QJsonArray::fromStringList(mLearnSysMsgs);

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
    // 1. Flush any candidate still waiting in the post-evaluation 250ms/350ms error-check window
    if (mErrorCheckTimer && mErrorCheckTimer->isActive()) {
        mErrorCheckTimer->stop();
    }
    mWaitingForErrorCheck = false;
    if (mXErrorCheckInFlight && !mXCurrentCandidateCode.trimmed().isEmpty()) {
        mRagVerifyQueue.enqueue({ mXCurrentCandidateCode, mXCurrentPrompt, mXCurrentMode, true });
        mXCurrentCandidateCode.clear();
    }
    mXErrorCheckInFlight = false;
    if (!mPendingAppendRagCode.trimmed().isEmpty()) {
        mRagVerifyQueue.enqueue({ mPendingAppendRagCode, mPendingAppendRagPrompt, QStringLiteral("append"), false });
        mPendingAppendRagCode.clear();
        mPendingAppendRagPrompt.clear();
    }

    // 2. If the daemon is idle and we have queued RAG candidates not yet verified, give the async
    //    verification pipeline a window (up to 6s) to finish before stopping the validation server.
    if (!mDaemonBusy && mCurrentProcess == nullptr && (!mRagVerifyQueue.isEmpty() || mRagVerifyInFlight)) {
        processRagVerifyQueue();
        int drainElapsed = 0;
        while ((mRagVerifyInFlight || !mRagVerifyQueue.isEmpty()) && drainElapsed < 6000) {
            QApplication::processEvents();
            QThread::msleep(50);
            drainElapsed += 50;
        }
    }

    stopValidationServer();

    // Collect any remaining in-memory RAG candidates that did not finish async queueing before shutdown
    // so Python's `save_session_log` can verify and ingest them via headless `sclang -i scval`.
    Document* activeDoc = Main::instance()->documentManager()->activeDocument();
    QString activeFilePath = activeDoc ? activeDoc->filePath() : QString();
    QJsonArray extraRagCandidates;
    auto pushExtraCandidate = [&](const PendingRagCandidate& cand) {
        if (cand.code.trimmed().isEmpty()) return;
        QJsonObject cObj;
        cObj["code"] = cand.code;
        cObj["prompt"] = cand.prompt;
        cObj["hint_mode"] = cand.hintMode.isEmpty() ? QStringLiteral("append") : cand.hintMode;
        cObj["val_server_verified"] = cand.alreadyValidatedGate1;
        cObj["active_file"] = activeFilePath;
        extraRagCandidates.append(cObj);
    };
    if (mRagVerifyInFlight && !mActiveRagCandidate.code.trimmed().isEmpty()) {
        pushExtraCandidate(mActiveRagCandidate);
        mActiveRagCandidate = PendingRagCandidate();
        mRagVerifyInFlight = false;
    }
    while (!mRagVerifyQueue.isEmpty()) {
        pushExtraCandidate(mRagVerifyQueue.dequeue());
    }

    // Auto-save session state for the current file before shutdown
    if (activeDoc) {
        saveSessionFor(activeDoc);
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

    QString pendingRagPath = scriptDir + "/use-logs/.pending_rag_blocks.json";
    bool processRagBlocks = false;
    QJsonArray arr;
    if (QFile::exists(pendingRagPath)) {
        QFile ragFile(pendingRagPath);
        if (ragFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QJsonDocument ragDoc = QJsonDocument::fromJson(ragFile.readAll());
            ragFile.close();
            if (ragDoc.isArray()) {
                arr = ragDoc.array();
            }
        }
    }
    for (const QJsonValue& ev : extraRagCandidates) {
        QJsonObject eObj = ev.toObject();
        QJsonObject synthetic;
        synthetic["detected_mode"] = eObj["hint_mode"].toString("append");
        synthetic["num_exec_blocks"] = 1;
        synthetic["num_chunks"] = qMax(1, (eObj["code"].toString().length() + 3599) / 3600);
        synthetic["char_count"] = eObj["code"].toString().length();
        synthetic["val_server_verified"] = eObj["val_server_verified"].toBool(false);
        arr.append(synthetic);
    }

    if (!arr.isEmpty()) {
        int cntAppend = 0, execAppend = 0;
        int cntGenerate = 0, execGenerate = 0;
        int cntCompose = 0, execCompose = 0;
        int cntDesign = 0, execDesign = 0;
        int totalChunks = 0;
        int totalChars = 0;
        int unverifiedCount = 0;

        for (const QJsonValue& v : arr) {
            QJsonObject obj = v.toObject();
            QString m = obj["detected_mode"].toString("append");
            int nExec = obj["num_exec_blocks"].toInt(1);
            totalChunks += obj["num_chunks"].toInt(1);
            totalChars += obj["char_count"].toInt(0);
            if (!obj["val_server_verified"].toBool(false))
                ++unverifiedCount;

            if (m == "generate") { ++cntGenerate; execGenerate += nExec; }
            else if (m == "compose") { ++cntCompose; execCompose += nExec; }
            else if (m == "design") { ++cntDesign; execDesign += nExec; }
            else { ++cntAppend; execAppend += nExec; }
        }

        int totalExec = execAppend + execGenerate + execCompose + execDesign;
        const bool canUseWarmDaemon = (mDaemonProcess && mDaemonProcess->state() == QProcess::Running && mDaemonReady && !mDaemonBusy);
        double estSeconds = (canUseWarmDaemon ? 0.8 : 4.5) + (totalChunks * 0.12) + (totalExec * 0.02);
        if (!QDir(scriptDir + "/vectordb_knowledge_base").exists())
            estSeconds += 15.0;
        if (unverifiedCount > 0)
            estSeconds += 1.8 + (unverifiedCount * 0.15);

        double sizeKb = totalChars / 1024.0;
        QStringList breakdownLines;
        if (cntAppend > 0)   breakdownLines << tr("• Append: %1 block(s) (%2 executable () blocks)").arg(cntAppend).arg(execAppend);
        if (cntGenerate > 0) breakdownLines << tr("• Generate: %1 block(s) (%2 executable () blocks)").arg(cntGenerate).arg(execGenerate);
        if (cntCompose > 0)  breakdownLines << tr("• Compose: %1 block(s) (%2 executable () blocks)").arg(cntCompose).arg(execCompose);
        if (cntDesign > 0)   breakdownLines << tr("• Design: %1 block(s) (%2 executable () blocks)").arg(cntDesign).arg(execDesign);

        QString msg = tr(
            "Would you like the validation-verified blocks generated in this session to feed the failsafe RAGs?\n\n"
            "Session Blocks Analysed & Verified:\n%1\n"
            "Total: %2 executable () block(s) across %3 vector chunk(s) (%4 KB)\n\n"
            "Estimated Cost: $0.00 (100% programmatic & local embeddings, 0 LLM calls)\n"
            "Estimated Time: ~%5 seconds"
        ).arg(breakdownLines.join("\n"))
         .arg(totalExec)
         .arg(totalChunks)
         .arg(QString::number(sizeKb, 'f', 1))
         .arg(QString::number(estSeconds, 'f', 1));

        QMessageBox::StandardButton ragRes = QMessageBox::question(
            nullptr,
            tr("Feed Failsafe RAGs"),
            msg,
            QMessageBox::Yes | QMessageBox::No,
            QMessageBox::Yes
        );
        processRagBlocks = (ragRes == QMessageBox::Yes);
    }

    QJsonObject data;
    data["process_fixes"] = processFixes;
    data["process_rag_blocks"] = processRagBlocks;
    // Skip blocking Google Docs network sync on shutdown; connectDocumentSignals() syncs
    // completed session logs asynchronously in the background on next IDE startup.
    data["sync_to_docs"] = false;
    if (!extraRagCandidates.isEmpty()) {
        data["extra_rag_candidates"] = extraRagCandidates;
    }
    if (!activeFilePath.isEmpty()) {
        data["active_file"] = activeFilePath;
    }

    QString progressText = (processFixes && processRagBlocks)
        ? tr("Processing learnings & feeding failsafe RAGs...")
        : (processFixes ? tr("Processing session learnings...")
                        : (processRagBlocks ? tr("Feeding failsafe RAGs...") : tr("Saving session logs...")));
    QString titleText = (processFixes || processRagBlocks)
        ? tr("Closing — Processing")
        : tr("Closing — Saving");

    QProgressDialog progress(progressText, QString(), 0, 0, nullptr);
    progress.setWindowTitle(titleText);
    progress.setWindowModality(Qt::ApplicationModal);
    progress.setCancelButton(nullptr);
    progress.setMinimumDuration(0);
    progress.show();
    QApplication::processEvents();

    bool completedViaDaemon = false;
    if (mDaemonProcess && mDaemonProcess->state() == QProcess::Running && mDaemonReady && !mDaemonBusy) {
        // Fast path (~1-3s): execute save_session_log inside the already-warmed persistent daemon
        // (HuggingFace BGE embeddings & torch already in RAM — avoids 25-35s cold subprocess import)
        bool daemonDone = false;
        runBackendCommand("save_session_log", data, [&daemonDone](const QJsonObject&) {
            daemonDone = true;
        });
        const int maxWaitMs = (processFixes || processRagBlocks) ? 25000 : 4000;
        int waitedMs = 0;
        while (!daemonDone && mDaemonProcess && mDaemonProcess->state() == QProcess::Running && waitedMs < maxWaitMs) {
            QApplication::processEvents();
            QThread::msleep(50);
            waitedMs += 50;
        }
        completedViaDaemon = daemonDone;
    }

    if (!completedViaDaemon) {
        // Fallback path if the daemon was not running or busy
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
        proc.start(pythonPath(), args);
        const int maxFallbackMs = (processFixes || processRagBlocks) ? 45000 : 8000;
        int elapsed = 0;
        while (!proc.waitForFinished(200)) {
            QApplication::processEvents();
            elapsed += 200;
            if (elapsed >= maxFallbackMs) {
                proc.kill();
                break;
            }
        }
        QFile::remove(tempPath);
    }

    progress.close();
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

void AiAssistWidget::onGenPlanSysClicked() { openSysMessageEditor(mGenPlanSysMsgs); }
void AiAssistWidget::onGenCodeSysClicked() { openSysMessageEditor(mGenCodeSysMsgs); }
void AiAssistWidget::onDesignPlanSysClicked() { openSysMessageEditor(mDesignPlanSysMsgs); }
void AiAssistWidget::onDesignCodeSysClicked() { openSysMessageEditor(mDesignCodeSysMsgs); }
void AiAssistWidget::onComposePlanSysClicked() { openSysMessageEditor(mComposePlanSysMsgs); }
void AiAssistWidget::onComposeCodeSysClicked() { openSysMessageEditor(mComposeCodeSysMsgs); }
void AiAssistWidget::onAppSysClicked() { openSysMessageEditor(mAppendSysMsgs); }
void AiAssistWidget::onFixSysClicked() { openSysMessageEditor(mFixSysMsgs); }
void AiAssistWidget::onRemSysClicked() { openSysMessageEditor(mRemakeSysMsgs); }
void AiAssistWidget::onLearnSysClicked() { openSysMessageEditor(mLearnSysMsgs); }

void AiAssistWidget::saveSysMsgDefaults() {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    QString filePath = scriptDir.filePath("sys_msgs_defaults.json");

    QJsonObject obj;
    obj["gen_plan"] = QJsonArray::fromStringList(mGenPlanSysMsgs);
    obj["gen_code"] = QJsonArray::fromStringList(mGenCodeSysMsgs);
    obj["design_plan"] = QJsonArray::fromStringList(mDesignPlanSysMsgs);
    obj["design_code"] = QJsonArray::fromStringList(mDesignCodeSysMsgs);
    obj["compose_plan"] = QJsonArray::fromStringList(mComposePlanSysMsgs);
    obj["compose_code"] = QJsonArray::fromStringList(mComposeCodeSysMsgs);
    obj["append"] = QJsonArray::fromStringList(mAppendSysMsgs);
    obj["fix"] = QJsonArray::fromStringList(mFixSysMsgs);
    obj["remake"] = QJsonArray::fromStringList(mRemakeSysMsgs);
    obj["learn"] = QJsonArray::fromStringList(mLearnSysMsgs);
    obj["custom"] = QJsonArray::fromStringList(mCustomSelectedSysMsgs);

    QFile f(filePath);
    if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        f.write(QJsonDocument(obj).toJson(QJsonDocument::Indented));
    }
}

void AiAssistWidget::loadSysMsgDefaults() {
    QString backendScript = backendScriptPath();
    QDir scriptDir(QFileInfo(backendScript).absolutePath());
    QString filePath = scriptDir.filePath("sys_msgs_defaults.json");

    QFile f(filePath);
    if (!f.exists() || !f.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    QJsonDocument doc = QJsonDocument::fromJson(f.readAll());
    if (!doc.isObject()) return;
    QJsonObject obj = doc.object();

    auto load = [&](const QString& key, QStringList& target) {
        if (obj.contains(key)) {
            QJsonArray arr = obj[key].toArray();
            target.clear();
            for (int i = 0; i < arr.size(); ++i)
                target.append(arr[i].toString());
        }
    };
    load("gen_plan", mGenPlanSysMsgs);
    load("gen_code", mGenCodeSysMsgs);
    load("design_plan", mDesignPlanSysMsgs);
    load("design_code", mDesignCodeSysMsgs);
    load("compose_plan", mComposePlanSysMsgs);
    load("compose_code", mComposeCodeSysMsgs);
    load("append", mAppendSysMsgs);
    load("fix", mFixSysMsgs);
    load("remake", mRemakeSysMsgs);
    load("learn", mLearnSysMsgs);
    load("custom", mCustomSelectedSysMsgs);
}



void AiAssistWidget::onErrorCheckTimeout() {
    mWaitingForErrorCheck = false;
    bool wasXErrorInFlight = mXErrorCheckInFlight;
    mXErrorCheckInFlight = false;
    mXLastInsertedChunk.clear();
    mXLastNavEntryId = 0;
    mXLastNavDoc = nullptr;
    mRagFallbackCode.clear();
    mPendingFallbackMode.clear();

    if (wasXErrorInFlight && !mXCurrentCandidateCode.trimmed().isEmpty()) {
        mRagVerifyQueue.enqueue({ mXCurrentCandidateCode, mXCurrentPrompt, mXCurrentMode, true });
        mXCurrentCandidateCode.clear();
    } else if (!mPendingAppendRagCode.trimmed().isEmpty()) {
        mRagVerifyQueue.enqueue({ mPendingAppendRagCode, mPendingAppendRagPrompt, QStringLiteral("append"), false });
        mPendingAppendRagCode.clear();
        mPendingAppendRagPrompt.clear();
    }

    // Drain any queued user-facing Append / X-Append jobs FIRST; background RAG verification
    // only starts once the user queues are empty.
    processAppendQueue();
    processXAppendQueue();
    processRagVerifyQueue();
    updateCancelButtonState();
}

void AiAssistWidget::applyRagFallback() {
    mXErrorCheckInFlight = false;
    mXCurrentCandidateCode.clear();
    mPendingAppendRagCode.clear();
    mPendingAppendRagPrompt.clear();
    qDebug() << "[AutoAppend] applyRagFallback triggered! mode:" << mPendingFallbackMode;
    QString mode = mPendingFallbackMode.isEmpty() ? QStringLiteral("append") : mPendingFallbackMode;
    QString fbLabel = (mode == "design") ? tr("Randomized Subtractive Synth") : tr("RAG Block");

    mAutoAppendLog->append("<span style='color:#e74c3c;'>[RAG FAILSAFE]</span> LLM code errored! Clearing layers and applying fallback...");
    if (mXAutoAppendLog) {
        if (mXCurrentFixAttempt > 0 && mXCurrentMaxFixAttempts > 0) {
            mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[AUTO-FIX \xE2\x9C\x96]</span> Exhausted %1/%2 Auto-Fix attempt(s) \xE2\x86\x92 triggering %3 failsafe...")
                .arg(mXCurrentFixAttempt).arg(mXCurrentMaxFixAttempts).arg(fbLabel));
        }
        mXAutoAppendLog->append(QString("<span style='color:#e74c3c;'>[FAILSAFE - %1]</span> Main server runtime error detected! Clearing layers and applying %2...")
            .arg(mode.toUpper()).arg(fbLabel));
    }

    QString code = mRagFallbackCode;
    runRagFailsafeCode(code, mode, [this, mode]() {
        mRagFallbackCode.clear();
        mPendingFallbackMode.clear();
        if (mXAutoAppendLog) {
            mXAutoAppendLog->append(QString("<span style='color:#2ecc71;'>[FAILSAFE OK - %1]</span> Fallback block evaluated and composition state reset")
                .arg(mode.toUpper()));
        }
        processAppendQueue(); // Continue processing any pending dictates
        processXAppendQueue();
        updateCancelButtonState();
    });
}

void AiAssistWidget::runRagFailsafeCode(const QString& code, const QString& mode, std::function<void()> onDone,
                                        const QString& prompt) {
    QString effectivePrompt = prompt.trimmed();
    if (effectivePrompt.isEmpty())
        effectivePrompt = mXCurrentPrompt.trimmed();
    if (effectivePrompt.isEmpty())
        effectivePrompt = mPendingAppendRagPrompt.trimmed();
    // 1. Full server & client reset across all X-Append modes (append, generate, compose, design)
    //    so the performance starts cleanly from scratch with the failsafe block.
    QString resetScript = QStringLiteral(
        "(\n"
        "try { Tdef.all.do(_.stop); Tdef.removeAll } {};\n"
        "try { Pdef.all.do(_.stop); Pdef.removeAll } {};\n"
        "try { Ndef.clear(1) } {};\n"
        "if(~guiRoutine.notNil) { try { ~guiRoutine.stop } {}; ~guiRoutine = nil };\n"
        "[~mainWin, ~surWin, ~win, ~guiWin, ~synthWin].do { |w| if(w.notNil) { try { w.close } {} } };\n"
        "~mainWin = nil; ~surWin = nil; ~win = nil; ~guiWin = nil; ~synthWin = nil;\n"
        "try { Window.closeAll } {};\n"
        "try { MIDIdef.freeAll } {};\n"
        "if(~notes.notNil) { try { ~notes.do { |item| if(item.notNil) { if(item.isKindOf(Collection)) { item.do { |sn| if(sn.notNil) { try { sn.free } {} } } } { try { item.free } {} } } } } {}; ~notes = nil };\n"
        "if(~zoneNotes.notNil) { try { ~zoneNotes.do { |z| if(z.notNil) { z.do { |sn| if(sn.notNil) { try { sn.free } {} } } } } } {}; ~zoneNotes = nil };\n"
        "[~subSynth, ~monoSynth, ~leadSynth, ~droneSynth, ~synth, ~fxSynth, ~masterFx, ~celestialFx, ~ancientFx, ~reverbSynth, ~delaySynth, ~synthGroup, ~fxGroup, ~masterGroup, ~sourceGroup].do { |n| if(n.notNil) { try { n.free } {} } };\n"
        "~subSynth = nil; ~monoSynth = nil; ~leadSynth = nil; ~droneSynth = nil; ~synth = nil;\n"
        "~fxSynth = nil; ~masterFx = nil; ~celestialFx = nil; ~ancientFx = nil; ~reverbSynth = nil; ~delaySynth = nil;\n"
        "~synthGroup = nil; ~fxGroup = nil; ~masterGroup = nil; ~sourceGroup = nil;\n"
        "if(~buses.notNil) { try { ~buses.do { |b| if(b.notNil) { try { b.free } {} } } } {}; ~buses = nil };\n"
        "[~fxBus, ~celestialBus, ~ancientBus, ~reverbBus, ~delayBus, ~masterBus, ~synthBus].do { |b| if(b.notNil) { try { b.free } {} } };\n"
        "~fxBus = nil; ~celestialBus = nil; ~ancientBus = nil; ~reverbBus = nil; ~delayBus = nil; ~masterBus = nil; ~synthBus = nil;\n"
        ")"
    );
    Main::evaluateCode(resetScript);
    
    // 2. Wait 300ms to allow clears and frees to settle, then execute fallback from scratch
    QTimer::singleShot(300, this, [this, code, mode, effectivePrompt, onDone]() {
        // 3. Insert into active document
        Document* doc = Main::instance()->documentManager()->activeDocument();
        int fallbackNavIdx = 1;
        if (doc) {
            const int navIdx = promptNavBar() ? promptNavBar()->nextInteractionIndex(doc) : 1;
            fallbackNavIdx = navIdx;
            const QString failsafeModel = QStringLiteral("failsafe");
            const QString headerLine = PromptNavBar::formatHeaderComment(mode, navIdx, effectivePrompt, failsafeModel);
            QTextCursor cursor(doc->textDocument());
            QString docText = doc->textDocument()->toPlainText();
            int historyIdx = docText.lastIndexOf("//History.end;");
            int codeStartPos = 0;
            QString insertedBlock = headerLine + "\n// [FAILSAFE APPLIED]\n" + code.trimmed();
            if (historyIdx != -1) {
                cursor.setPosition(historyIdx);
                codeStartPos = historyIdx;
                cursor.insertText(insertedBlock + "\n\n");
            } else {
                cursor.movePosition(QTextCursor::End);
                codeStartPos = cursor.position() + 2;
                cursor.insertText("\n\n" + insertedBlock);
            }
            registerPromptNavBlock(doc, mode, effectivePrompt, codeStartPos, insertedBlock, failsafeModel);
        }
        
        // 4. Auto-execute the fallback block
        evaluateCodeBlocks(code);
        emit xAppendEvaluated(mode, fallbackNavIdx, code);
        
        // 5. Send reset_composition_state to the daemon (including mode and design tracker reset)
        QJsonObject cmd;
        cmd["command"] = "reset_composition_state";
        cmd["code"] = code;
        cmd["mode"] = mode;
        cmd["reset_design_tracker"] = (mode != "design");
        if (doc) {
            cmd["active_file"] = doc->filePath();
        }
        
        QJsonDocument jsonDoc(cmd);
        if (mDaemonProcess && mDaemonReady) {
            mDaemonProcess->write(jsonDoc.toJson(QJsonDocument::Compact) + "\n");
        }
        
        if (onDone) onDone();
    });
}

// --- Parallel Validation Server (sclang + muted parallel Server on Port 57111) ---

void AiAssistWidget::startValidationServer() {
    if (mValidationProcess) return;

    mValidationProcess = new QProcess(this);
    mValidationOutputBuffer.clear();
    mValidationReady = false;
    mValidationBusy = false;

    if (!mValidationTimeoutTimer) {
        mValidationTimeoutTimer = new QTimer(this);
        mValidationTimeoutTimer->setSingleShot(true);
        connect(mValidationTimeoutTimer, &QTimer::timeout, this, [this]() {
            if (!mValidationBusy) return;
            mValidationBusy = false;
            qWarning() << "[ValServer] Validation timed out; checking buffer for errors...";
            bool hasErr = mValidationOutputBuffer.contains("ERROR:", Qt::CaseInsensitive)
                       || mValidationOutputBuffer.contains("__VAL_ERROR__", Qt::CaseSensitive)
                       || mValidationOutputBuffer.contains("syntax error", Qt::CaseInsensitive);
            if (mValServerStatusLabel) {
                mValServerStatusLabel->setText(hasErr ? tr("✖ Failed (Timeout)") : tr("✔ Ready (57111)"));
                mValServerStatusLabel->setStyleSheet(hasErr
                    ? "QLabel { background-color: #641e16; color: #f1948a; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }"
                    : "QLabel { background-color: #145a32; color: #2ecc71; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
            }
            if (mValidationCallback) {
                auto cb = std::move(mValidationCallback);
                mValidationCallback = nullptr;
                cb(!hasErr, hasErr ? mValidationOutputBuffer : QString());
            }
            updateCancelButtonState();
            processXAppendQueue();
            processRagVerifyQueue();
        });
    }

    Settings::Manager* settings = Main::settings();
    settings->beginGroup("IDE/interpreter");
    QString workingDirectory = settings->value("runtimeDir").toString();
    QString configFile = settings->value("configFile").toString();
    settings->endGroup();

    QString sclangCommand;
#ifdef Q_OS_MAC
    sclangCommand = standardDirectory(ScResourceDir) + "/../MacOS/sclang";
#else
    QString appDirSclang = QDir(QApplication::applicationDirPath()).filePath("sclang.exe");
    if (QFileInfo::exists(appDirSclang))
        sclangCommand = appDirSclang;
    else
        sclangCommand = "sclang";
#endif

    QStringList sclangArguments;
    if (!configFile.isEmpty())
        sclangArguments << "-l" << configFile;
    // Use -i scval so Platform.ideName == "scval" (skips startup.scd and hardware audio/MIDI/window side-effects)
    // and a separate UDP port (57129) so it never collides with main sclang (57120)
    sclangArguments << "-i" << "scval" << "-u" << "57129";

    if (!workingDirectory.isEmpty())
        mValidationProcess->setWorkingDirectory(workingDirectory);

    connect(mValidationProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        if (!mValidationProcess) return;
        QString out = QString::fromUtf8(mValidationProcess->readAllStandardOutput());
        handleValidationServerOutput(out);
    });

    connect(mValidationProcess, &QProcess::readyReadStandardError, this, [this]() {
        if (!mValidationProcess) return;
        QString err = QString::fromUtf8(mValidationProcess->readAllStandardError());
        handleValidationServerOutput("ERROR: " + err);
    });

    connect(mValidationProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus) {
        mValidationReady = false;
        mValidationBusy = false;
        if (mValServerStatusLabel) {
            mValServerStatusLabel->setText(tr("Stopped (%1)").arg(exitCode));
            mValServerStatusLabel->setStyleSheet(
                "QLabel { background-color: #641e16; color: #f1948a; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
        }
        if (mValidationCallback) {
            auto cb = std::move(mValidationCallback);
            mValidationCallback = nullptr;
            cb(false, tr("Validation sclang process exited unexpectedly (code %1)").arg(exitCode));
        }
        updateCancelButtonState();
        processXAppendQueue();
        processRagVerifyQueue();
    });

    if (mValServerStatusLabel) {
        mValServerStatusLabel->setText(tr("● Booting (57111)..."));
        mValServerStatusLabel->setStyleSheet(
            "QLabel { background-color: #2c3e50; color: #f39c12; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
    }

    mValidationProcess->start(sclangCommand, sclangArguments, QIODevice::ReadWrite | QIODevice::Text);
}

void AiAssistWidget::stopValidationServer() {
    if (mValidationTimeoutTimer)
        mValidationTimeoutTimer->stop();
    mValidationCallback = nullptr;
    mValidationBusy = false;
    mValidationReady = false;

    if (mValidationProcess) {
        disconnect(mValidationProcess, nullptr, this, nullptr);
        if (mValidationProcess->state() == QProcess::Running) {
            QByteArray exitCmd = "if(s.notNil) { s.quit }; 0.exit\n\x0c";
            mValidationProcess->write(exitCmd);
            mValidationProcess->closeWriteChannel();
            if (!mValidationProcess->waitForFinished(1000)) {
                mValidationProcess->kill();
                mValidationProcess->waitForFinished(300);
            }
        }
        delete mValidationProcess;
        mValidationProcess = nullptr;
    }
}

void AiAssistWidget::handleValidationServerOutput(const QString& chunk) {
    if (chunk.isEmpty()) return;

    if (mValServerConsole) {
        mValServerConsole->moveCursor(QTextCursor::End);
        mValServerConsole->insertPlainText(chunk);
        QScrollBar* sb = mValServerConsole->verticalScrollBar();
        if (sb) sb->setValue(sb->maximum());
    }

    mValidationOutputBuffer += chunk;
    if (mValidationOutputBuffer.length() > 32000) {
        mValidationOutputBuffer = mValidationOutputBuffer.right(16000);
    }

    // 1. Detect initial class library compile completion -> configure parallel server on port 57111
    if (!mValidationReady && (mValidationOutputBuffer.contains("Welcome to SuperCollider")
                              || mValidationOutputBuffer.contains("compile done"))) {
        mValidationReady = true;
        mValidationOutputBuffer.clear();

        // Initialize the isolated parallel validation server on UDP port 57111 (virtual/sandboxed in scval)
        QString initScript = QStringLiteral(
            "(\n"
            "~valServer = Server(\\valServer, NetAddr(\"127.0.0.1\", 57111));\n"
            "~valServer.options.numOutputBusChannels = 2;\n"
            "~valServer.options.numInputBusChannels = 0;\n"
            "~valServer.options.memSize = 131072;\n"
            "Server.default = s = ~valServer;\n"
            "s.boot;\n"
            "\"__VAL_SERVER_BOOTED__\".postln;\n"
            "\"__VAL_INTERPRETER_READY__\".postln;\n"
            ")\n\x0c"
        );
        mValidationProcess->write(initScript.toUtf8());

        if (mValServerStatusLabel) {
            mValServerStatusLabel->setText(tr("✔ Ready (Port 57111)"));
            mValServerStatusLabel->setStyleSheet(
                "QLabel { background-color: #145a32; color: #2ecc71; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
        }
        if (mXAutoAppendLog) {
            mXAutoAppendLog->append("<span style='color:#2ecc71;'>[VAL-SERVER]</span> Parallel validation interpreter + muted server (UDP 57111) ready.");
        }
        return;
    }

    if (!mValidationBusy) return;

    // 2. Check for completion markers during active validation
    bool hasValidMarker = mValidationOutputBuffer.contains("__VAL_VALID__");
    bool hasErrorMarker = mValidationOutputBuffer.contains("__VAL_ERROR__:");

    if (!hasValidMarker && !hasErrorMarker) {
        return;
    }

    // Even if __VAL_VALID__ was printed at the end of the wrapper, check if sclang posted any
    // ERROR: / syntax error / Exception during compilation or execution of the candidate file
    QString errDetails;
    QString fullTrace;
    bool capturingTrace = false;
    QStringList lines = mValidationOutputBuffer.split('\n');
    for (const QString& line : lines) {
        QString trimmed = line.trimmed();
        if (trimmed.startsWith("WARNING:", Qt::CaseInsensitive) || trimmed.startsWith("INFO:", Qt::CaseInsensitive))
            continue;
        if (trimmed.contains("__VAL_VALID__"))
            continue;
        bool isErrTrigger = trimmed.contains("__VAL_ERROR__:")
            || trimmed.startsWith("ERROR:", Qt::CaseInsensitive)
            || trimmed.startsWith("Lexing Error", Qt::CaseInsensitive)
            || trimmed.startsWith("Parse Error", Qt::CaseInsensitive)
            || trimmed.contains("syntax error", Qt::CaseInsensitive)
            || trimmed.startsWith("!");
        if (isErrTrigger) {
            errDetails += trimmed + "\n";
            capturingTrace = true;
        }
        if (capturingTrace && !trimmed.isEmpty()) {
            fullTrace += line + "\n";
        }
    }

    bool isValid = hasValidMarker && !hasErrorMarker && errDetails.isEmpty();
    QString finalErrorText = errDetails.trimmed();
    if (!fullTrace.trimmed().isEmpty()) {
        finalErrorText = errDetails.trimmed() + "\n" + fullTrace.trimmed();
    }
    if (!isValid && finalErrorText.isEmpty()) {
        finalErrorText = mValidationOutputBuffer.right(600).trimmed();
    }

    mValidationBusy = false;
    if (mValidationTimeoutTimer)
        mValidationTimeoutTimer->stop();

    if (mValServerStatusLabel) {
        if (isValid) {
            mValServerStatusLabel->setText(tr("✔ Passed (57111)"));
            mValServerStatusLabel->setStyleSheet(
                "QLabel { background-color: #145a32; color: #2ecc71; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
        } else {
            mValServerStatusLabel->setText(tr("✖ Validation Error"));
            mValServerStatusLabel->setStyleSheet(
                "QLabel { background-color: #641e16; color: #f1948a; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
            // Auto-open the validation console on failure so the user can immediately inspect the error
            if (mValServerConsoleToggleBtn && !mValServerConsoleToggleBtn->isChecked()) {
                mValServerConsoleToggleBtn->setChecked(true);
            }
        }
    }

    if (mValidationCallback) {
        auto cb = std::move(mValidationCallback);
        mValidationCallback = nullptr;
        cb(isValid, finalErrorText);
    }
    updateCancelButtonState();
    processXAppendQueue();
    processRagVerifyQueue();
}

void AiAssistWidget::validateCodeOnParallelServer(const QString& code, const QString& mode,
                                                  std::function<void(bool valid, const QString& errorMsg)> callback) {
    // If validation process is not ready yet, fall back to allowing execution so main post-window check catches errors
    if (!mValidationProcess || mValidationProcess->state() != QProcess::Running || !mValidationReady) {
        qWarning() << "[ValServer] Parallel validation server not ready; proceeding to main evaluation.";
        callback(true, QString());
        return;
    }

    mValidationOutputBuffer.clear();
    mValidationBusy = true;
    mValidationCallback = std::move(callback);
    updateCancelButtonState();

    if (mValServerStatusLabel) {
        mValServerStatusLabel->setText(tr("● Validating %1...").arg(mode.toUpper()));
        mValServerStatusLabel->setStyleSheet(
            "QLabel { background-color: #1b4f72; color: #5dade2; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
    }

    // Write candidate code to a temporary file for parallel validation.
    // Convert asynchronous `.waitForBoot(` to synchronous `.do(` and `s.sync;` to `nil;`
    // in the temporary validation file so that the entire setup body inside `s.waitForBoot({ ... })`
    // (SynthDefs, Ndefs, Pbindefs, Tdef setup, MIDIdefs, and stray `.wait` checks) executes
    // synchronously inside `try { fn.value; }` before `__VAL_VALID__` is printed.
    QString valCode = code;
    valCode.replace(QRegularExpression("\\.\\s*waitForBoot\\s*\\("), QStringLiteral(".do("));
    valCode.replace(QRegularExpression("\\b(?:s|Server\\.default)\\s*\\.\\s*sync\\s*;"), QStringLiteral("nil;"));

    QString tempPath = QDir::tempPath() + "/sc_val_candidate.scd";
    QFile tempFile(tempPath);
    if (tempFile.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
        tempFile.write(valCode.toUtf8());
        tempFile.close();
    }

    QString escapedPath = tempPath;
    escapedPath.replace("\\", "/");

    // In the parallel validation sclang (-i scval):
    // 1. thisProcess.interpreter.compileFile(path) verifies syntax + var ordering + literals.
    // 2. Executing fn.value inside try { ... } verifies runtime execution, SynthDef UGen graph
    //    compilation, Ndef/Pbindef/Tdef setup, s.waitForBoot blocks, and GUI construction synchronously
    //    without opening hardware audio streams, MIDI ports, or visible windows.
    QString cleanupCmd = (mode == "append")
        ? QStringLiteral("Window.closeAll;")
        : QStringLiteral("CmdPeriod.run; Ndef.clear; Pdef.removeAll; Tdef.removeAll; MIDIdef.freeAll; Window.closeAll;");

    QString wrapper = QStringLiteral(
        "try {\n"
        "    var fn = thisProcess.interpreter.compileFile(\"%1\");\n"
        "    if(fn.isNil) {\n"
        "        \"__VAL_ERROR__: Syntax / compile error in generated code\".postln;\n"
        "    } {\n"
        "        fn.value;\n"
        "        try { %2 } { };\n"
        "        \"__VAL_VALID__\".postln;\n"
        "    };\n"
        "} { |err|\n"
        "    try { %2 } { };\n"
        "    (\"__VAL_ERROR__: \" ++ err.errorString).postln;\n"
        "};\n\x0c"
    ).arg(escapedPath, cleanupCmd);

    mValidationProcess->write(wrapper.toUtf8());
    mValidationTimeoutTimer->start(4500);
}

void AiAssistWidget::enqueueRagCandidate(const QString& code, const QString& prompt,
                                         const QString& hintMode, bool alreadyValidatedGate1) {
    if (code.trimmed().isEmpty())
        return;
    mRagVerifyQueue.enqueue({ code, prompt, hintMode, alreadyValidatedGate1 });
    processRagVerifyQueue();
}

void AiAssistWidget::processRagVerifyQueue() {
    if (mRagVerifyInFlight || mRagVerifyQueue.isEmpty())
        return;
    // Never start background RAG verification while user-facing X-Append or Append jobs are queued or in flight
    if (mDaemonBusy || mCurrentProcess != nullptr || mValidationBusy
        || mXErrorCheckInFlight || mWaitingForErrorCheck
        || !mXAppendQueue.isEmpty() || !mAppendQueue.isEmpty())
        return;
    if (!mDaemonReady)
        return;

    mRagVerifyInFlight = true;
    PendingRagCandidate item = mRagVerifyQueue.dequeue();
    mActiveRagCandidate = item;

    auto finishItem = [this]() {
        mActiveRagCandidate = PendingRagCandidate();
        mRagVerifyInFlight = false;
        updateCancelButtonState();
        processAppendQueue();
        processXAppendQueue();
        processRagVerifyQueue();
    };

    auto runPrepareAndGate2 = [this, item, finishItem]() {
        if (mDaemonBusy || mCurrentProcess != nullptr) {
            mRagVerifyQueue.prepend(item);
            mActiveRagCandidate = PendingRagCandidate();
            mRagVerifyInFlight = false;
            return;
        }
        QJsonObject prepData;
        prepData["code"] = item.code;
        prepData["mode"] = item.hintMode;

        runBackendCommand("prepare_rag_block", prepData, [this, item, finishItem](const QJsonObject& prepRes) {
            if (!prepRes["is_rag_eligible"].toBool(false)) {
                finishItem();
                return;
            }
            QString detectedMode = prepRes["detected_mode"].toString("append");
            QJsonArray execArr = prepRes["executable_blocks"].toArray();
            QStringList execBlocks;
            for (const QJsonValue& v : execArr) {
                QString b = v.toString();
                if (!b.trimmed().isEmpty()) execBlocks.append(b);
            }
            if (execBlocks.isEmpty()) {
                finishItem();
                return;
            }
            QString consolidated = prepRes["consolidated_block"].toString();

            validateRagExecutableBlocksOnServer(
                execBlocks,
                consolidated,
                detectedMode,
                [this, item, detectedMode, execArr, finishItem](bool valid, const QString& valErr) {
                    if (!valid) {
                        qWarning() << "[RAG-Feeder] Gate 2 validation rejected block (" << detectedMode << "):" << valErr.left(180);
                        finishItem();
                        return;
                    }
                    const bool verifiedOnServer = (mValidationProcess && mValidationProcess->state() == QProcess::Running && mValidationReady);
                    QJsonObject qData;
                    qData["code"] = item.code;
                    qData["prompt"] = item.prompt;
                    qData["origin_mode"] = item.hintMode;
                    qData["detected_mode"] = detectedMode;
                    qData["executable_blocks"] = execArr;
                    qData["val_server_verified"] = verifiedOnServer;

                    if (mDaemonBusy || mCurrentProcess != nullptr) {
                        PendingRagCandidate verifiedItem = item;
                        verifiedItem.alreadyValidatedGate1 = true;
                        mRagVerifyQueue.prepend(verifiedItem);
                        mActiveRagCandidate = PendingRagCandidate();
                        mRagVerifyInFlight = false;
                        return;
                    }
                    runBackendCommand("queue_rag_block", qData, [this, finishItem](const QJsonObject& qRes) {
                        QString st = qRes["status"].toString();
                        QString detMode = qRes["detected_mode"].toString("append");
                        int nExec = qRes["num_exec_blocks"].toInt(1);
                        int nChunks = qRes["num_chunks"].toInt(1);
                        qDebug() << "[RAG-Feeder] Queued block:" << st
                                 << "| mode:" << detMode
                                 << "| exec_blocks:" << nExec;
                        if (st == QStringLiteral("queued")) {
                            if (mXAutoAppendLog) {
                                mXAutoAppendLog->append(
                                    QString("<span style='color:#1abc9c;'>[RAG-FEEDER \xE2\x9C\x94]</span> Queued verified <b>%1</b> block (%2 executable () block(s), %3 chunk(s)) for shutdown failsafe KB prompt")
                                        .arg(detMode.toUpper()).arg(nExec).arg(nChunks));
                            }
                        } else if (st == QStringLiteral("duplicate") || st == QStringLiteral("duplicate_on_disk")) {
                            ++mSessionDuplicateRagCount;
                            if (mXAutoAppendLog) {
                                mXAutoAppendLog->append(
                                    QString("<span style='color:#95a5a6;'>[RAG-FEEDER]</span> Verified <b>%1</b> block already present in failsafe-%1.scd (deduplicated)")
                                        .arg(detMode));
                            }
                        }
                        finishItem();
                    });
                });
        });
    };

    if (!item.alreadyValidatedGate1 && mValidationProcess && mValidationProcess->state() == QProcess::Running && mValidationReady) {
        validateCodeOnParallelServer(item.code, item.hintMode, [runPrepareAndGate2, finishItem](bool valid, const QString& err) {
            if (!valid) {
                qWarning() << "[RAG-Feeder] Gate 1 validation rejected block:" << err.left(180);
                finishItem();
                return;
            }
            runPrepareAndGate2();
        });
    } else {
        runPrepareAndGate2();
    }
}

void AiAssistWidget::validateRagExecutableBlocksOnServer(
    const QStringList& execBlocks,
    const QString& consolidatedBlock,
    const QString& mode,
    std::function<void(bool valid, const QString& errorMsg)> callback)
{
    if (!mValidationProcess || mValidationProcess->state() != QProcess::Running || !mValidationReady) {
        // Validation server unavailable right now; Python shutdown scval batch verifier will handle it
        callback(true, QString());
        return;
    }

    mValidationOutputBuffer.clear();
    mValidationBusy = true;
    mValidationCallback = std::move(callback);
    updateCancelButtonState();

    if (mValServerStatusLabel) {
        mValServerStatusLabel->setText(tr("● Verifying RAG %1...").arg(mode.toUpper()));
        mValServerStatusLabel->setStyleSheet(
            "QLabel { background-color: #1b4f72; color: #5dade2; padding: 1px 6px; border-radius: 3px; font-size: 9px; font-weight: bold; }");
    }

    auto sanitizeForVal = [](QString src) {
        src.replace(QRegularExpression("\\.\\s*waitForBoot\\s*\\("), QStringLiteral(".do("));
        src.replace(QRegularExpression("\\b(?:s|Server\\.default)\\s*\\.\\s*sync\\s*;"), QStringLiteral("nil;"));
        return src;
    };

    QStringList execStmts;
    for (int i = 0; i < execBlocks.size(); ++i) {
        QString blkPath = QDir::tempPath() + QString("/sc_val_rag_blk_%1.scd").arg(i);
        QFile bf(blkPath);
        if (bf.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
            bf.write(sanitizeForVal(execBlocks[i]).toUtf8());
            bf.close();
        }
        blkPath.replace("\\", "/");
        execStmts << QStringLiteral(
            "fn = thisProcess.interpreter.compileFile(\"%1\"); "
            "if(fn.isNil) { ok = false; \"__VAL_ERROR__: Syntax/compile error in extracted () block\".postln } { fn.value };"
        ).arg(blkPath);
    }

    QString cleanupCmd = QStringLiteral("CmdPeriod.run; Ndef.clear; Pdef.removeAll; Tdef.removeAll; MIDIdef.freeAll; Window.closeAll;");
    QString consStmt;
    if (!consolidatedBlock.trimmed().isEmpty()) {
        QString consPath = QDir::tempPath() + QStringLiteral("/sc_val_rag_consolidated.scd");
        QFile cf(consPath);
        if (cf.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text)) {
            cf.write(sanitizeForVal(consolidatedBlock).toUtf8());
            cf.close();
        }
        consPath.replace("\\", "/");
        consStmt = QStringLiteral(
            "try { %1 } { }; "
            "fn = thisProcess.interpreter.compileFile(\"%2\"); "
            "if(fn.isNil) { ok = false; \"__VAL_ERROR__: Syntax/compile error in consolidated RAG block\".postln } { fn.value };"
        ).arg(cleanupCmd, consPath);
    }

    QString wrapper = QStringLiteral(
        "try {\n"
        "    var fn, ok = true;\n"
        "    %1\n"
        "    %2\n"
        "    try { %3 } { };\n"
        "    if(ok) { \"__VAL_VALID__\".postln };\n"
        "} { |err|\n"
        "    try { %3 } { };\n"
        "    (\"__VAL_ERROR__: \" ++ err.errorString).postln;\n"
        "};\n\x0c"
    ).arg(execStmts.join(" "), consStmt, cleanupCmd);

    mValidationProcess->write(wrapper.toUtf8());
    mValidationTimeoutTimer->start(6000);
}

void AiAssistWidget::evaluateCodeBlocks(const QString& evalCode) {
    QString code = evalCode;
    code.replace(QChar(0x2029), QChar('\n'));

    QStringList blocks;
    int depth = 0;
    int blockStart = -1;
    bool inLineComment = false;
    bool inBlockComment = false;
    bool inString = false;
    QChar stringChar;

    for (int i = 0; i < code.length(); i++) {
        QChar c = code[i];
        QChar next = (i + 1 < code.length()) ? code[i + 1] : QChar();

        if (inLineComment) {
            if (c == '\n') inLineComment = false;
            continue;
        }
        if (inBlockComment) {
            if (c == '*' && next == '/') { inBlockComment = false; i++; }
            continue;
        }
        if (inString) {
            if (c == stringChar) inString = false;
            continue;
        }
        if (c == '/' && next == '/') { inLineComment = true; i++; continue; }
        if (c == '/' && next == '*') { inBlockComment = true; i++; continue; }
        if (c == '"' || c == '\'') { inString = true; stringChar = c; continue; }

        if (c == '(') {
            if (depth == 0) blockStart = i;
            depth++;
        } else if (c == ')') {
            depth--;
            if (depth == 0 && blockStart >= 0) {
                blocks.append(code.mid(blockStart, i - blockStart + 1));
                blockStart = -1;
            }
        }
    }

    if (blocks.size() > 1) {
        qDebug() << "[AiAssist] Splitting" << blocks.size() << "top-level () blocks for evaluation";
        for (const QString& block : blocks) {
            Main::evaluateCode(block);
        }
    } else {
        Main::evaluateCode(code);
    }
}

} // namespace ScIDE




