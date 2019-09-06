#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <droneconfig.h>
#include <tcpclient.h>
#include <thread>
#include <QtDebug>
#include <unistd.h>

void network(DroneConfig &config) {
   //qDebug() << "network maganer before while";
    while (config.netClient()) {
        if (!config.serverIp().isEmpty() && !config.serverPort().isEmpty()) {
            if (config.tryConnect() == true) {
                //qDebug() << "cmd to connect";
                // Define network manager
                TCPClient client(config.serverIp().toStdString(), config.serverPort().toStdString());
                config.setSendToDroneFunc([&](std::string msg){client.async_send(msg);});
                config.setClientStopFunc([&](){client.stop();});
                // pass connection set function from UI to network manager object
                client.setConnectionStatusFunc([&](const bool &connectionStatus){config.setConnectionStatus(connectionStatus);});
                // pass telemetry set function from UI to network manager object
                client.setTelemFunc([&](int rssi, const std::string &net_type, bool videoStatus) { config.assingTelemData(rssi, net_type, videoStatus);});
                // pass tryConnection flag get function from UI to network manager object
                client.getTryConnectStatusFunc([&]()->bool{return config.tryConnect();});
                // pass tryConnection flag set function from UI to network manager object
                client.setTryConnectStatusFunc([&](const bool &tryConnect) { config.setTryConnect(tryConnect);});
                // pass uiMsg function to network manager object
                client.setUiMsgFunc([&](const std::string &msg){config.setUiMsg(msg.c_str());});
                client.setCmdResSetFunc([&](const std::string &res){config.setCmdResult(res.c_str());});
                // pass video bitrete setter
                client.setBitrateSetFunc([&](float bitrate){config._setVideoBitrate(bitrate);});
                // start connection timer to check tryConnection flag state
                client.startConnectTimer();
                // start connection manager event loop
                client.run();
            }
        }
        std::this_thread::sleep_for (std::chrono::seconds(1));
    }
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<DroneConfig>("backend.DroneConfig",1, 0, "DroneConfig");

    QQmlApplicationEngine engine;
    DroneConfig controlServer;
    controlServer.setBaseFilePath(argv[0]);
    std::thread networkManager(network, std::ref(controlServer));
    engine.rootContext()->setContextProperty("controlServer", &controlServer);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //QObject::connect(engine.rootContext(), SIGNAL(sendToDrone(QString)),
    //                                        &controlServer, SLOT(sendToDrone(QString)));
    if (engine.rootObjects().isEmpty())
        return -1;
    int32_t res = app.exec();
    if (networkManager.joinable()){
        networkManager.join();
    }
    return res;
}
