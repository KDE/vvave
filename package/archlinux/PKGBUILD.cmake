# Maintainer: kaiman <kaisfm at sohu dot com>
 
pkgname=vvave
pkgver=git
pkgrel=0
pkgdesc='Tiny Qt Music Player to keep your favorite songs at hand'
arch=(x86_64)
url='https://vvave.kde.org/'
license=(GPL3)
depends=(ki18n knotifications qt5-webengine qt5-websockets taglib)
makedepends=(extra-cmake-modules git python)
optdepends=('youtube-dl: youtube support')
provides=("${pkgname%-*}")
conflicts=("${pkgname%-*}" 'babe-qt')
replaces=('babe-qt')
source=('git://anongit.kde.org/vvave.git')
sha256sums=('SKIP')

#pkgver() {
#  cd $pkgname
#  git describe --long --tags | sed -r 's/([^-]*-g)/r\1/;s/-/./g;s/v//g'
#}

prepare() {
  rm -rf $pkgname
  git clone --recurse-submodules $source
  mkdir -p build
}

build() {
  cd build
  cmake ../$pkgname -DCMAKE_INSTALL_PREFIX=/usr
  make
}
 
package() {
  cd build
  make DESTDIR="$pkgdir" install
}
