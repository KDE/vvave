#include "cloud.h"
#include "services/local/taginfo.h"

Cloud::Cloud(QObject *parent) : BaseList (parent)
{
    this->fm = new FM(this);
    this->setList();

//    connect(this->fm, &FM::cloudServerContentReady, [this](const FMH::MODEL_LIST &list, const QString &url)
//    {
//        Q_UNUSED(url);
//        emit this->preListChanged();
//        this->list = list;
//        this->formatList();
//        emit this->postListChanged();
//    });

    connect(this->fm, &FM::warningMessage, [this](const QString &message)
    {
        emit this->warning(message);
    });

    connect(this->fm, &FM::newItem, [this](const FMH::MODEL &item, const QString &path)
    {
        auto newItem = item;
        auto url = item[FMH::MODEL_KEY::URL];
        auto thumbnail = item[FMH::MODEL_KEY::THUMBNAIL];

        newItem[FMH::MODEL_KEY::FAV] = QString("0");
        newItem[FMH::MODEL_KEY::RATE] = QString("0");
        newItem[FMH::MODEL_KEY::URL] = FMH::fileExists(QUrl::fromLocalFile(thumbnail))? thumbnail : item[FMH::MODEL_KEY::URL];
        newItem[FMH::MODEL_KEY::SOURCE] = FMH::fileExists(QUrl::fromLocalFile(thumbnail))? thumbnail : item[FMH::MODEL_KEY::PATH];

        if(FMH::fileExists(QUrl::fromLocalFile(thumbnail)))
        {
            qDebug()<< "file exists:" << thumbnail;
            TagInfo info;
            info.feed(thumbnail);

            newItem[FMH::MODEL_KEY::ARTIST] = info.getArtist();
            newItem[FMH::MODEL_KEY::ALBUM] = info.getAlbum();
            newItem[FMH::MODEL_KEY::TITLE] = info.getTitle();
            newItem[FMH::MODEL_KEY::RELEASEDATE] = QString::number(info.getYear());
            newItem[FMH::MODEL_KEY::TRACK] = QString::number(info.getTrack());
        }else
            newItem[FMH::MODEL_KEY::TITLE] = item[FMH::MODEL_KEY::LABEL];

        emit this->preItemAppended();
        this->list << newItem;
        emit this->postItemAppended();

    });

    connect(this->fm, &FM::cloudItemReady, [this](const FMH::MODEL &item, const QString &path)
    {
        qDebug()<< "REQUESTED CLOUD IMAGE READY << " << item;
        Q_UNUSED(path);
        auto newItem = item;
        auto url = item[FMH::MODEL_KEY::URL];
        auto thumbnail = item[FMH::MODEL_KEY::THUMBNAIL];

        newItem[FMH::MODEL_KEY::FAV] = QString("0");
        newItem[FMH::MODEL_KEY::RATE] = QString("0");
        newItem[FMH::MODEL_KEY::URL] = FMH::fileExists(QUrl::fromLocalFile(thumbnail))? thumbnail : item[FMH::MODEL_KEY::URL];
        newItem[FMH::MODEL_KEY::SOURCE] = FMH::fileExists(QUrl::fromLocalFile(thumbnail))? thumbnail : item[FMH::MODEL_KEY::PATH];

        if(FMH::fileExists(QUrl::fromLocalFile(thumbnail)))
        {
            qDebug()<< "file exists:" << thumbnail;
            TagInfo info;
            info.feed(thumbnail);

            newItem[FMH::MODEL_KEY::ARTIST] = info.getArtist();
            newItem[FMH::MODEL_KEY::ALBUM] = info.getAlbum();
            newItem[FMH::MODEL_KEY::TITLE] = info.getTitle();
            newItem[FMH::MODEL_KEY::RELEASEDATE] = QString::number(info.getYear());
            newItem[FMH::MODEL_KEY::TRACK] = QString::number(info.getTrack());
        }else
            newItem[FMH::MODEL_KEY::TITLE] = item[FMH::MODEL_KEY::LABEL];


        this->update(FM::toMap(newItem), this->pending.take(QString(item[FMH::MODEL_KEY::PATH]).replace(FMH::CloudCachePath+"opendesktop", FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH])));
        emit this->cloudItemReady(FM::toMap(newItem));
    });
}

FMH::MODEL_LIST Cloud::items() const
{
    return this->list;
}

void Cloud::setAccount(const QString value)
{
    if(this->account == value)
        return;

    this->account = value;
    emit this->accountChanged();

    this->setList();
}

QString Cloud::getAccount() const
{
    return this->account;
}

void Cloud::setList()
{
    emit this->preListChanged();
    this->list.clear();
    this->fm->getCloudServerContent(FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+"/"+this->account, FMH::FILTER_LIST[FMH::FILTER_TYPE::AUDIO], 3);
    emit this->postListChanged();
}

void Cloud::formatList()
{
    for(auto &item : this->list)
    {
        auto url = item[FMH::MODEL_KEY::URL];
        auto thumbnail = item[FMH::MODEL_KEY::THUMBNAIL];

        item[FMH::MODEL_KEY::FAV] = QString("0");
        item[FMH::MODEL_KEY::RATE] = QString("0");
        item[FMH::MODEL_KEY::URL] = FMH::fileExists(QUrl::fromLocalFile(thumbnail))? thumbnail : item[FMH::MODEL_KEY::URL];
        item[FMH::MODEL_KEY::SOURCE] = FMH::fileExists(QUrl::fromLocalFile(thumbnail))? thumbnail : item[FMH::MODEL_KEY::PATH];

        qDebug()<< "CLOUD FILE" << thumbnail;

        if(FMH::fileExists(QUrl::fromLocalFile(thumbnail)))
        {
            qDebug()<< "file exists:" << thumbnail;
            TagInfo info;
            info.feed(thumbnail);

            item[FMH::MODEL_KEY::ARTIST] = info.getArtist();
            item[FMH::MODEL_KEY::ALBUM] = info.getAlbum();
            item[FMH::MODEL_KEY::TITLE] = info.getTitle();
            item[FMH::MODEL_KEY::RELEASEDATE] = QString::number(info.getYear());
            item[FMH::MODEL_KEY::TRACK] = QString::number(info.getTrack());
        }else
        {
            item[FMH::MODEL_KEY::TITLE] = item[FMH::MODEL_KEY::LABEL];
        }
    }
}

QVariantMap Cloud::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto item = this->list.at(index);

    for(auto key : item.keys())
        res.insert(FMH::MODEL_NAME[key], item[key]);

    return res;
}

void Cloud::requestFile(const int &index)
{
    if(index < 0 || index >= this->list.size())
        return;

    this->pending.insert(this->list[index][FMH::MODEL_KEY::PATH], index);
    qDebug()<< "1-PEDNIGN CLOUD"<< this->pending;

    this->fm->getCloudItem(FM::toMap(this->list[index]));
}

bool Cloud::update(const QVariantMap &data, const int &index)
{
    if(index < 0 || index >= this->list.size())
        return false;

    auto newData = this->list[index];
    QVector<int> roles;

    for(auto key : data.keys())
        if(newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString())
        {
            newData.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());
            roles << FMH::MODEL_NAME_KEY[key];
        }

    this->list[index] = newData;

    emit this->updateModel(index, roles);
    return true;
}

void Cloud::upload(const QString &url)
{
    this->fm->copy({FMH::getFileInfo(url)}, FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+"/"+this->account);
}
