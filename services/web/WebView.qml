import QtQuick 2.0
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Loader
{
    source: Maui.Handy.isLinux || Maui.Handy.isAndroid ? "qrc:/services/web/WebViewLinux.qml" : "qrc:/services/web/WebViewOther.qml"
}
