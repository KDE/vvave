#include "foldersmodel.h"

FoldersModel::FoldersModel(QObject *parent) : MauiList(parent)
{}

FMH::MODEL_LIST FoldersModel::items() const
{
    return this->list;
}

void FoldersModel::setFolders(const QList<QUrl> &folders)
{
    if(m_folders == folders)
        return;

    m_folders = folders;

    emit this->preListChanged();
    this->list.clear();

    for(const auto &folder : m_folders)
    {
        this->list << FMH::getDirInfoModel(folder);
    }
    emit this->postListChanged();
    emit foldersChanged();
}

QList<QUrl> FoldersModel::folders() const
{
    return m_folders;
}
