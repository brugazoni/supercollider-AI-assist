#include <QDialog>
#include <QTreeWidget>
#include <QLineEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QMessageBox>

class OpenRouterBrowserDialog : public QDialog {
public:
    OpenRouterBrowserDialog(const QJsonArray& models, QWidget* parent = nullptr) 
        : QDialog(parent), mModels(models) 
    {
        setWindowTitle(tr("OpenRouter Model Browser"));
        resize(800, 500);

        QVBoxLayout* layout = new QVBoxLayout(this);

        QHBoxLayout* searchLayout = new QHBoxLayout;
        searchLayout->addWidget(new QLabel(tr("Search:")));
        mSearchBox = new QLineEdit;
        mSearchBox->setPlaceholderText(tr("Type to filter by name or ID..."));
        searchLayout->addWidget(mSearchBox);
        layout->addLayout(searchLayout);

        mTree = new QTreeWidget;
        mTree->setHeaderLabels({tr("Model"), tr("Context"), tr("Input ($/1M)"), tr("Output ($/1M)"), tr("ID")});
        mTree->setAlternatingRowColors(true);
        mTree->setSelectionBehavior(QAbstractItemView::SelectRows);
        mTree->setSelectionMode(QAbstractItemView::SingleSelection);
        
        mTree->header()->resizeSection(0, 300);
        mTree->header()->resizeSection(1, 100);
        mTree->header()->resizeSection(2, 100);
        mTree->header()->resizeSection(3, 100);
        
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
            if (item && item->parent()) { // Only allow selecting models (which have a parent provider)
                acceptSelection();
            }
        });

        populateTree("");
    }

    QString selectedModelId() const { return mSelectedId; }

private:
    QTreeWidget* mTree;
    QLineEdit* mSearchBox;
    QString mSelectedId;
    QJsonArray mModels;

    void populateTree(const QString& filter) {
        mTree->clear();
        QMap<QString, QTreeWidgetItem*> providers;

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
                provider[0] = provider[0].toUpper(); // Capitalize
            }

            if (!providers.contains(provider)) {
                QTreeWidgetItem* pItem = new QTreeWidgetItem(mTree);
                pItem->setText(0, provider);
                QFont boldFont = pItem->font(0);
                boldFont.setBold(true);
                pItem->setFont(0, boldFont);
                providers[provider] = pItem;
            }

            QTreeWidgetItem* mItem = new QTreeWidgetItem(providers[provider]);
            mItem->setText(0, name);
            
            int ctx = m["context_length"].toInt();
            QString ctxStr = ctx >= 1000 ? QString::number(ctx / 1000) + "k" : QString::number(ctx);
            mItem->setText(1, ctxStr);
            
            mItem->setText(2, QString::number(m["price_in"].toDouble(), 'f', 2));
            mItem->setText(3, QString::number(m["price_out"].toDouble(), 'f', 2));
            mItem->setText(4, id);
            
            // Store ID in Data
            mItem->setData(0, Qt::UserRole, id);
        }

        mTree->expandAll();
    }

    void acceptSelection() {
        QTreeWidgetItem* item = mTree->currentItem();
        if (!item || !item->parent()) {
            // Cannot select a provider node
            return;
        }
        mSelectedId = item->data(0, Qt::UserRole).toString();
        accept();
    }
};

