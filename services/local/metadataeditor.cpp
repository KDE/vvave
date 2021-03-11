#include "metadataeditor.h"

MetadataEditor::MetadataEditor(QObject *parent) : QObject(parent)
  , m_tag(new TagInfo(this))
{
    connect(this, &MetadataEditor::urlChanged, this, &MetadataEditor::getData);
}

QUrl MetadataEditor::url() const
{
    return this->m_url;
}

QString MetadataEditor::title() const
{
    return this->m_title;
}

QString MetadataEditor::artist() const
{
    return this->m_artist;
}

QString MetadataEditor::album() const
{
    return this->m_album;
}

QString MetadataEditor::genre() const
{
    return this->m_genre;
}

int MetadataEditor::track() const
{
    return this->m_track;
}

QString MetadataEditor::comment() const
{
    return m_comment;
}

int MetadataEditor::year() const
{
    return m_year;
}

void MetadataEditor::setUrl(QUrl url)
{
    if (m_url == url)
        return;

    m_url = url;
    emit urlChanged(m_url);
}

void MetadataEditor::setTitle(QString title)
{
    if (m_title == title)
        return;

    m_title = title;
    m_tag->setTitle(m_title);
    emit titleChanged(m_title);
}

void MetadataEditor::setArtist(QString artist)
{
    if (m_artist == artist)
        return;

    m_artist = artist;
    m_tag->setArtist(m_artist);
    emit artistChanged(m_artist);
}

void MetadataEditor::setAlbum(QString album)
{
    if (m_album == album)
        return;

    m_album = album;
    m_tag->setAlbum(m_album);
    emit albumChanged(m_album);
}

void MetadataEditor::setTrack(int track)
{
    if (m_track == track)
        return;

    m_track = track;
    m_tag->setTrack(m_track);
    emit trackChanged(m_track);
}

void MetadataEditor::setGenre(QString genre)
{
    if (m_genre == genre)
        return;

    m_genre = genre;
    m_tag->setGenre(m_genre);
    emit genreChanged(m_genre);
}

void MetadataEditor::setComment(QString comment)
{
    if (m_comment == comment)
        return;

    m_comment = comment;
    m_tag->setComment(m_comment);
    emit commentChanged(m_comment);
}

void MetadataEditor::setYear(int year)
{
    if (m_year == year)
        return;

    m_year = year;
    m_tag->setYear(m_year);
    emit yearChanged(m_year);
}

void MetadataEditor::getData()
{
    m_tag->setFile(this->m_url.toLocalFile());

    m_title = m_tag->getTitle();
    emit this->titleChanged(m_title);

    m_artist = m_tag->getArtist();
    emit this->artistChanged(m_artist);

    m_album = m_tag->getAlbum();
    emit this->albumChanged(m_album);

    m_genre = m_tag->getGenre();
    emit this->genreChanged(m_genre);

    m_track = m_tag->getTrack();
    emit this->trackChanged(m_track);

    m_year = m_tag->getYear();
    emit this->yearChanged(m_year);

    m_comment = m_tag->getComment();
    emit this->commentChanged(m_comment);
}
