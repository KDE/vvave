#include <QQmlApplicationEngine>
#include <QFontDatabase>
#include <QQmlContext>

#include <QIcon>
#include <QCommandLineParser>

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedContext>
#else
#include <KI18n/KLocalizedContext>
#include <KI18n/KLocalizedString>
#endif

#if defined Q_OS_ANDROID || defined Q_OS_IOS
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#ifdef Q_OS_ANDROID
#include "mauiandroid.h"
#endif

#ifdef Q_OS_MACOS
#include "mauimacos.h"
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "fmstatic.h"
#include "mauiapp.h"
#else
#include <MauiKit/fmstatic.h>
#include <MauiKit/mauiapp.h>
#include "vvave_version.h"
#endif

#include "vvave.h"

#include "utils/bae.h"
#include "services/local/player.h"

#include "models/tracks/tracksmodel.h"
#include "models/albums/albumsmodel.h"
#include "models/playlists/playlistsmodel.h"
#include "models/folders/foldersmodel.h"
#include "models/cloud/cloud.h"

#ifdef Q_OS_ANDROID
Q_DECL_EXPORT
#endif

#define VVAVE_URI "org.maui.vvave"

int main(int argc, char *argv[])
{
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_WIN32
	qputenv("QT_MULTIMEDIA_PREFERRED_PLUGINS", "w");
#endif

#if defined Q_OS_ANDROID | defined Q_OS_IOS
	QGuiApplication app(argc, argv);
#else
	QApplication app(argc, argv);
#endif

#ifdef Q_OS_ANDROID
	if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
		return -1;
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
	app.setWindowIcon(QIcon("qrc:/assets/vvave.png"));

    MauiApp::instance()->setHandleAccounts(true); //for now pix can not handle cloud accounts
    MauiApp::instance()->setIconName("qrc:/assets/vvave.png");

    KLocalizedString::setApplicationDomain("vvave");
    KAboutData about(QStringLiteral("vvave"), i18n("Vvave"), VVAVE_VERSION_STRING, i18n("Vvave lets you organize, browse and listen to your local and online music collection."),
                     KAboutLicense::LGPL_V3, i18n("© 2019-2020 Nitrux Development Team"));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/vvave");
    about.setBugAddress("https://invent.kde.org/maui/vvave/-/issues");
    about.setOrganizationDomain("org.maui.vvave");
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    const QStringList args = parser.positionalArguments();

	QFontDatabase::addApplicationFont(":/assets/materialdesignicons-webfont.ttf");

	QQmlApplicationEngine engine;
	const QUrl url(QStringLiteral("qrc:/main.qml"));
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
					 &app, [url, args](QObject *obj, const QUrl &objUrl)
	{
		if (!obj && url == objUrl)
			QCoreApplication::exit(-1);

        if(FMStatic::loadSettings("Settings", "ScanCollectionOnStartUp", true ).toBool())
        {
            vvave::instance()->scanDir(vvave::sources());
        }

		if(!args.isEmpty())
			 vvave::instance()->openUrls(args);

	}, Qt::QueuedConnection);

	engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

	qmlRegisterSingletonInstance<vvave>(VVAVE_URI, 1, 0, "Vvave", vvave::instance ());

	qmlRegisterType<TracksModel>(VVAVE_URI, 1, 0, "Tracks");
	qmlRegisterType<PlaylistsModel>(VVAVE_URI, 1, 0, "Playlists");
	qmlRegisterType<AlbumsModel>(VVAVE_URI, 1, 0, "Albums");
	qmlRegisterType<FoldersModel>(VVAVE_URI, 1, 0, "Folders");
	qmlRegisterType<Cloud>(VVAVE_URI, 1, 0, "Cloud");
	qmlRegisterType<Player>(VVAVE_URI, 1, 0, "Player");

#ifdef STATIC_KIRIGAMI
	KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
	MauiKit::getInstance().registerTypes();
#endif
	engine.load(url);

#ifdef Q_OS_MACOS
	//	MAUIMacOS::removeTitlebarFromWindow();
#endif

	return app.exec();
}
