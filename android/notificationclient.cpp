#include "notificationclient.h"


#if defined(Q_OS_ANDROID)
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QException>

class InterfaceConnFailedException : public QException
{
public:
    void raise() const { throw *this; }
    InterfaceConnFailedException *clone() const { return new InterfaceConnFailedException(*this); }
};
#elif defined(Q_OS_WINDOWS)
#elif defined(Q_OS_DARWIN)
#else
#endif


NotificationClient::NotificationClient(QObject *parent)
    : QObject(parent)
{
    connect(this, SIGNAL(notificationChanged()), this, SLOT(updateAndroidNotification()));
}

void NotificationClient::notify(const QString &notification)
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

#if defined(Q_OS_ANDROID)
    QAndroidJniObject javaNotification = QAndroidJniObject::fromString(m_notification);
       QAndroidJniObject::callStaticMethod<void>("org/qtproject/example/notification/NotificationClient",
                                          "notify",
                                          "(Ljava/lang/String;)V",
                                          javaNotification.object<jstring>());
#endif

}
