# includes openssl libs onto android build

android {
  ANDROID_EXTRA_LIBS += $$PWD/3rdparty/openssl/lib/libcrypto.so
  ANDROID_EXTRA_LIBS += $$PWD/3rdparty/openssl/lib/libssl.so
}
