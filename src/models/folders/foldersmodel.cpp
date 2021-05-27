#include "foldersmodel.h"
#include <MauiKit/FileBrowsing/fmstatic.h>

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

	emit this->preListChanged();
	this->list.clear();

    for(const auto &folder : std::as_const(m_folders))
	{
        this->list << FMStatic::getFileInfoModel(folder);
	}
	emit this->postListChanged();
	emit foldersChanged();
}

QList<QUrl> FoldersModel::folders() const
{
	return m_folders;
}
