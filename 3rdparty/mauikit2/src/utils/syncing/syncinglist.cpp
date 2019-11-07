#include "syncinglist.h"
#include "fm.h"

SyncingList::SyncingList(QObject *parent) : QObject(parent), fm(new FM(this))
{
	this->setList();
}

void SyncingList::setList()
{
    emit this->preListChanged();

    this->list = this->fm->getCloudAccounts();
	qDebug()<< "SYNCIGN LIST"<< list;

    emit this->postListChanged();
}

QVariantMap SyncingList::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

	return FMH::toMap(this->list.at(index));
}

void SyncingList::refresh()
{
    this->setList();
}

void SyncingList::insert(const QVariantMap& data)
{	
	auto model = FMH::toModel(data);
	
	if(this->fm->addCloudAccount(model[FMH::MODEL_KEY::SERVER], model[FMH::MODEL_KEY::USER], model[FMH::MODEL_KEY::PASSWORD]))
	{
		this->setList();
	}	
}

void SyncingList::removeAccount(const QString &server, const QString &user)
{		
	if(this->fm->removeCloudAccount(server, user))
	{
		this->refresh();
	}	
}

void SyncingList::removeAccountAndFiles(const QString &server, const QString &user)
{
	if(this->fm->removeCloudAccount(server, user))
	{
		this->refresh();
	}	
	
	this->fm->removeDir(FM::resolveUserCloudCachePath(server, user));
}

FMH::MODEL_LIST SyncingList::items() const
{
	return this->list;
}

