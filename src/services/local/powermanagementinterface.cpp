/*
   SPDX-FileCopyrightText: 2019 (c) Matthieu Gallien <matthieu_gallien@yahoo.fr>

   SPDX-License-Identifier: LGPL-3.0-or-later
 */

#include "powermanagementinterface.h"

#include <KLocalizedString>

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
#define Qt5DBus_FOUND true
#else
#define Qt5DBus_FOUND false
#endif

#if Qt5DBus_FOUND
#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCall>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDBusUnixFileDescriptor>
#endif

#if defined Q_OS_WIN
#include <windows.h>
#include <winbase.h>
#endif

#include <QString>
#include <QDebug>
#include <QGuiApplication>

class PowerManagementInterfacePrivate
{
public:

    bool mPreventSleep = false;

    bool mInhibitedSleep = false;

    uint mInhibitSleepCookie = 0;

};

PowerManagementInterface::PowerManagementInterface(QObject *parent) : QObject(parent), d(std::make_unique<PowerManagementInterfacePrivate>())
{
#if Qt5DBus_FOUND
    auto sessionBus = QDBusConnection::sessionBus();

    sessionBus.connect(QStringLiteral("org.freedesktop.PowerManagement.Inhibit"),
                       QStringLiteral("/org/freedesktop/PowerManagement/Inhibit"),
                       QStringLiteral("org.freedesktop.PowerManagement.Inhibit"),
                       QStringLiteral("HasInhibitChanged"), this, SLOT(hostSleepInhibitChanged()));
#endif
}

PowerManagementInterface::~PowerManagementInterface() = default;

bool PowerManagementInterface::preventSleep() const
{
    return d->mPreventSleep;
}

bool PowerManagementInterface::sleepInhibited() const
{
    return d->mInhibitedSleep;
}

void PowerManagementInterface::setPreventSleep(bool value)
{
    if (d->mPreventSleep == value) {
        return;
    }

    if (value) {
        inhibitSleepPlasmaWorkspace();
        inhibitSleepGnomeWorkspace();
        d->mPreventSleep = true;
    } else {
        uninhibitSleepPlasmaWorkspace();
        uninhibitSleepGnomeWorkspace();
        d->mPreventSleep = false;
    }

    Q_EMIT preventSleepChanged();
}

void PowerManagementInterface::retryInhibitingSleep()
{
    if (d->mPreventSleep && !d->mInhibitedSleep) {
        inhibitSleepPlasmaWorkspace();
        inhibitSleepGnomeWorkspace();
    }
}

void PowerManagementInterface::hostSleepInhibitChanged()
{
}

void PowerManagementInterface::inhibitDBusCallFinishedPlasmaWorkspace(QDBusPendingCallWatcher *aWatcher)
{
#if Qt5DBus_FOUND
    QDBusPendingReply<uint> reply = *aWatcher;
    if (reply.isError()) {
    } else {
        d->mInhibitSleepCookie = reply.argumentAt<0>();
        d->mInhibitedSleep = true;

        Q_EMIT sleepInhibitedChanged();
    }
    aWatcher->deleteLater();
#endif
}

void PowerManagementInterface::uninhibitDBusCallFinishedPlasmaWorkspace(QDBusPendingCallWatcher *aWatcher)
{
#if Qt5DBus_FOUND
    QDBusPendingReply<> reply = *aWatcher;
    if (reply.isError()) {
        qDebug() << "PowerManagementInterface::uninhibitDBusCallFinished" << reply.error();
    } else {
        d->mInhibitedSleep = false;

        Q_EMIT sleepInhibitedChanged();
    }
    aWatcher->deleteLater();
#endif
}

void PowerManagementInterface::inhibitDBusCallFinishedGnomeWorkspace(QDBusPendingCallWatcher *aWatcher)
{
#if Qt5DBus_FOUND
    QDBusPendingReply<uint> reply = *aWatcher;
    if (reply.isError()) {
        qDebug() << "PowerManagementInterface::inhibitDBusCallFinishedGnomeWorkspace" << reply.error();
    } else {
        d->mInhibitSleepCookie = reply.argumentAt<0>();
        d->mInhibitedSleep = true;

        Q_EMIT sleepInhibitedChanged();
    }
    aWatcher->deleteLater();
#endif
}

void PowerManagementInterface::uninhibitDBusCallFinishedGnomeWorkspace(QDBusPendingCallWatcher *aWatcher)
{
#if Qt5DBus_FOUND
    QDBusPendingReply<> reply = *aWatcher;
    if (reply.isError()) {
        qDebug() << "PowerManagementInterface::uninhibitDBusCallFinished" << reply.error();
    } else {
        d->mInhibitedSleep = false;

        Q_EMIT sleepInhibitedChanged();
    }
    aWatcher->deleteLater();
#endif
}

