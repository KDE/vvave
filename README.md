# Building

### Build for Android
Use `qmake`:

```bash
# Clone the code
git clone https://invent.kde.org/kde/vvave.git
cd vvave
# Create build dir
mkdir build && cd build
# Build
qmake -o Makefile ../vvave.pro
make
```

### Build for Desktop
Use `cmake`:
```bash
# Clone the code
git clone https://invent.kde.org/kde/vvave.git
cd vvave
# Create build dir
mkdir build && cd build
# Build
cmake ..
make
sudo make install
```

### Dependencies

If you've built vvave on some distro, please contribute here!

#### Ubuntu

```
sudo apt install kirigami2-dev libkf5syntaxhighlighting-dev extra-cmake-modules libtag1-dev libkf5notifications-dev libqt5websockets5-dev qtdeclarative5-dev qtmultimedia5-dev qtwebengine5-dev qtbase5-dev
```

For other distros, the `buildInputs` part of the next section is a good clue for what
you need.

### Using a nix shell

If you use `nix` you don't have to get your environment dirty, here are all the
dependencies and environment variables you need to load:

```nix
with import <nixpkgs> {};

let qtx = qt5; in
stdenv.mkDerivation {
  name = "vvave";

  buildInputs = [
    appstream
    taglib
    gettext
  ] ++ (with libsForQt5; [
    ki18n
    kconfig
    knotifications
    kservice
    kio
    kirigami2
  ]) ++ (with qtx; [
    qtbase
    qtwebsockets
    qtquickcontrols
    qtquickcontrols2
    qtmultimedia
    qtwebengine
    qtgraphicaleffects
    qtdeclarative
  ]) ++ (with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ]);

  shellHook = with qtx; ''
    export QT_QPA_PLATFORM_PLUGIN_PATH="${qtbase}/${qtbase.qtPluginPrefix}/platforms"
    export QT_PLUGIN_PATH="$QT_PLUGIN_PATH:${qtbase.bin}/${qtbase.qtPluginPrefix}"
    export QML2_IMPORT_PATH="$QML2_IMPORT_PATH:${qtquickcontrols2.bin}/${qtbase.qtQmlPrefix}"
    export QML2_IMPORT_PATH="$QML2_IMPORT_PATH:${qtquickcontrols}/${qtbase.qtQmlPrefix}"
    export QML2_IMPORT_PATH="$QML2_IMPORT_PATH:${qtgraphicaleffects}/${qtbase.qtQmlPrefix}"
    export QML2_IMPORT_PATH="$QML2_IMPORT_PATH:${qtdeclarative.bin}/${qtbase.qtQmlPrefix}"
    export QML2_IMPORT_PATH="$QML2_IMPORT_PATH:${libsForQt5.kirigami2}/${qtbase.qtQmlPrefix}"
  '';
}
```

## Troubleshooting

### QML complains module X is not installed

Check that all of the following Qt Components are installed:

```
qtbase qtquickcontrols2 qtquickcontrols qtgraphicaleffects qtdeclarative kirigami2
```

Next check that module `X` can be found in `$QML2_IMPORT_PATH`.

### VVAVE is built and running but no sound comes out!

Check that you have all the correct gstreamer plugins installed:

```
gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav
```
