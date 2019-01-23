#ifndef YOUTUBEDL_H
#define YOUTUBEDL_H
#include <QObject>
#include <QWidget>
#include <QProcess>
#include <QByteArray>
#include <QMovie>
#include <QDebug>
#include <QDirIterator>

#include "../../utils/bae.h"
#include "../local/taginfo.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
class Notify;
#endif
class youtubedl : public QObject
{
    Q_OBJECT

public:
    explicit youtubedl(QObject *parent = nullptr);
    ~youtubedl();
    void fetch(const QString &json);
    QStringList ids;

private slots:
    void processFinished();
    void processFinished_totally(const int &state, const FMH::MODEL &info, const QProcess::ExitStatus &exitStatus);

private:
    const QString ydl="youtube-dl -f m4a --youtube-skip-dash-manifest -o \"$$$.%(ext)s\"";
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    Notify *nof;
#endif

signals:
    void done();
};

#endif // YOUTUBEDL_H
