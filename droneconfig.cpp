#include "droneconfig.h"
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QProcess>

DroneConfig::DroneConfig(QObject *parent)
: QObject(parent), _videoStatus(false), _connectionStatus(false),
  _videoBitrate(0.0), _networkRssi(-128), _networkType("NO_CON"),
  _try_connect(false), _serverIp("127.0.0.1"), _serverPort("25095"), _net_client(true), _drone_status(false), _server_status(false)
{
    setVideoStatus(true);
}

bool DroneConfig::connectionStatus(){
    return _connectionStatus;
}

void DroneConfig::setConnectionStatus(const bool &connectionStatus) {
    if (connectionStatus == _connectionStatus)
        return;
    _connectionStatus = connectionStatus;
    emit connectionStatusChanged();
}

bool DroneConfig::videoStatus() const {
    return _videoStatus;
}

void DroneConfig::setVideoStatus(const bool &videoStatus) {
    if (videoStatus == _videoStatus)
        return;
    _videoStatus = videoStatus;
    emit videoStatusChanged();
}

float DroneConfig::videoBitrate() const {
    return _videoBitrate;
}

void DroneConfig::_setVideoBitrate(float bitrate) {
    if (bitrate == _videoBitrate)
        return;
    _videoBitrate = bitrate;
    emit videoBitrateChanged();
}

int DroneConfig::networkRssi() const {
    return _networkRssi;
}

void DroneConfig::_setNetworkRssi(int rssi) {
    if (rssi == _networkRssi)
        return;
    _networkRssi = rssi;
    emit networkRssiChanged();
}

void DroneConfig::setCmdResult(const QString &msg){
    if (msg == _cmdResult)
        return;
    _cmdResult = msg;
    emit cmdResultChanged();
}

QString DroneConfig::cmdResult()const{
    return _cmdResult;
}

QString DroneConfig::networkType() const {
    return _networkType;
}

void DroneConfig::_setNetworkType(const QString &networkType) {
    if (networkType == _networkType)
        return;
    _networkType = networkType;
    emit networkTypeChanged();
}

void DroneConfig::assingTelemData(int rssi, const std::string networkType, bool videoStatus){
    _setNetworkRssi(rssi);
    _setNetworkType(networkType.c_str());
    setVideoStatus(videoStatus);
}

bool DroneConfig::tryConnect() const {
    return _try_connect;
}

void DroneConfig::setTryConnect(const bool &tryConnect) {
    if (tryConnect == _try_connect)
        return;
    _try_connect = tryConnect;
    emit tryConnectChanged();
}

QString DroneConfig::serverIp() const {
    return _serverIp;
}

QString DroneConfig::serverPort() const {
    return _serverPort;
}

void DroneConfig::setServerIp(const QString &ip) {
    if (ip == _serverIp)
        return;
    _serverIp = ip;
}

void DroneConfig::setServerPort(const QString &port) {
    if (port == _serverPort)
        return;
    _serverPort = port;
}

void DroneConfig::setUiMsg(const QString &msg) {
    if (_ui_msg == msg)
        return;
    _ui_msg = msg;
    emit uiMsgChanged();
}

QString DroneConfig::uiMsg() {
    return _ui_msg;
}

void  DroneConfig::sendToDrone(const QString &cmd) {
    if (_connectionStatus == true)
        _send_to_network(cmd.toStdString());
    else
        setUiMsg("No connection to drone");
}

void DroneConfig::setSendToDroneFunc(std::function<void(std::string msg)> func) {
    _send_to_network = func;
}

bool DroneConfig::writeHistory(const QString& filename,const QString& data)
{
    QString path = _basePath + filename;
    if (path.isEmpty()) {
       return false;
    }

    QFile file(path );
    if (!file.open(QFile::WriteOnly | QFile::Truncate)){
        setUiMsg("Does not exits: " + path);
       return false;
    }

    QTextStream out(&file);
    out << data;
    file.close();
    return true;
}

QString DroneConfig::readHistory(const QString& fileName){
    QString path = _basePath + fileName;
    QString text;
    if(path.isEmpty()) {
            return "";
        }
        QFile file(path);
        if(!file.exists()) {
            setUiMsg("Does not exits: " + path);
            return "";
        }
        if(file.open(QIODevice::ReadOnly)) {
            QTextStream stream(&file);
            text = stream.readAll();
        }
        return text;
}

void DroneConfig::setBaseFilePath(const char *path) {
    std::string pathStr(path);
    std::string newPath(pathStr.begin(), pathStr.begin() + (pathStr.rfind("/") + 1));
    _basePath = std::string(newPath).c_str();
    qDebug() << "Base path  >>> " << _basePath;
}

void DroneConfig::setClientStopFunc(std::function<void(void)> func) {
    _stop_tcp = func;
}

void DroneConfig::stop_net_client(){
    _net_client.store(false);
    if (_try_connect == true && !_serverIp.isEmpty() && !_serverPort.isEmpty())
        _stop_tcp();
   std::this_thread::sleep_for (std::chrono::seconds(1));
}

bool DroneConfig::netClient() const {
    return _net_client;
}


void DroneConfig::setDroneStatus(const bool & status) {
    if (_drone_status == status)
        return;
    _drone_status.store(status);
    emit droneStatusChanged();
}

void DroneConfig::setServerStatus(const bool & status) {
    if (_server_status == status)
        return;
    _server_status.store(status);
    emit serverStatusChanged();
}

bool DroneConfig::droneStatus() const {
    return _drone_status;
}

bool DroneConfig::serverStatus() const {
    return _server_status;
}

void DroneConfig::invoke_ffmpeg() {
     QProcess process;
    process.startDetached(("ffplay tcp://" + _serverIp.toStdString() + ":" + std::to_string(25090)).c_str());
}

void DroneConfig::setParamList(const QStringList & list) {
    _param_list = list;
    emit paramListChanged();
}

QStringList DroneConfig::paramList() const {
    return _param_list;
}
