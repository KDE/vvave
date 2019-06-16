#include "vvave.h"

#include "db/collectionDB.h"

static CollectionDB *DB = CollectionDB::getInstance();

vvave::vvave(QObject *parent) : QObject(parent)
{

}
