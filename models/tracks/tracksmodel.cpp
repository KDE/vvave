#include "tracksmodel.h"

TracksModel::TracksModel(QObject *parent) : BaseList(parent)
{

}

FMH::MODEL_LIST TracksModel::items() const
{
    return this->list;
}

void TracksModel::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    qDebug()<< "setting query"<< this->query;

    emit this->queryChanged();
}

QString TracksModel::getQuery() const
{
    return this->query;
}

void TracksModel::setSortBy(const uint &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

uint TracksModel::getSortBy() const
{
    return this->sort;
}
