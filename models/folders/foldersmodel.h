#ifndef FOLDERSMODEL_H
#define FOLDERSMODEL_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif


class FoldersModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QList<QUrl> folders READ folders WRITE setFolders NOTIFY foldersChanged)

public:
    FoldersModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override final;
    void setFolders(const QList<QUrl> &folders);
    QList<QUrl> folders () const;

private:
        FMH::MODEL_LIST list;
        QList<QUrl> m_folders;

signals:
        void foldersChanged();

};

#endif // FOLDERSMODEL_H
