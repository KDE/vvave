#ifndef YOUTUBE_H
#define YOUTUBE_H
#include <QObject>
#include <QWidget>
#include <QMap>
#include <QUrl>
#include <QVariant>

class YouTube : public QObject
{
    Q_OBJECT

    enum class METHOD : uint8_t
    {
        SEARCH
    };

public:
    explicit YouTube(QObject *parent = nullptr);
    ~YouTube();
    Q_INVOKABLE bool getQuery(const QString &query, const int &limit = 5);
    bool packQueryResults(const QByteArray &array);
    void getId(const QString &results);
    void getUrl(const QString &id);

    Q_INVOKABLE QString getKey() const;
    QByteArray startConnection(const QString &url, const QMap<QString, QString> &headers = {});

    Q_INVOKABLE static QUrl fromUserInput(const QString &userInput);
private:
    const QString KEY = "AIzaSyDMLmTSEN7i6psE2tHdaG6hy3ljWKXIYBk";
    const QMap<METHOD, QString> API =
    {
        {METHOD::SEARCH, "https://www.googleapis.com/youtube/v3/search?"}
    };

signals:
    void queryResultsReady(QVariantList res);
};

#endif // YOUTUBE_H
