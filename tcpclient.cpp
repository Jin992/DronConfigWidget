#include "tcpclient.h"
#include <boost/bind.hpp>
#include <iostream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

#define CLIENT_ROLE 0
#define DRONE_ROLE 1
#define SERVER_ROLE 2

/***
 * TCPClient::TCPClient(std::string server_ip, std::string port)
 *  @brief - constructor init resolver and launch async resolve
 *  @param server_ip - server ip address string
 *  @param port - server port string
 */
TCPClient::TCPClient(std::string server_ip, std::string port)
: _io(), _resolver(_io), _socket(_io), _connection_status(false), _off_timer(_io), _ping_pong_timer(_io)
{
    QJsonObject pingJson;
    pingJson.insert("id", QJsonValue::fromVariant(CLIENT_ROLE));
    // define name field
    pingJson.insert("name", QJsonValue::fromVariant("ping"));
    QJsonDocument doc(pingJson);
    //Create query for resolver to resolve
    QString strJson(doc.toJson(QJsonDocument::Compact));
    // convet QString to std::string
    _json_ping = strJson.toStdString();
    tcp::resolver::query query(server_ip.c_str(), port.c_str());
    // Launch resolver asynchronously
    _resolver.async_resolve(query,
                           boost::bind(&TCPClient::_handle_resolve, this,
                                       boost::asio::placeholders::error,
                                       boost::asio::placeholders::iterator));

}

/***
 * void TCPClient::_handle_resolve(const boost::system::error_code &err, tcp::resolver::iterator endpoint_iterator)
 * @brief - attempt a connection to endpoint from the resolver list
 * @param err - boost error code object
 * @param endpoint_iterator - contain remote endpoint object
 */
void TCPClient::_handle_resolve(const boost::system::error_code &err,
                                tcp::resolver::iterator endpoint_iterator) {
    if (!err) {
        // Attempt a connection to the first endpoint in the list, Each endpoint
        // Will be tried until we successfully establish a connection
        tcp::endpoint endpoint = *endpoint_iterator;
        _socket.async_connect(endpoint,
                              boost::bind(&TCPClient::_handle_connect, this,
                                          boost::asio::placeholders::error, ++endpoint_iterator));
    } else{
        std::cout << "Error " << err.message() << std::endl;
    }
}

/***
 * void TCPClient::_handle_connect(const boost::system::error_code &err,tcp::resolver::iterator endpoint_iterator)
 * @brief - async connect callback. if async connect is successfully coonected set ui connection status to true
 *          and launch async read function, if err is try set all ui flags to false
 * @param err - boost error code object
 * @param endpoint_iterator - contain remote endpoint object
 */
void TCPClient::_handle_connect(const boost::system::error_code &err,
                                 tcp::resolver::iterator endpoint_iterator) {
    if (!err) {
        _connection_status.store(true);
        _is_con_func(true);
        _ui_msg_func("Connecting to server, please wait.");
        // launch async read
        std::string key("Radion");
        async_send(key);
        async_read();
    } else {
         _connection_status.store(false);
         _is_con_func(false);
         //_set_try_connect(false);
         _io.stop();
         _ui_msg_func(err.message());
    }
}

void TCPClient::async_read() {
    _socket.async_read_some(boost::asio::buffer(_in_buf), boost::bind(&TCPClient::_handle_read, this,
                                                                      boost::asio::placeholders::error,
                                                                      boost::asio::placeholders::bytes_transferred));
}

void TCPClient::async_send(std::string &msg) {
    _socket.async_send(boost::asio::buffer(msg),
                       [&](const boost::system::error_code &error, uint bytes_transferred) {
                            if (error) _error_action(error.message());});
}

void TCPClient::_handle_write(const boost::system::error_code &error, uint bytes_transferred) {
    if (!error)
        async_read();
    else
        _error_action(error.message());
}

void TCPClient::_telem_ac() {
    // Create QJsonObject
    QJsonObject responseJson;
    // define id field
    responseJson.insert("id", QJsonValue::fromVariant(CLIENT_ROLE));
    // define name field
    responseJson.insert("name", QJsonValue::fromVariant("telem"));
    // define data field
    responseJson.insert("data", QJsonValue::fromVariant("ok"));
    // convert QJsonObject to QHsonDocument
    QJsonDocument doc(responseJson);
    // convert QJsonDocument to QString
    QString strJson(doc.toJson(QJsonDocument::Compact));
    // convet QString to std::string
    std::string stdJson = strJson.toStdString();
    // send json ac
    //qDebug() << stdJson.c_str();
    boost::asio::async_write(_socket, boost::asio::buffer(stdJson.data(), stdJson.size()),[this](const boost::system::error_code &error, uint bytes_transferred){
                                                             _handle_telem_ac(error, bytes_transferred);});
}

