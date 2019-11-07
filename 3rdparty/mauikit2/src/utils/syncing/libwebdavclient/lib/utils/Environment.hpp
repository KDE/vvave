#ifndef UTILS_ENVIRONMENT_HPP
#define UTILS_ENVIRONMENT_HPP

#include <QString>

class Environment {
public:
  static QString get(QString key);
};

#endif
