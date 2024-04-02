#include "foldersmodel.h"
#include <MauiKit4/FileBrowsing/fmstatic.h>

FoldersModel::FoldersModel(QObject *parent) : MauiList(parent)
{}

const FMH::MODEL_LIST &FoldersModel::items() const
{
	return this->list;
}

void FoldersModel::setFolders(const QList<QUrl> &folders)
{
	if(m_folders == folders)
		return;

	m_folders = folders;

    Q_EMIT foldersChanged();
}

QList<QUrl> FoldersModel::folders() const
{
	return m_folders;
}


void FoldersModel::componentComplete()
{
    connect(this, &FoldersModel::foldersChanged, this, &FoldersModel::setList);
    this->setList();
}

void FoldersModel::setList()
{
    if(m_folders.isEmpty())
    {
        return;
    }

    Q_EMIT this->preListChanged();
    this->list.clear();

    for(const auto &folder : std::as_const(m_folders))
    {
        this->list << FMStatic::getFileInfoModel(folder);
    }
    Q_EMIT this->postListChanged();
    Q_EMIT this->countChanged();
}
