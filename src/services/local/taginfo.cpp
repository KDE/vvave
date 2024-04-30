/*
   Babe - tiny music player
   Copyright (C) 2017  Camilo Higuita
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

 */

#include "taginfo.h"
#include "../../utils/bae.h"

#include <taglib/fileref.h>
#include <taglib/tag.h>

using namespace BAE;

TagInfo::TagInfo(const QString &url, QObject *parent)
    : QObject(parent)
{
    this->setFile(url);
}

TagInfo::TagInfo(QObject *parent)
    : QObject(parent)
{}

TagInfo::~TagInfo()
{
    delete this->file;
}

bool TagInfo::isNull()
{
    return this->file->isNull();
}

QString TagInfo::getAlbum() const
{
    const auto value = QString::fromStdWString(file->tag()->album().toWString());
    return !value.isEmpty() ? value : SLANG[W::UNKNOWN];
}

QString TagInfo::getTitle() const
{
    const auto value = QString::fromStdWString(file->tag()->title().toWString());
    return !value.isEmpty() ? value : fileName();
}

QString TagInfo::getArtist() const
{
    const auto value = QString::fromStdWString(file->tag()->artist().toWString());
    return !value.isEmpty() ? value : SLANG[W::UNKNOWN];
}

int TagInfo::getTrack() const
{
    return static_cast<signed int>(file->tag()->track());
}

QString TagInfo::getGenre() const
{
    const auto value = QString::fromStdWString(file->tag()->genre().toWString());
    return !value.isEmpty() ? value : SLANG[W::UNKNOWN];
}

QString TagInfo::fileName() const
{
    return QFileInfo(path).fileName();
}

uint TagInfo::getYear() const
{
    return file->tag()->year();
}

void TagInfo::setFile(const QString &url)
{
    this->path = url;
    QFileInfo _file(this->path);

    if (_file.isReadable() && _file.exists()) {
        this->file = new TagLib::FileRef(TagLib::FileName(path.toUtf8()));
    } else
        this->file = new TagLib::FileRef();
}

int TagInfo::getDuration() const
{
    return file->audioProperties()->length();
}

QString TagInfo::getComment() const
{
    const auto value = QString::fromStdWString(file->tag()->comment().toWString());
    return !value.isEmpty() ? value : SLANG[W::UNKNOWN];
}

QByteArray TagInfo::getCover() const
{
    QByteArray array;
    return array;
}

void TagInfo::setCover(const QByteArray &array)
{
    Q_UNUSED(array);
}

void TagInfo::setComment(const QString &comment)
{
    this->file->tag()->setComment(comment.toStdString());
    this->file->save();
}

void TagInfo::setAlbum(const QString &album)
{
    this->file->tag()->setAlbum(album.toStdString());
    this->file->save();
}

void TagInfo::setTitle(const QString &title)
{
    this->file->tag()->setTitle(title.toStdString());
    this->file->save();
}

void TagInfo::setTrack(const int &track)
{
    this->file->tag()->setTrack(static_cast<unsigned int>(track));
    this->file->save();
}

void TagInfo::setYear(const int &year)
{
    this->file->tag()->setYear(static_cast<unsigned int>(year));
    this->file->save();
}

void TagInfo::setArtist(const QString &artist)
{
    this->file->tag()->setArtist(artist.toStdString());
    this->file->save();
}

void TagInfo::setGenre(const QString &genre)
{
    this->file->tag()->setGenre(genre.toStdString());
    this->file->save();
}
