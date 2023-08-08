#ifndef FOLDERSMODEL_H
#define FOLDERSMODEL_H

#include <QObject>

#include <MauiKit3/Core/mauilist.h>

class FoldersModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QList<QUrl> folders READ folders WRITE setFolders NOTIFY foldersChanged)

public:
    FoldersModel(QObject *parent = nullptr);

    const FMH::MODEL_LIST &items() const override final;
    void setFolders(const QList<QUrl> &folders);
    QList<QUrl> folders () const;
    void componentComplete() override final;

private:
        FMH::MODEL_LIST list;
        QList<QUrl> m_folders;

        void setList();

signals:
        void foldersChanged();

};

#endif // FOLDERSMODEL_H
