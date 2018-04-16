#ifndef ANDROID_H
#define ANDROID_H
#include <QAndroidActivityResultReceiver>
#include <QObject>
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>

class Android : public QObject, public QAndroidActivityResultReceiver
{
    Q_OBJECT
public:
    explicit Android(QObject *parent = nullptr);
    Q_INVOKABLE void fileChooser();
    virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);

private:
    QAndroidActivityResultReceiver *resultReceiver;

signals:
    void folderPicked(const QString &url);


public slots:
};

#endif // ANDROID_H
