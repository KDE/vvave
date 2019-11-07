/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "pathlist.h"

PathList::PathList(QObject *parent) : MauiList(parent) {}

PathList::~PathList() {}

QVariantMap PathList::get(const int& index) const
{
	if(this->list.isEmpty() || index >= this->list.size() || index < 0)
	{
		return QVariantMap();
	}
	
	const auto model = this->list.at(index);	
	return FMH::toMap(model);
}

QString PathList::getPath() const
{
	return this->m_path;
}

FMH::MODEL_LIST PathList::items() const
{
	return this->list;
}

void PathList::popPaths(const QString &path)
{
	const int index = [m_path = this->m_path, path]() -> const int
	{
		int i = 0;
		for(const auto &c : m_path)
		{				
			if(i < path.length())			
			{	
				if(c != path[i])
					break;
				i++;
			}			
		}
		return i;
	}();
	
	if(index == 0)
	{
		emit this->preListChanged();
		this->list.clear();
		this->list << PathList::splitPath(path);
		emit this->postListChanged();
		return;
	}
	
	auto _url = QString(this->m_path).left(index);
	
	while(_url.endsWith("/"))
		_url.chop(1);
	
	removePaths(_url);
	this->m_path = _url;
	appendPaths(path);
}

void PathList::appendPaths(const QString &path)
{
	const auto _url = QString(path).replace(this->m_path, "");	
	for(auto &item : splitPath(_url))
	{
		emit this->preItemAppended();
		item[FMH::MODEL_KEY::PATH] = this->m_path + item[FMH::MODEL_KEY::PATH];
		this->list << item;
		emit this->postItemAppended();
	}	
}

void PathList::removePaths(const QString &path)
{
	auto _url = QString(this->m_path).replace(path, "");	
	
	while(_url.endsWith("/"))
		_url.chop(1);
	
	while(_url.startsWith("/"))
		_url.remove(0,1);
	
	_url.insert(0, "/");
	const auto count = _url.count("/");
	
	if(count < this->list.size())
	{
		for(auto i = 0; i < count; i++)
		{
			emit this->preItemRemoved(this->list.size()-1);
			this->list.removeAt(this->list.size()-1);
			emit this->postItemRemoved();
		}	
	}
}

void PathList::setPath(const QString& path)
{	
	auto _url = path;
	
	while(_url.endsWith("/"))
		_url.chop(1);
	
	while(_url.startsWith("/"))
		_url.remove(0,1);
	
	if(_url == this->m_path)
		return;	
	
	if(!this->list.isEmpty() && _url.startsWith(this->m_path))
	{
		appendPaths(_url);
	}
	else if(!this->list.isEmpty() && this->m_path.startsWith(_url))
	{
		removePaths(_url);
	}	
	else 
	{
		popPaths(_url);
	}
	
	this->m_path = _url;	
	emit this->pathChanged();		
}

FMH::MODEL_LIST PathList::splitPath(const QString& path)
{
	FMH::MODEL_LIST res;
	
	QString _url = path;
	
	while(_url.endsWith("/"))
		_url.chop(1);
	
	_url += "/";
	
	const auto count = _url.count("/");
	
	for(auto i = 0; i< count; i++)
	{
		_url =  QString(_url).left(_url.lastIndexOf("/")) ;
		auto label = QString(_url).right(_url.length() - _url.lastIndexOf("/")-1);
		
		if(label.isEmpty())
			continue;
		
		if(label.contains(":") && i == count -1)
		{
			res << FMH::MODEL
			{
				{FMH::MODEL_KEY::LABEL, "/"},
				{FMH::MODEL_KEY::PATH, _url+"/"}
			};
			break;
		}
		
		res << FMH::MODEL 
		{
			{FMH::MODEL_KEY::LABEL, label},
			{FMH::MODEL_KEY::PATH, _url}
		};
	}
	std::reverse(res.begin(), res.end());
	
	
	return res;
}

