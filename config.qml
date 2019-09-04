import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 1.2
import backend.DroneConfig 1.0

Window {
    id: root
    width: 640
    height: 480

    flags: Qt.FramelessWindowHint |
           Qt.WindowMinimizeButtonHint |
           Qt.Window | Qt.WindowStaysOnTopHint

    property var curIp: "127.0.0.1:25095"

    function find(model, criteria) {
      for(var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return model.get(i)
      return null
    }

    Component.onCompleted: {
        var file = controlServer.readHistory("config.txt")
        var lines = file.split('\n')
       for (var i = 0; i < lines.length; i++) {
           var line = {
               textIn:lines[i]
           }
           if (find(listModelIp, function(item) { return item.textIn === lines[i] }) === null) {
               listModelIp.append(line)
           }
       }
    }

    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        anchors.bottomMargin: 33
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    Rectangle {
        id: droneConfig
        x: 14
        y: 23
        width: 614
        height: 445
        color: "#00000000"
        border.width: 2

        Rectangle {
            id: additionalSettings
            x: 407
            y: 29
            width: 188
            height: 375
            color: "#00000000"
            border.width: 2

            Rectangle {
                id: additionalSettingsLabelFrame
                x: 0
                y: -14
                width: 140
                height: 14
                color: "#000000"

                Text {
                    id: additionalSettingsLabel
                    x: 11
                    y: 0
                    color: "#ffffff"
                    text: qsTr("Additional Settings")
                    font.bold: true
                    font.pixelSize: 12
                }
            }
        }

        Rectangle {
            id: networkSettings
            x: 8
            y: 29
            width: 188
            height: 375
            color: "#00000000"
            border.width: 2

            Rectangle {
                id: networkSettingsLabelFrame
                x: 0
                y: -14
                width: 140
                height: 14
                color: "#000000"

                Text {
                    id: networkSettingsLabel
                    x: 9
                    y: 0
                    width: 93
                    height: 14
                    color: "#ffffff"
                    text: qsTr("Network Settings")
                    font.bold: true
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: serverIpFrame
                x: 9
                y: 17
                width: 168
                height: 24
                color: "#ffffff"
                radius: 0
                border.width: 2
                TextInput {
                    id: serverIpValue
                    x: 2
                    y: 5
                    width: 166
                    height: 19
                    text: curIp
                    font.pixelSize: 14
                    echoMode: TextInput.Normal
                    inputMask: ""
                    onFocusChanged:{
                        historyBoxIp.visible = !historyBoxIp.visible
                        print(historyBoxIp.visible)
                    }
                }

                Text {
                    id: serverIpLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("ipaddres:port")
                    font.pixelSize: 12
                }
            }


            Button {
                id: networkSettingsApply
                x: 53
                y: 341
                text: qsTr("Apply")
                property variant stringList
                onClicked: {
                    stringList = curIp.split(":")
                    print(stringList[0])
                    print(stringList[1])
                    var line = {
                        textIn:serverIpValue.text
                    }
                    if (find(listModelIp, function(item) { return item.textIn === serverIpValue.text }) === null) {
                        listModelIp.append(line)
                    }
                    controlServer.serverIp = stringList[0]
                    controlServer.serverPort = stringList[1]
                }
            }

            Rectangle {
                id: historyBoxIp
                visible: false
                x: 11
                y: 38
                width: 164
                height: listModelIp.count * 20 < 60 ?  listModelIp.count * 20 : 60
                color: "#ffffff"
                border.width: 1
                z: 1
                ListView {
                    id: listViewIp
                    x: 0
                    y: 0
                    width: 164
                    height: 60
                    scale: 1
                    keyNavigationWraps: true
                    cacheBuffer: 200
                    contentHeight: 150
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 200
                    maximumFlickVelocity: 400
                    z: 0
                    clip:true
                    model: ListModel {
                        id: listModelIp
                    }
                    delegate: Item {
                        width: parent.width
                        height: 20

                        Text {
                           text: textIn
                           font.pointSize: 10
                           anchors.verticalCenter: parent.verticalCenter
                           font.bold: false
                        }
                        MouseArea {
                           anchors.fill: parent
                           z: 1
                           onClicked:{
                              curIp = textIn
                           }
                        }
                    }
                }
            }
        }



        Rectangle {
            id: videoSettigns
            x: 208
            y: 29
            width: 188
            height: 375
            color: "#00000000"
            border.width: 2

            Rectangle {
                id: incBitrate
                x: 8
                y: 18
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                TextInput {
                    id: incBitrateInput
                    x: 0
                    y: 1
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    inputMask: ""
                    echoMode: TextInput.NoEcho
                    font.pixelSize: 12
                }

                Text {
                    id: incBitrateLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Bitrate increase rate:")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: videoHeight
                x: 8
                y: 284
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                Text {
                    id: videoHeightLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Video height")
                    font.pixelSize: 12
                }

                TextInput {
                    id: videoHeightInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: videoReconnectionTimeout
                x: 8
                y: 256
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                TextInput {
                    id: videoReconnectionTimeoutInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }

                Text {
                    id: videoReconnectionTimeoutLabel
                    x: 0
                    y: -14
                    width: 157
                    height: 14
                    text: qsTr("Video reconnection timeout:")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: minimalLatencyUpgTime
                x: 8
                y: 226
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                Text {
                    id: minimalLatencyUpgLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Minimal latency upgrade times:")
                    font.pixelSize: 12
                }

                TextInput {
                    id: minimalLatencyUpgInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: minimalLatencyTS
                x: 8
                y: 196
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                TextInput {
                    id: minimalLatencyTSInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }

                Text {
                    id: minimalLatencyTSLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Minimal latency time slot:")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: avLatencyUpgTime
                x: 8
                y: 166
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                Text {
                    id: avLatencyUpgTimeLabel
                    x: 0
                    y: -14
                    width: 166
                    height: 14
                    text: qsTr("Avarage latency upgrade times:")
                    font.pixelSize: 12
                }

                TextInput {
                    id: avLatencyUpgTimeInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: avLatencyTS
                x: 8
                y: 137
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                Text {
                    id: avLatencyTSLabel
                    x: 0
                    y: -14
                    width: 142
                    height: 14
                    text: qsTr("Avarage latency time slot:")
                    font.pixelSize: 12
                }

                TextInput {
                    id: avLatencyTSInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: latencyThreshold
                x: 8
                y: 106
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                Text {
                    id: latencyThresholdLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Latency threshold:")
                    font.pixelSize: 12
                }

                TextInput {
                    id: latencyThresholdInput
                    x: 0
                    y: 0
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: periodBitrate
                x: 8
                y: 77
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                Text {
                    id: periodBitrateLabel
                    x: 0
                    y: -14
                    width: 127
                    height: 14
                    text: qsTr("Bitrate inc/dec period:")
                    font.pixelSize: 12
                }

                TextInput {
                    id: periodBitrateInput
                    x: 0
                    y: 1
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: decBitrate
                x: 8
                y: 47
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2

                TextInput {
                    id: decBitrateInput
                    x: 0
                    y: 1
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }

                Text {
                    id: decBitrateLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Bitrate decrease rate:")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: videoWidth
                x: 8
                y: 313
                width: 168
                height: 15
                color: "#ffffff"
                radius: 0
                border.width: 2
                TextInput {
                    id: videoWidthInput
                    x: 0
                    y: 1
                    width: 157
                    height: 14
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                    echoMode: TextInput.NoEcho
                    inputMask: ""
                }

                Text {
                    id: videoWidthLabel
                    x: 0
                    y: -14
                    width: 110
                    height: 14
                    text: qsTr("Video width")
                    font.pixelSize: 12
                }
            }

            Rectangle {
                id: videoSettingsLabelFrame
                x: 0
                y: -14
                width: 140
                height: 14
                color: "#000000"

                Text {
                    id: videoSettingsLabel
                    x: 8
                    y: 0
                    width: 101
                    height: 14
                    color: "#ffffff"
                    text: qsTr("Video Settings")
                    font.bold: true
                    font.pixelSize: 12
                }
            }

            Button {
                id: getParamBtn
                x: 13
                y: 341
                width: 89
                height: 26
                text: qsTr("Get Params")
            }

            Button {
                id: applyParamBtn
                x: 115
                y: 341
                width: 61
                height: 26
                text: qsTr("Apply")
            }
        }

        Rectangle {
            id: droneConfigLabelFrame
            x: 0
            y: -14
            width: 154
            height: 14
            color: "#000000"

            Text {
                id: dronConfigLabel
                x: 9
                y: 0
                width: 122
                height: 14
                color: "#ffffff"
                text: qsTr("Drone Configuration")
                font.bold: true
                font.pixelSize: 12
            }
        }

        Button {
            id: closeBtn
            x: 512
            y: 414
            text: qsTr("Close")
            onClicked: { var strToWrite = ""
                for(var i = 0; i < listModelIp.count; ++i) {
                    strToWrite += listModelIp.get(i).textIn + "\n"
                }
                if (!controlServer.writeHistory("config.txt", strToWrite.toString())) {
                    controlServer.uiMsg = "Write error"
                }
                root.close()
            }
        }





    }

    Connections {
        target: networkSettingsApply
        onClicked: print(serverIpValue.text.toString())
    }
    //    Rectangle {
    //        id: rectangle
    //        x: 0
    //        y: 0
    //        width: 640
    //        height: 480
    //        color: "#b3404040"
    //        radius: 3
    //        border.color: "#184ea3"
    //        border.width: 2
    //    }

}
