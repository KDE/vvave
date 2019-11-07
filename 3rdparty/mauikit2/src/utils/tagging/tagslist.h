#ifndef TAGSLIST_JH
#define TAGSLIST_JH

#include <QObject>
#include "fmh.h"
#include "tag.h"

class Tagging;
class TagsList : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool abstract READ getAbstract WRITE setAbstract NOTIFY abstractChanged)
	Q_PROPERTY(bool strict READ getStrict WRITE setStrict NOTIFY strictChanged)
	Q_PROPERTY(QStringList urls READ getUrls WRITE setUrls NOTIFY urlsChanged)
	Q_PROPERTY(QString lot READ getLot WRITE setLot NOTIFY lotChanged)
	Q_PROPERTY(QString key READ getKey WRITE setKey NOTIFY keyChanged)
	
    Q_PROPERTY(TagsList::KEYS sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged())
	
 
public:   
    enum KEYS : uint_fast8_t
    {
        URL = TAG::URL,
        APP = TAG::APP,
        URI = TAG::URI,
        MAC = TAG::MAC,
        LAST_SYNC = TAG::LAST_SYNC,
        NAME = TAG::NAME,
        VERSION = TAG::VERSION,
        LOT = TAG::LOT,
        TAG = TAG::TAG,
        COLOR = TAG::COLOR,
        ADD_DATE = TAG::ADD_DATE,
        COMMENT = TAG::COMMENT,
        MIME = TAG::MIME,
        TITLE = TAG::TITLE,
        DEVICE = TAG::DEVICE,
		KEY = TAG::KEY
    }; Q_ENUM(KEYS)
	
    explicit TagsList(QObject *parent = nullptr);
	TAG::DB_LIST items() const;
	
    TagsList::KEYS getSortBy() const;
    void setSortBy(const TagsList::KEYS &key);
	
	bool getAbstract() const;
	void setAbstract(const bool &value);	
	
	bool getStrict() const;
	void setStrict(const bool &value);
	
	QStringList getUrls() const;
	void setUrls(const QStringList &value);
	
	QString getLot() const;
	void setLot(const QString &value);
	
	QString getKey() const;
	void setKey(const QString &value);
	

private:
    TAG::DB_LIST list;
	void setList();
	void sortList();
	Tagging *tag;
	
	TAG::DB_LIST toModel(const QVariantList &data);
   
	bool abstract = false;
	bool strict = true;
	QStringList urls = QStringList();
	QString lot;
	QString key;
    TagsList::KEYS sortBy = TagsList::KEYS::ADD_DATE;
	
protected:

signals:
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void updateModel(int index, QVector<int> roles);
    void preListChanged();
    void postListChanged();
	
	void abstractChanged();
	void strictChanged();
	void urlsChanged();
	void lotChanged();
	void keyChanged();
	void sortByChanged();

public slots:    
    QVariantMap get(const int &index) const;
	void append(const QString &tag);
	bool insert(const QString &tag);
	void insertToUrls(const QString &tag);
	void insertToAbstract(const QString &tag);
	void updateToUrls(const QStringList &tags);
	void updateToAbstract(const QStringList &tags);
	
	bool remove(const int &index);
	void removeFrom(const int &index, const QString &url);
	void removeFrom(const int &index, const QString &key, const QString &lot);
	
	void removeFromUrls(const int &index);
	void removeFromUrls(const QString &tag);
	void removeFromAbstract(const int &index);
	
	void erase(const int &index);
    void refresh();
	
	bool contains(const QString &tag);
	int indexOf(const QString &tag);
};

#endif // SYNCINGLIST_H
