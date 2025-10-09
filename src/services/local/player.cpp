#include "player.h"

#include <MauiKit4/Accounts/mauiaccounts.h>

#include <QByteArrayView>

#include <QNetworkRequest>
#include <QThread>
#include <QTime>

#include "powermanagementinterface.h"

Player::Player(QObject *parent)
    : MediaPlayer(parent)
    , m_power(new PowerManagementInterface(this))

{
   setPreferredOutput("jack");
   
 
    connect(this, &MediaPlayer::stateChanged, [this]() {
        // this->m_power->setPreventSleep(true);
        // this->m_power->setPreventSleep(false);
        // Q_EMIT this->playingChanged();
    });
}

inline QNetworkRequest getOcsRequest(const QNetworkRequest &request)
{
    qDebug() << Q_FUNC_INFO;

    qDebug() << "FORMING THE REQUEST" << request.url();

    // Read raw headers out of the provided request
    QMap<QByteArray, QByteArray> rawHeaders;
    const auto headerList = request.rawHeaderList();

    for (const QByteArray &headerKey : headerList) {
        rawHeaders.insert(headerKey, request.rawHeader(headerKey));
    }

    const auto account = FMH::toModel(MauiAccounts::instance()->getCurrentAccount());
    //    const auto account = FMH::MODEL();

    const QString concatenated = QString("%1:%2").arg(account[FMH::MODEL_KEY::USER], account[FMH::MODEL_KEY::PASSWORD]);
    const QByteArray data = concatenated.toLocal8Bit().toBase64();
    const auto headerData = QByteArrayView("Basic ") + QByteArrayView(data);

    // Construct new QNetworkRequest with prepared header values
    QNetworkRequest newRequest(request);

    newRequest.setRawHeader(QString("Authorization").toLocal8Bit(), headerData);
    newRequest.setRawHeader(QByteArrayLiteral("OCS-APIREQUEST"), QByteArrayLiteral("true"));
    newRequest.setRawHeader(QByteArrayLiteral("Cache-Control"), QByteArrayLiteral("public"));
    newRequest.setRawHeader(QByteArrayLiteral("Content-Description"), QByteArrayLiteral("File Transfer"));

    newRequest.setHeader(QNetworkRequest::ContentTypeHeader, "audio/mpeg");
    newRequest.setAttribute(QNetworkRequest::CacheSaveControlAttribute, true);
    newRequest.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    qDebug() << "headers" << newRequest.rawHeaderList() << newRequest.url();

    return newRequest;
}


QString Player::transformTime(int value)
{
    QString tStr;
    if (value) {
        QTime time((value / 3600) % 60, (value / 60) % 60, value % 60, (value * 1000) % 1000);
        QString format = "mm:ss";
        if (value > 3600)
            format = "hh:mm:ss";
        tStr = time.toString(format);
    }

    return tStr.isEmpty() ? "00:00" : tStr;
}

bool Player::getPlaying() const {
    return state() == MediaPlayer::Playing;
}