void TCPClient::_handle_read(const boost::system::error_code &error, uint bytes_transferred) {
    if (!error) {
        std::string jstr(_in_buf.c_array(), bytes_transferred);

        //qDebug() << jstr.c_str();
        QJsonDocument data = QJsonDocument::fromJson(jstr.c_str());
        QJsonObject json = data.object();

        if (json.contains("name")) {
            std::string name = json["name"].toString().toStdString();
            if (name == "telem") {
                _ui_msg_func("Connected");
               json = json["data"].toObject();
               float bt = std::stof(json["bitrate"].toString().toStdString());
               int rssi = std::stoi(json["rssi"].toString().toStdString());
               //qDebug() << json["video"];
               bool video_status = json["video"].toBool();
               std::string net_type;
               switch ( json["netType"].toInt()) {
               case 0:
                   net_type = "No connection";
                   break;
               case 1:
                   net_type = "NO_SERVICE";
                   break;
               case 2:
                   net_type = "LIMITED_SERVICE_GSM";
                   break;
               case 3:
                   net_type = "EDGE";
                   break;
               case 4:
                   net_type = "UMTS";
                   break;
               case 5:
                   net_type = "HSPA+";
                   break;
               case 6:
                   net_type = "DC-HSPA+";
                   break;
               case 7:
                   net_type = "LTE";
                   break;
               case 8:
                   net_type = "NO_MODEM";
                   break;
               default:
                   net_type = "UNKNOWN";
                   break;
               }
               _telem_func(bt, rssi, net_type, video_status);
               _telem_ac();
            } else if (name == "cmd"){
                json = json["data"].toObject();
                if (json["system"].toString() == "video") {
                    if (json["data"].toString().toStdString() != "ok")
                        qDebug() << "Error";
                } else if (json["system"].toString() == "exec_res") {
                    qDebug() << "ACTION";
                    _cmdResFunc(json["action"].toString().toStdString());
                }
            } else if (name == "pong") {
                //currently not defined
            }
        } else {
            _error_action(error.message());
        }
    async_read();
    }
}

void TCPClient::_handle_telem_ac(const boost::system::error_code &error, uint bytes_transferred){
    if (error) {
        qDebug() << (char*) _response.data().data();
        qDebug() << "Error";
    }
}

void TCPClient::setTelemFunc(std::function<void(float, int, const std::string &, bool)> func) {
    _telem_func = func;
}

void TCPClient::setConnectionStatusFunc(std::function<void(const bool &connectionStatus)> func){
    _is_con_func = func;
}

void TCPClient::run() {
    startPingPong();
    _io.run();
}

void TCPClient::on_timer(const boost::system::error_code & err) {
    _off_timer.expires_from_now(boost::posix_time::seconds(1));
    _off_timer.async_wait([this](const boost::system::error_code &e) { _handle_timer(e);});
}

void TCPClient::_handle_timer(const boost::system::error_code &err){
    if (_off_timer.expires_at() <= boost::asio::deadline_timer::traits_type::now()) {
        _off_timer.cancel();
        if (!_get_con_status()) {
            _error_action("Disconnected");
            return;
        }
        _off_timer.expires_from_now(boost::posix_time::seconds(1));
        _off_timer.async_wait([this](const boost::system::error_code &e) {_handle_timer(e);});
    }
}

void TCPClient::startPingPong() {
    _ping_pong_timer.expires_from_now(boost::posix_time::seconds(1));
    _ping_pong_timer.async_wait([this](const boost::system::error_code &e) {_handle_ping_pong(e);});
}

void TCPClient::_handle_ping_pong(const boost::system::error_code &err){
    if (err) {
        _error_action(err.message());
    }
    if (_ping_pong_timer.expires_at() <= boost::asio::deadline_timer::traits_type::now()) {
        _ping_pong_timer.cancel();
        async_send(_json_ping);
       _ping_pong_timer.expires_from_now(boost::posix_time::seconds(1));
       _ping_pong_timer.async_wait([this](const boost::system::error_code &e) {_handle_ping_pong(e);});
    }
}

void TCPClient::getTryConnectStatusFunc(std::function<bool()> func) {
     _get_con_status = func;
}

void TCPClient::startConnectTimer() {
    on_timer(_timer_error);
}

void TCPClient::setTryConnectStatusFunc(std::function<void(const bool &tryConnect)> func) {
    _set_try_connect = func;
}

void TCPClient::setUiMsgFunc(std::function<void(const std::string &)> func) {
    _ui_msg_func = func;
}

void TCPClient::setCmdResSetFunc(std::function<void (const std::string &)> func){
    _cmdResFunc = func;
}

void TCPClient::_error_action(const std::string &msg){
    _is_con_func(false);
    //_set_try_connect(false);
    _io.stop();
    _ui_msg_func(msg);
}

