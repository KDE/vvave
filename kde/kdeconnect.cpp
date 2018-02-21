#include "kdeconnect.h"
#include "../utils/babeconsole.h"
#include <QProcess>

KdeConnect::KdeConnect(QObject *parent) : QObject(parent)
{

}

QVariantList KdeConnect::getDevices()
{
    QVariantList devices;

    bDebug::Instance()->msg("Getting the kdeconnect devices avaliable");
    QProcess process;
    process.start("kdeconnect-cli -a");
    process.waitForFinished();
    // auto output = process->readAllStandardOutput();

    process.setReadChannel(QProcess::StandardOutput);

    while (process.canReadLine())
    {
        QString line = QString::fromLocal8Bit(process.readLine());
        if(line.contains("(paired and reachable)"))
        {
            QVariantMap _devices;
            QStringList items = line.split(" ");
            auto key = QString(items.at(2));
            auto name = QString(items.at(1)).replace(":","");

            bDebug::Instance()->msg("Founded devices: "+key+" : "+name);
            _devices.insert("key", key);
            _devices.insert("name", name);

            devices.append(_devices);
        }
    }

    return  devices;
}

bool KdeConnect::sendToDevice(const QString &device, const QString &id, const QString &url)
{
    QString deviceName = device;
    QString deviceKey = id;

    bDebug::Instance()->msg("Trying to send "+url + " to : "+ deviceName);

    auto process = new QProcess();
    connect(process, static_cast<void(QProcess::*)(int, QProcess::ExitStatus)>(&QProcess::finished),
            [=](int exitCode, QProcess::ExitStatus exitStatus)
    {
        bDebug::Instance()->msg("ProcessFinished_totally"+exitCode+exitStatus);
        //        BabeWindow::nof->notify("Song sent to " + deviceName,title +" by "+ artist);
//        process->deleteLater();
    });

    bDebug::Instance()->msg("kdeconnect-cli -d "  +deviceKey+ " --share " + url);
    process->start("kdeconnect-cli -d " +deviceKey+ " --share " +"\""+ url+"\"");

    return true;
}
