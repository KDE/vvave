#ifndef LYRICWIKIASERVICE_H
#define LYRICWIKIASERVICE_H
#include <QObject>
#include "../pulpo.h"

class lyricWikia : public Pulpo
{
    Q_OBJECT

private:
    const QString API = "https://lyrics.fandom.com/api.php?action=lyrics";

    bool extractLyrics(const QByteArray &array);

public:
    explicit lyricWikia(const FMH::MODEL &song);
    ~lyricWikia();
    virtual bool setUpService(const ONTOLOGY &ontology, const INFO &info);

protected:
    virtual bool parseTrack();

};

#endif // LYRICWIKIASERVICE_H
