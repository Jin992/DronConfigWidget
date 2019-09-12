import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Imagine 2.3
import QtQuick.Controls.Universal 2.0
import backend.DroneConfig 1.0


Window {
    id: root
    visible: true
    width: 300
    height: 200
    color: "#00000000"

    property bool configWindow: false
    property bool networkConnect: false
    property bool bindWindow: false
    property var videoBtnLabel: "Video"

    property alias exitmsg: exitmsg
    title: qsTr("DroneControlTool")
    flags: Qt.FramelessWindowHint |
           Qt.WindowMinimizeButtonHint |
           Qt.Window | Qt.WindowStaysOnTopHint

    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        anchors.rightMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: (!bindWindow) ? root.x += (mouseX - lastMousePos.x) : root.x
        onMouseYChanged: (!bindWindow) ? root.y += (mouseY - lastMousePos.y) : root.y
    }

    //x: Screen.desktopAvailableWidth - width - 10
    //y: Screen.desktopAvailableHeight - height -10

    Rectangle {
        id: cntlOverlay
        x: 0
        y: 0
        width: 300
        height: 200
        radius: 12
        border.color: "#000000"
        color:"#b39a9797"
        border.width: 2

        Rectangle {
            id: videoSection
            x: 10
            y: 110
            width: 182
            height: 65
            color: "#00000000"
            radius: 0
            border.width: 2

            Text {
                id: videoSwitchLabel
                x: 6
                y: 36
                width: 54
                height: 15
                color: "#ffffff"
                text: qsTr("Video:")
                font.bold: true
                font.pixelSize: 16
            }

            Switch {
                id: videoSwitch
                checked: controlServer.videoStatus
                x: 81
                y: 29
                width: 74
                height: 34
                onClicked: {
                    //controlServer.videoStatus = !controlServer.videoStatus

                    controlServer.sendToDrone("{\"id\":0,\"name\":\"cmd\",\"data\":{\"system\":\"video\",\"action\":" + !controlServer.videoStatus  + "}}")
                    print(controlServer.videoStatus )
                }
            }

            Text {
                id: bitrateValue
                x: 83
                y: 8
                width: 87
                height: 15
                color: "#ffffff"
                text: controlServer.videoBitrate.toFixed(2) +  qsTr(" Mbit/s")
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                font.bold: true
            }

            Text {
                id: bitrateValueLabel
                x: 6
                y: 6
                width: 63
                height: 18
                color: "#ffffff"
                text: qsTr("Bitrate:")
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                font.pixelSize: 16
            }

            Rectangle {
                id: videoSectionTitle
                x: 0
                y: -12
                width: 96
                height: 13
                color: "#000000"

                Text {
                    id: videoSectionLab
                    x: 4
                    y: -1
                    color: "#ffffff"
                    text: qsTr("Video Section")
                    font.pixelSize: 12
                }
            }
        }

        Rectangle {
            id: modemSection
            x: 10
            y: 28
            width: 183
            height: 65
            color: "#00000000"
            radius: 0
            border.width: 2

            Text {
                id: netTitle
                x: 8
                y: 11
                width: 77
                height: 14
                color: "#ffffff"
                text: qsTr("Network:")
                font.bold: true
                font.pixelSize: 16
            }

            Text {
                id: rssiTitle
                x: 8
                y: 35
                width: 64
                height: 14
                color: "#ffffff"
                text: qsTr("RSSI:")
                font.bold: true
                font.pixelSize: 16
            }

            Text {
                id: rssiData
                x: 81
                y: 38
                width: 105
                height: 27
                color: "#ffffff"
                text:  controlServer.networkRssi.toString() + qsTr(" dBm")
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
            }

            Text {
                id: netData
                x: 104
                y: 14
                width: 60
                height: 16
                color: "#ffffff"
                text: controlServer.networkType
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
            }

            Rectangle {
                id: modemTitle
                x: 102
                y: 64
                width: 81
                height: 13
                color: "#000000"
                Text {
                    id: modemLab
                    x: 4
                    y: -2
                    width: 69
                    height: 14
                    color: "#ffffff"
                    text: qsTr("Modem")
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 12
                }
            }

        }

        Button {
            id: configBtn
            x: 198
            y: 124
            width: 94
            height: 24
            checkable: false
            highlighted: false
            flat: false
            Text{
                id: configButtonLabel
                x: 0
                y: 4
                width: 94
                height: 24
                text: qsTr("Config")
                font.pointSize: 11
                font.bold: true
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.Capitalize
            }
            background: Rectangle {
                color: "black"
                radius: 6
            }
            display: AbstractButton.TextOnly
            onClicked: {
                var component = Qt.createComponent("config.qml")
                var window    = component.createObject(this)
                window.show()
            }
        }

        Button {
            id: bindBtn
            x: 198
            y: 70
            width: 94
            height: 24
            background: Rectangle {
                color: "#000000"
                radius: 6
            }
            flat: false
            Text {
                x: 0
                y: 4
                width: 94
                height: 24
                color: "#ffffff"
                text: bindWindow ? qsTr("Unbind") :qsTr("Bind")
                font.pointSize: 11
                font.capitalization: Font.Capitalize
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            highlighted: false
            display: AbstractButton.TextOnly
            onClicked: {
                bindWindow = !bindWindow
                //root.change()
            }
        }

        Button {
            id: cm
            x: 198
            y: 151
            width: 94
            height: 24
            background: Rectangle {
                color: "#000000"
                radius: 6
            }
            flat: false
            Text {
                x: 0
                y: 4
                width: 94
                height: 24
                color: "#ffffff"
                text: controlServer.connectionStatus ? qsTr("Disconnect") : qsTr("Connect")
                font.pointSize: 11
                font.capitalization: Font.Capitalize
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            highlighted: false
            display: AbstractButton.TextOnly
            onClicked: {
                controlServer.tryConnect = !controlServer.connectionStatus
                //root.change()
            }
        }

        DelayButton {
            id: delayButton
            x: 198
            y: 15
            width: 94
            height: 24
            background: Rectangle {
                color: "#000000"
                radius: 6
            }
            Text {
                x: -2
                y: 4
                width: 94
                height: 24
                color: "#ffffff"
                text: qsTr("Exit")
                font.pointSize: 11
                font.capitalization: Font.Capitalize
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
            }
            onClicked: popup.open()
            //root.close()
        }

        Button {
            id: cmdBtn
            x: 198
            y: 97
            width: 94
            height: 24
            flat: false
            Text {
                id: cmdBtnLabel
                x: 0
                y: 4
                width: 94
                height: 24
                color: "#ffffff"
                text: qsTr("cmd")
                font.pointSize: 11
                font.capitalization: Font.Capitalize
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            highlighted: false
            display: AbstractButton.TextOnly
            background: Rectangle {
                color: "#000000"
                radius: 6
            }
            checkable: false
            onClicked: {
                var component1 = Qt.createComponent("cmdExecutor.qml")
                var window1    = component1.createObject(this)
                window1.show()
            }
        }

        Button {
            id: playVideoBtn
            x: 198
            y: 42
            width: 94
            height: 24
            Text {
                id: videoText
                x: 0
                y: 4
                width: 94
                height: 24
                color: "#ffffff"
                text: videoBtnLabel
                font.bold: true
                font.capitalization: Font.Capitalize
                font.pointSize: 11
                horizontalAlignment: Text.AlignHCenter
            }
            highlighted: false
            flat: false
            background: Rectangle {
                id: playVideoBtnBck
                color: "#000000"
                radius: 6
            }
            display: AbstractButton.TextOnly
            onClicked: {
                playVideoBtn.enabled = false
                playVideoBtnBck.color = "darkGray"
                print(playVideoBtn.enabled)
                videoBtnLabel = "wait"
                controlServer.invoke_ffmpeg()
                videoBtnTimer.start()
            }
            Timer {
                id:videoBtnTimer
                interval: 10000
                repeat: false
                running: false
                onTriggered: {
                    playVideoBtn.enabled = true
                    playVideoBtnBck.color = "#000000"
                    videoBtnLabel = "Video"
                    print("stop timer")
                }
            }
        }
    }

    Popup {
        id: popup
        x: root.width/2 - 110
        y: root.height/2 - 60
        width: 220
        height: 120
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        Text {
            id: exitmsg
            x: 10
            y: 20
            width: 174
            height: 18
            text: qsTr("Do you realy want to exit?")
            font.bold: false
            font.pixelSize: 15
        }

        Button {
            id: popupYesBtn
            width: 60
            height: 30
            x: 35
            y: 62
            text: qsTr("Yes")
            onClicked:{
                controlServer.stop_net_client()
                Qt.quit()}

        }

        Button {
            id: popupNoBtn
            width: 60
            height: 30
            x: 100
            y: 62
            text: qsTr("No")
            onClicked:{popup.close()}
        }
    }

    Rectangle {
        id: connectionMap
        x: 10
        y: 8
        width: 280
        height: 15
        color: "#00000000"

        Rectangle {
            id: serverFrame
            x: 50
            y: 0
            width: 43
            height: 15
            color: "#000000"

            Text {
                id: serverVal
                x: 3
                y: 0
                width: 46
                height: 15
                color: controlServer.serverStatus ? "#54f925" : "#ec2121"
                text: controlServer.serverStatus ? qsTr("Online") :qsTr("Offline")
                font.pixelSize: 12
            }

            Text {
                id: serverLabel
                x: -49
                y: -1
                text: qsTr("Server:")
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
            }
        }




        Rectangle {
            id: droneValFrame
            x: 136
            y: 0
            width: 43
            height: 15
            color: "#000000"

            Text {
                id: droneLabel
                x: -40
                y: 0
                width: 40
                height: 15
                text: qsTr("Drone:")
                font.pixelSize: 12
            }

            Text {
                id: droneVal
                x: 3
                y: 0
                width: 44
                height: 15
                color: controlServer.droneStatus ? "#54f925" : "#ec2121"
                text: controlServer.droneStatus ? qsTr("Online") :qsTr("Offline")
                font.pixelSize: 12
            }

        }




    }

    Rectangle {
        id: backendMsgBox
        x: 10
        y: 178
        width: 280
        height: 17
        color: "#00000000"
        border.color: "#00000000"

        Text {
            id: backendMsg
            width: 280
            height: 17
            text: controlServer.uiMsg
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 12
        }
    }

    Connections {
        target: cm
        onClicked: print(controlServer.connectionStatus)
    }








}

/*##^## Designer {
    D{i:30;invisible:true}D{i:31;invisible:true}D{i:29;invisible:true}D{i:32;invisible:true}
}
 ##^##*/
