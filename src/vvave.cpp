#include "vvave.h"

#include "db/collectionDB.h"
#include "services/local/taginfo.h"

#include <MauiKit/FileBrowsing/fileloader.h>
#include <MauiKit/FileBrowsing/fm.h>
#include <MauiKit/Core/utils.h>

#include <QTimer>

FMH::MODEL vvave::trackInfo(const QUrl &url)
{
    TagInfo info(url.toLocalFile());
    if (info.isNull())
        return FMH::MODEL();

    const auto track = info.getTrack();
    const auto genre = info.getGenre();
    const auto album = info.getAlbum();
    const auto title = info.getTitle(); /* to fix*/
    const auto artist = info.getArtist();
    const auto sourceUrl = FMStatic::parentDir(url).toString();
    const auto duration = info.getDuration();
    const auto year = info.getYear();
    const auto comment = info.getComment();

    FMH::MODEL map = {{FMH::MODEL_KEY::URL, url.toString()},
                      {FMH::MODEL_KEY::TRACK, QString::number(track)},
                      {FMH::MODEL_KEY::TITLE, title},
                      {FMH::MODEL_KEY::ARTIST, artist},
                      {FMH::MODEL_KEY::ALBUM, album},
                      {FMH::MODEL_KEY::COMMENT, comment},
                      {FMH::MODEL_KEY::DURATION, QString::number(duration)},
                      {FMH::MODEL_KEY::GENRE, genre},
                      {FMH::MODEL_KEY::SOURCE, sourceUrl},
                      {FMH::MODEL_KEY::RELEASEDATE, QString::number(year)}};

    BAE::artworkCache(map, FMH::MODEL_KEY::ALBUM);
    return map;
}

/*
 * Sets upthe app default config paths
 * BrainDeamon to get collection information
 * YoutubeFetcher ?
 *
 * */
vvave::vvave(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<QList<QUrl> *>("QList<QUrl>&");

    QDir dirPath(BAE::CachePath.toLocalFile());
    if (!dirPath.exists())
        dirPath.mkpath(".");
}

void vvave::setFetchArtwork(bool fetchArtwork)
{
    if (m_fetchArtwork == fetchArtwork)
        return;

    m_fetchArtwork = fetchArtwork;
    emit fetchArtworkChanged(m_fetchArtwork);
}

bool vvave::fetchArtwork() const
{
    return m_fetchArtwork;
}

void vvave::addSources(const QList<QUrl> &paths)
{
    auto urls = QUrl::fromStringList(sources());
    QList<QUrl> newUrls;

    for (const auto &path : paths) {
        if (!urls.contains(path)) {
            newUrls << path;
            emit sourceAdded(path);
        }
    }

    if (newUrls.isEmpty())
        return;

    urls << newUrls;
    UTIL::saveSettings("SETTINGS", QVariant::fromValue(QUrl::toStringList(urls)), "SOURCES");

    scanDir(urls);
    emit sourcesChanged();
}

bool vvave::removeSource(const QString &source)
{
    auto urls = this->sources();
    if (!urls.contains(source))
        return false;

    urls.removeOne(source);
    UTIL::saveSettings("SETTINGS", QVariant::fromValue(urls), "SOURCES");
    emit sourcesChanged();

    if (CollectionDB::getInstance()->removeSource(source)) {
        emit this->sourceRemoved(source);
        return true;
    }

    return false;
}

void vvave::scanDir(const QList<QUrl> &paths)
{
    auto fileLoader = new FMH::FileLoader();
    fileLoader->informer = &trackInfo;
    //    fileLoader->setBatchCount(50);

    connect(fileLoader, &FMH::FileLoader::itemReady, CollectionDB::getInstance(), &CollectionDB::addTrack);
    connect(fileLoader, &FMH::FileLoader::finished, fileLoader, [this, fileLoader](FMH::MODEL_LIST, QList<QUrl>)
    {
        m_scanning = false;
        emit scanningChanged(m_scanning);

        fileLoader->deleteLater();
    });

    fileLoader->requestPath(paths, true, QStringList() << FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::AUDIO] << "*.m4a");

    m_scanning = true;
    emit scanningChanged(m_scanning);
}

void vvave::rescan()
{
    scanDir(QUrl::fromStringList(sources()));
}

QStringList vvave::sources()
{
    return UTIL::loadSettings("SETTINGS", "SOURCES", QVariant::fromValue(BAE::defaultSources)).toStringList();
}

QVariantList vvave::sourcesModel()
{
    QVariantList res;
    const auto urls = sources();
    for (const auto &url : urls)
    {
        res << FMStatic::getFileInfo(url);
    }

    return res;
}

void vvave::openUrls(const QStringList &urls)
{
    if (urls.isEmpty())
        return;

    QVariantList data;

    for (const auto &url : urls) {
        auto _url = QUrl::fromUserInput(url);
        if (CollectionDB::getInstance()->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], _url.toString())) {
            const auto item = CollectionDB::getInstance()->getDBData(QStringList() << _url.toString());
            data << FMH::toMap(item.first());
        } else {
            data << FMH::toMap(trackInfo(_url));
        }
    }

    emit this->openFiles(data);
}

QList<QUrl> vvave::folders()
{
    const auto sources = CollectionDB::getInstance()->getDBData("select * from sources");
    return QUrl::fromStringList(FMH::modelToList(sources, FMH::MODEL_KEY::URL));
}

bool vvave::scanning() const
{
    return m_scanning;
}

