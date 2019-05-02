#include "lyricwikiaService.h"

lyricWikia::lyricWikia(const FMH::MODEL &song)
{
    this->availableInfo.insert(ONTOLOGY::TRACK, {INFO::LYRICS});
    this->track = song;

    connect(this, &lyricWikia::arrayReady, [this](QByteArray data)
    {

        qDebug()<< "GOT THE ARRAY";
        this->array = data;
        this->parseArray();
    });
}

lyricWikia::~lyricWikia()
{

}

bool lyricWikia::setUpService(const PULPO::ONTOLOGY &ontology, const PULPO::INFO &info)
{
    this->ontology = ontology;
    this->info = info;

    if(!this->availableInfo[this->ontology].contains(this->info))
        return false;

    auto url = this->API;

    switch(this->ontology)
    {
        case PULPO::ONTOLOGY::TRACK:
        {
            QUrl encodedArtist(this->track[FMH::MODEL_KEY::ARTIST]);
            encodedArtist.toEncoded(QUrl::FullyEncoded);

            QUrl encodedTrack(this->track[FMH::MODEL_KEY::TITLE]);
            encodedTrack.toEncoded(QUrl::FullyEncoded);

            url.append("&artist=" + encodedArtist.toString());
            url.append("&song=" + encodedTrack.toString());
            url.append("&fmt=xml");

            break;
        }

        default: return false;
    }

    qDebug()<< "[lyricwikia service]: "<< url;

    this->startConnectionAsync(url);

    return true;
}

bool lyricWikia::parseTrack()
{
    QString xmlData(this->array);

    QDomDocument doc;

    if (!doc.setContent(xmlData)) return false;

    QString temp = doc.documentElement().namedItem("url").toElement().text().toLatin1();
    QUrl temp_u (temp);
    temp_u.toEncoded(QUrl::FullyEncoded);

    temp = temp_u.toString();

    temp.replace("http://lyrics.fandom.com/","http://lyrics.fandom.com/index.php?title=");
    temp.append("&action=edit");
    QRegExp url_regexp("<url>(.*)</url>");
    url_regexp.setMinimal(true);
    QUrl url = QUrl::fromEncoded(temp.toLatin1());
    QString referer = url_regexp.cap(1);

    auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [=] (QByteArray data)
    {
        qDebug() << "Receiving lyrics" << data;

        if(data.isEmpty())
            return;

        this->extractLyrics(data);

        downloader->deleteLater();
    });
    downloader->getArray(QUrl(url).toEncoded(), {{"Referer", referer.toLatin1()}});

    return true;
}

bool lyricWikia::extractLyrics(const QByteArray &array)
{
    QString content = QString::fromUtf8(array.constData());
    content.replace("&lt;", "<");
    QRegExp lyrics_regexp("<lyrics>(.*)</lyrics>");
    lyrics_regexp.indexIn(content);
    QString lyrics = lyrics_regexp.cap(1);

    if(lyrics.isEmpty()) return false;

    lyrics = lyrics.trimmed();
    lyrics.replace("\n", "<br>");

    QString text;

    if(!lyrics.contains("PUT LYRICS HERE")&&!lyrics.isEmpty())
    {
        text = "<h2 align='center' >" + this->track[FMH::MODEL_KEY::TITLE] + "</h2>";
        text += lyrics;

        text= "<div align='center'>"+text+"</div>";
    }

    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::TRACK, INFO::LYRICS,CONTEXT::LYRIC,text));
    return true;
}
