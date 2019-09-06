#ifndef TCPCLIENT_H
#define TCPCLIENT_H

#include <boost/asio.hpp>
#include <string>
#include <functional>
#include <atomic>
#include <boost/enable_shared_from_this.hpp>
#include <boost/array.hpp>

using boost::asio::ip::tcp;

class TCPClient : public boost::enable_shared_from_this<TCPClient>
{
public:
    TCPClient(std::string server_ip, std::string port);
    void async_send(std::string &msg);
    void setTelemFunc(std::function<void(int, const std::string &, bool)> func);
    void run();
    void async_read();
    void startConnectTimer();
    void on_timer(const boost::system::error_code&);
    void setConnectionStatusFunc(std::function<void(const bool &)> func);
    void setTryConnectStatusFunc(std::function<void(const bool &)> func);
    void getTryConnectStatusFunc(std::function<bool()> func);
    void setUiMsgFunc(std::function<void(const std::string &)> func);
    void setCmdResSetFunc(std::function<void (const std::string &)> func);
    void setBitrateSetFunc(std::function <void(float)> func);
    void startPingPong();

private:
    void _error_action(const std::string &msg);
    void _send_key();
    void _telem_ac();
    void _handle_ping_pong(const boost::system::error_code &err);
    void _handle_timer(const boost::system::error_code &err);
    void _handle_resolve(const boost::system::error_code &err,tcp::resolver::iterator endpoint_iterator);
    void _handle_connect(const boost::system::error_code &err,tcp::resolver::iterator endpoint_iterator);
    void _handle_write(const boost::system::error_code &error, uint bytes_transferred);
    void _handle_read(const boost::system::error_code &error, uint bytes_transferred);
    void _handle_telem_ac(const boost::system::error_code &error, uint bytes_transferred);

private:
    boost::asio::io_service                                     _io;
    boost::asio::ip::tcp::resolver                              _resolver;
    boost::asio::ip::tcp::socket                                _socket;
    boost::asio::streambuf                                      _request;
    boost::asio::streambuf                                      _response;
    boost::array<char, 2048>                                    _in_buf;
    boost::asio::deadline_timer                                 _off_timer;
    boost::asio::deadline_timer                                 _ping_pong_timer;
    std::function<void(int, const std::string, bool)>    _telem_func;
    std::function<void(const bool &connectionStatus)>           _is_con_func;
    std::function<void(const bool &tryConnect)>                 _set_try_connect;
    std::function<bool()>                                       _get_con_status;
    std::function<void(const std::string &)>                    _ui_msg_func;
    std::atomic<bool>                                           _connection_status;
    boost::system::error_code                                   _timer_error;
    std::function<void (const std::string &)>                   _cmdResFunc;
    std::string                                                 _json_ping;
    std::function <void(float)>                                 _set_bitrate;
};

#endif // TCPCLIENT_H
