# Default rules for deployment.

isEmpty(PREFIX){
    PREFIX = /usr
}

qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = $${PREFIX}/bin/
!isEmpty(target.path): INSTALLS += target

desktop_files.path = $${PREFIX}/share/applications/
desktop_files.files = $$PWD/*.desktop

meta_files.path = $${PREFIX}/share/metainfo/
meta_files.files = $$PWD/*appdata.xml

#services.path = $${PREFIX}/share/dbus-1/services
#services.files = $$PWD/data/*.service

#dman.path = $${PREFIX}/share/dman/
#dman.files = $$PWD/dman/*

#translations.path = $${PREFIX}/share/$${TARGET}/translations
#translations.files = $$PWD/translations/*.qm

hicolor.path =  $${PREFIX}/share/icons/hicolor/scalable/apps
hicolor.files = $$PWD/assets/vvave.svg

INSTALLS += target desktop_files meta_files hicolor

#GitVersion = $$system(git rev-parse HEAD)
#DEFINES += GIT_VERSION=\\\"$$GitVersion\\\"

