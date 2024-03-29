#ifndef DRONECONFIG_H
#define DRONECONFIG_H

#include <QObject>
#include <QString>
#include <tcpclient.h>
#include <QtDebug>
#include <string>
#include <QStringList>

class DroneConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool     videoStatus      READ videoStatus      WRITE setVideoStatus       NOTIFY videoStatusChanged)
    Q_PROPERTY(bool     connectionStatus READ connectionStatus WRITE  setConnectionStatus NOTIFY connectionStatusChanged)
    Q_PROPERTY(float    videoBitrate     READ videoBitrate     WRITE _setVideoBitrate     NOTIFY videoBitrateChanged)
    Q_PROPERTY(int      networkRssi      READ networkRssi      WRITE _setNetworkRssi      NOTIFY networkRssiChanged)
    Q_PROPERTY(QString  networkType      READ networkType      WRITE _setNetworkType      NOTIFY networkTypeChanged)
    Q_PROPERTY(bool     tryConnect       READ tryConnect       WRITE setTryConnect        NOTIFY tryConnectChanged)
    Q_PROPERTY(QString  serverIp         READ serverIp         WRITE setServerIp          NOTIFY serverIpChanged)
    Q_PROPERTY(QString  serverPort       READ serverPort       WRITE setServerPort        NOTIFY serverPortChanged)
    Q_PROPERTY(QString  uiMsg            READ uiMsg            WRITE setUiMsg             NOTIFY uiMsgChanged)
    Q_PROPERTY(QString  cmdResult        READ cmdResult        WRITE setCmdResult         NOTIFY cmdResultChanged)
    Q_PROPERTY(bool     droneStatus      READ droneStatus      WRITE setDroneStatus       NOTIFY droneStatusChanged)
    Q_PROPERTY(bool     serverStatus     READ serverStatus     WRITE setServerStatus      NOTIFY serverStatusChanged)
    Q_PROPERTY(QStringList paramList     READ paramList        WRITE setParamList         NOTIFY paramListChanged)

public:
    explicit DroneConfig(QObject *parent = nullptr);

    // set functions
    void setVideoStatus(const bool &videoStatus);
    void setTryConnect(const bool &tryConnect);
    void setConnectionStatus(const bool &connectionStatus);
    void setServerIp(const QString &ip);
    void setServerPort(const QString &port);
    void setUiMsg(const QString &msg);
    void setSendToDroneFunc(std::function<void(std::string msg)> func);
    void setCmdResult(const QString &msg);
    void _setVideoBitrate(float bitrate);
    void setClientStopFunc(std::function<void(void)> func);
    void setServerStatus(const bool &status);
    void setDroneStatus(const bool & status);
    void setParamList(const QStringList &list);


    // get functions
    bool connectionStatus();
    bool videoStatus() const;
    float videoBitrate() const;
    bool tryConnect() const;
    int networkRssi() const;
    QString networkType() const;
    void assingTelemData(int rssi, const std::string networkType, bool videoStatus);
    QString serverIp() const;
    QString serverPort() const;
    QString uiMsg();
    QString cmdResult()const;
    bool netClient() const;
    bool droneStatus() const;
    bool serverStatus() const;
    QStringList &param_list(){return _param_list;}
    void setBaseFilePath(const char *path);
    QStringList paramList() const;

signals:
    void videoStatusChanged();
    void connectionStatusChanged();
    void videoBitrateChanged();
    void networkRssiChanged();
    void networkTypeChanged();
    void tryConnectChanged();
    void serverIpChanged();
    void serverPortChanged();
    void uiMsgChanged();
    void cmdResultChanged();
    void droneStatusChanged();
    void serverStatusChanged();
    void paramListChanged();


public slots:
    void sendToDrone(const QString &msg);
    bool writeHistory(const QString& file, const QString& data);
    QString readHistory(const QString& file);
    void stop_net_client();
    void invoke_ffmpeg();

private:
    // private set functions
    void _setNetworkRssi(int rssi);
    void _setNetworkType(const QString &networkType);

private:
    bool                                    _videoStatus;
    bool                                    _connectionStatus;
    float                                   _videoBitrate;
    int                                     _networkRssi;
    bool                                    _try_connect;
    QString                                 _networkType;
    QString                                 _serverIp;
    QString                                 _serverPort;
    QString                                 _ui_msg;
    std::function<void(std::string msg)>    _send_to_network;
    QString                                 _cmdResult;
    QString                                 _basePath;
    std::function<void (void)>              _stop_tcp;
    std::atomic<bool>                       _net_client;
    std::atomic<bool>                       _drone_status;
    std::atomic<bool>                       _server_status;
    QStringList                             _param_list;
};

#endif // DRONECONFIG_H
