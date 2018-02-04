#include "notificationclient.h"

#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#endif

NotificationClient::NotificationClient(QObject *parent)
    : QObject(parent)
{
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateAndroidNotification()));
}

void NotificationClient::setNotification(const QString &notification)
{
    if (m_notification == notification)
        return;

    m_notification = notification;
    emit notificationChanged();
}

QString NotificationClient::notification() const
{
    return m_notification;
}

void NotificationClient::updateAndroidNotification()
{
#ifdef Q_OS_ANDROID

    QAndroidJniObject javaNotification = QAndroidJniObject::fromString(m_notification);
    QAndroidJniObject::callStaticMethod<void>("org/qtproject/babe/NotificationClient",
                                              "notify",
                                              "(Ljava/lang/String;)V",
                                              javaNotification.object<jstring>());
#endif

}