void PowerManagementInterface::inhibitSleepPlasmaWorkspace()
{
#if Qt5DBus_FOUND
    auto sessionBus = QDBusConnection::sessionBus();

    auto inhibitCall = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.PowerManagement.Inhibit"),
                                                      QStringLiteral("/org/freedesktop/PowerManagement/Inhibit"),
                                                      QStringLiteral("org.freedesktop.PowerManagement.Inhibit"),
                                                      QStringLiteral("Inhibit"));

    inhibitCall.setArguments({{QGuiApplication::desktopFileName()}, {i18nc("explanation for sleep inhibit during play of music", "Playing music")}});

    auto asyncReply = sessionBus.asyncCall(inhibitCall);

    auto replyWatcher = new QDBusPendingCallWatcher(asyncReply, this);

    QObject::connect(replyWatcher, &QDBusPendingCallWatcher::finished,
                     this, &PowerManagementInterface::inhibitDBusCallFinishedPlasmaWorkspace);
#endif
}

void PowerManagementInterface::uninhibitSleepPlasmaWorkspace()
{
#if Qt5DBus_FOUND
    auto sessionBus = QDBusConnection::sessionBus();

    auto uninhibitCall = QDBusMessage::createMethodCall(QStringLiteral("org.freedesktop.PowerManagement.Inhibit"),
                                                      QStringLiteral("/org/freedesktop/PowerManagement/Inhibit"),
                                                      QStringLiteral("org.freedesktop.PowerManagement.Inhibit"),
                                                      QStringLiteral("UnInhibit"));

    uninhibitCall.setArguments({{d->mInhibitSleepCookie}});

    auto asyncReply = sessionBus.asyncCall(uninhibitCall);

    auto replyWatcher = new QDBusPendingCallWatcher(asyncReply, this);

    QObject::connect(replyWatcher, &QDBusPendingCallWatcher::finished,
                     this, &PowerManagementInterface::uninhibitDBusCallFinishedPlasmaWorkspace);
#endif
}

void PowerManagementInterface::inhibitSleepGnomeWorkspace()
{
#if Qt5DBus_FOUND
    auto sessionBus = QDBusConnection::sessionBus();

    auto inhibitCall = QDBusMessage::createMethodCall(QStringLiteral("org.gnome.SessionManager"),
                                                      QStringLiteral("/org/gnome/SessionManager"),
                                                      QStringLiteral("org.gnome.SessionManager"),
                                                      QStringLiteral("Inhibit"));

    // See: https://gitlab.gnome.org/GNOME/gnome-session/-/blob/master/gnome-session/org.gnome.SessionManager.xml
    // The last argument are flag settings to specify what should be inhibited:
    //    1  = Inhibit logging out
    //    2  = Inhibit user switching
    //    4  = Inhibit suspending the session or computer
    //    8  = Inhibit the session being marked as idle
    //    16 = Inhibit auto-mounting removable media for the session
    inhibitCall.setArguments({{QCoreApplication::applicationName()}, {uint(0)},
                              {i18nc("explanation for sleep inhibit during play of music", "Playing music")}, {uint(12)}});

    auto asyncReply = sessionBus.asyncCall(inhibitCall);

    auto replyWatcher = new QDBusPendingCallWatcher(asyncReply, this);

    QObject::connect(replyWatcher, &QDBusPendingCallWatcher::finished,
                     this, &PowerManagementInterface::inhibitDBusCallFinishedGnomeWorkspace);
#endif
}

void PowerManagementInterface::uninhibitSleepGnomeWorkspace()
{
#if Qt5DBus_FOUND
    auto sessionBus = QDBusConnection::sessionBus();

    auto uninhibitCall = QDBusMessage::createMethodCall(QStringLiteral("org.gnome.SessionManager"),
                                                        QStringLiteral("/org/gnome/SessionManager"),
                                                        QStringLiteral("org.gnome.SessionManager"),
                                                        QStringLiteral("UnInhibit"));

    uninhibitCall.setArguments({{d->mInhibitSleepCookie}});

    auto asyncReply = sessionBus.asyncCall(uninhibitCall);

    auto replyWatcher = new QDBusPendingCallWatcher(asyncReply, this);

    QObject::connect(replyWatcher, &QDBusPendingCallWatcher::finished,
                     this, &PowerManagementInterface::uninhibitDBusCallFinishedGnomeWorkspace);
#endif
}

void PowerManagementInterface::inhibitSleepWindowsWorkspace()
{
#if defined Q_OS_WIN
    SetThreadExecutionState(ES_CONTINUOUS | ES_SYSTEM_REQUIRED);
#endif
}

void PowerManagementInterface::uninhibitSleepWindowsWorkspace()
{
#if defined Q_OS_WIN
    SetThreadExecutionState(ES_CONTINUOUS);
#endif
}


#include "moc_powermanagementinterface.cpp"
