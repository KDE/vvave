#include "cloud.h"
#include "abstractmusicprovider.h"
#include "NextCloud/nextmusic.h"

#ifdef STATIC_MAUIKIT
#include "mauiaccounts.h"
#else
#include <mauiaccounts.h>
#endif

Cloud::Cloud(QObject *parent) : MauiList (parent),
    provider(new NextMusic(this))
{
    connect(MauiAccounts::instance(), &MauiAccounts::currentAccountChanged, [this](QVariantMap account)
    {
        this->provider->setCredentials(FMH::toModel(account));
        this->setList();
    });

    connect(provider, &AbstractMusicProvider::collectionReady, [=](FMH::MODEL_LIST data)
    {
        emit this->albumsChanged();
        emit this->artistsChanged();

        emit this->preListChanged();
        this->list = data;
        this->sortList();
        emit this->postListChanged();
    });

    connect(static_cast<NextMusic *> (provider), &NextMusic::trackPathReady, [=](QString id, QString path)
    {
        auto track =  static_cast<NextMusic *> (provider)->getTrackItem(id);
        track[FMH::MODEL_KEY::URL] = path;
        emit this->fileReady(FMH::toMap(track));
    });
}

void Cloud::componentComplete()
{
    this->provider->setCredentials(FMH::toModel(MauiAccounts::instance()->getCurrentAccount()));
    this->setList();
}

void Cloud::setSortBy(const Cloud::SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;

    emit this->preListChanged();
    this->sortList();
    emit this->postListChanged();
    emit this->sortByChanged();
}

Cloud::SORTBY Cloud::getSortBy() const
{
    return this->sort;
}

QVariantList Cloud::getAlbums() const
{
    return this->provider->getAlbumsList();
}

QVariantList Cloud::getArtists() const
{
    return this->provider->getArtistsList();
}

FMH::MODEL_LIST Cloud::items() const
{
    return this->list;
}

void Cloud::setList()
{
    this->provider->getCollection();
}

void Cloud::sortList()
{
    if(this->sort == Cloud::SORTBY::NONE)
        return;

    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    std::sort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        switch(key)
        {
            case FMH::MODEL_KEY::RELEASEDATE:
            case FMH::MODEL_KEY::RATE:
            case FMH::MODEL_KEY::FAV:
            case FMH::MODEL_KEY::COUNT:
            {
                if(e1[key].toInt() > e2[key].toInt())
                    return true;
                break;
            }

            case FMH::MODEL_KEY::TRACK:
            {
                if(e1[key].toInt() < e2[key].toInt())
                    return true;
                break;
            }

            case FMH::MODEL_KEY::ADDDATE:
            {
                auto currentTime = QDateTime::currentDateTime();

                auto date1 = QDateTime::fromString(e1[key], Qt::TextDate);
                auto date2 = QDateTime::fromString(e2[key], Qt::TextDate);

                if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                    return true;

                break;
            }

            case FMH::MODEL_KEY::TITLE:
            case FMH::MODEL_KEY::ARTIST:
            case FMH::MODEL_KEY::ALBUM:
            case FMH::MODEL_KEY::FORMAT:
            {
                const auto str1 = QString(e1[key]).toLower();
                const auto str2 = QString(e2[key]).toLower();

                if(str1 < str2)
                    return true;
                break;
            }

            default:
                if(e1[key] < e2[key])
                    return true;
        }

        return false;
    });
}

QVariantMap Cloud::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto item = this->list.at(this->mappedIndex(index));

    for(auto key : item.keys())
        res.insert(FMH::MODEL_NAME[key], item[key]);

    return res;
}

QVariantList Cloud::getAll()
{
    return QVariantList();
}

void Cloud::upload(const QUrl &url)
{

}

void Cloud::getFileUrl(const QString &id)
{
    static_cast<NextMusic *>(this->provider)->getTrackPath(id);
}

void Cloud::getFileUrl(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return;

    this->getFileUrl(this->list.at(this->mappedIndex(index))[FMH::MODEL_KEY::ID]);
}
