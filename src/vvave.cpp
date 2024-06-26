#include "vvave.h"

#include "db/collectionDB.h"
#include "services/local/taginfo.h"

#include <MauiKit4/FileBrowsing/fileloader.h>
#include <MauiKit4/FileBrowsing/fm.h>

#include <QSettings>

#include "utils/bae.h"

Q_GLOBAL_STATIC(vvave, vvaveInstance)

FMH::MODEL vvave::trackInfo(const QUrl &url)
{
    TagInfo info(url.toLocalFile());
    if (info.isNull())
    {
        return FMH::MODEL();
    }

    const auto track = info.getTrack();
    const auto genre = info.getGenre();
    const auto album = info.getAlbum();
    const auto title = info.getTitle(); /* to fix*/
    const auto artist = info.getArtist();
    const auto sourceUrl = FMStatic::parentDir(url).toString();
    const auto duration = info.getDuration();
    const auto year = info.getYear();
    const auto comment = info.getComment();

    return FMH::MODEL {{FMH::MODEL_KEY::URL, url.toString()},
        {FMH::MODEL_KEY::TRACK, QString::number(track)},
        {FMH::MODEL_KEY::TITLE, title},
        {FMH::MODEL_KEY::ARTIST, artist},
        {FMH::MODEL_KEY::ALBUM, album},
        {FMH::MODEL_KEY::COMMENT, comment},
        {FMH::MODEL_KEY::DURATION, QString::number(duration)},
        {FMH::MODEL_KEY::GENRE, genre},
        {FMH::MODEL_KEY::SOURCE, sourceUrl},
        {FMH::MODEL_KEY::RELEASEDATE, QString::number(year)}};
}

QString vvave::artworkUrl(const QString &artist, const QString &album)
{
    FMH::MODEL data = {{FMH::MODEL_KEY::ARTIST, artist}, {FMH::MODEL_KEY::ALBUM, album}};
    if (BAE::artworkCache(data, FMH::MODEL_KEY::ALBUM))
    {
        return QUrl(data[FMH::MODEL_KEY::ARTWORK]).toLocalFile();
    }

    return QString();
}

QVariantList vvave::getTracks(const QString &query)
{
    // return QVariantList();
    return FMH::toMapList(CollectionDB::getInstance()->getDBData(query));
}

/*
 * Sets upthe app default config paths
 * BrainDeamon to get collection information
 * YoutubeFetcher ?
 *
 * */
vvave *vvave::instance()
{
    return vvaveInstance();
}

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
    Q_EMIT fetchArtworkChanged(m_fetchArtwork);
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
            Q_EMIT sourceAdded(path);
        }
    }

    if (newUrls.isEmpty())
        return;

    urls << newUrls;

    QSettings settings;
    settings.beginGroup("SETTINGS");
    settings.setValue("SOURCES", QVariant::fromValue(QUrl::toStringList(urls)));
    settings.endGroup();

    scanDir(urls);
    Q_EMIT sourcesChanged();
}

bool vvave::removeSource(const QString &source)
{
    auto urls = this->sources();
    if (!urls.contains(source))
        return false;

    urls.removeOne(source);

    QSettings settings;
    settings.beginGroup("SETTINGS");
    settings.setValue("SOURCES", QVariant::fromValue(urls));
    settings.endGroup();

    Q_EMIT sourcesChanged();

    if (CollectionDB::getInstance()->removeSource(source)) {
        Q_EMIT this->sourceRemoved(QUrl(source));
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
        Q_EMIT scanningChanged(m_scanning);

        fileLoader->deleteLater();
    });

    fileLoader->requestPath(paths, true, QStringList() << FMStatic::FILTER_LIST[FMStatic::FILTER_TYPE::AUDIO] << "*.m4a");

    m_scanning = true;
    Q_EMIT scanningChanged(m_scanning);
}

void vvave::rescan()
{
    scanDir(QUrl::fromStringList(sources()));
}

QStringList vvave::sources()
{
    QSettings settings;
    settings.beginGroup("SETTINGS");
    auto data = settings.value("SOURCES", QVariant::fromValue(BAE::defaultSources)).toStringList();
    settings.endGroup();
    return data;
}

QVariantList vvave::sourcesModel()
{
    QVariantList res;
    const auto urls = QUrl::fromStringList(sources());
    for (const auto &url : urls)
    {
        if(FMStatic::fileExists(url))
        {
            res << FMStatic::getFileInfo(url);
        }
    }

    return res;
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

