import QtQuick 2.0
import QtQuick.Window 2.2
import QtQuick.Controls 2.4
import backend.DroneConfig 1.0

Window {
    id: root
    width: 640
    height: 480
    color: "#c0c3c4"

    flags: Qt.FramelessWindowHint |
           Qt.WindowMinimizeButtonHint |
           Qt.Window | Qt.WindowStaysOnTopHint

    property var curIp: "127.0.0.1:25095"
    property var dparam: ""
    property var dvalue:  ""
    property var dparamDescript: []
    property var dparamName: []
    property var map: new Object()

    function getParamId(paramStr){
        var splited = paramStr.split(':')
        return splited[0]
    }
    function getParamValue(paramStr){
        var splited = paramStr.split(':')
        return splited[1]
    }

    function find(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return i
        return false
    }

    function mapValue(key) {
        return map[key]
    }

    function setMapValue(key, value) {
        map[key] = value
    }

    Component.onCompleted: {
        var file = controlServer.readHistory("config.txt")
        var lines = file.split('\n')
        for (var i = 0; i < lines.length; i++) {
            var line = {
                textIn:lines[i]
            }
            if (find(listModelIp, function(item) { return item.textIn === lines[i] }) === false) {
                listModelIp.append(line)
            }
        }
        if (listModelIp.count > 1)
            curIp = listModelIp.get(1).textIn
        var cred = serverIpValue.text.split(":")
        print(cred[0])
        print(cred[1])
        controlServer.serverIp = cred[0]
        controlServer.serverPort = cred[1]

        var fileDecription = controlServer.readHistory("paramDesc.txt")
        var descriptionLines = fileDecription.split('\n')

        for (var j = 0; j < descriptionLines.length; j++) {
            var tmp = descriptionLines[j].split(':')
            setMapValue(tmp[0],tmp[1])
            print(tmp[0])
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
                    property int listCnt: 0
                    Keys.onDownPressed: {
                        if (listCnt < listModelIp.count - 1) {
                            listCnt++
                            curIp = listModelIp.get(listCnt).textIn
                        }
                    }
                    Keys.onUpPressed: {
                        if (listCnt > 0) {
                            listCnt--;
                            curIp = listModelIp.get(listCnt).textIn
                        }
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
                x: 52
                y: 344
                width: 85
                height: 24
                text: qsTr("Apply")
                property variant stringList
                onClicked: {
                    stringList = serverIpValue.text.split(":")
                    print(stringList[0])
                    print(stringList[1])
                    var line = {
                        textIn:serverIpValue.text
                    }
                    var elem = find(listModelIp, function(item) { return item.textIn === serverIpValue.text })
                    if (elem === false) {
                        listModelIp.insert(1, line)
                    } else {
                        listModelIp.move(elem, 1,1)
                    }
                    controlServer.serverIp = stringList[0]
                    controlServer.serverPort = stringList[1]
                }
            }

            ListModel {
                id: listModelIp
            }
        }



        Rectangle {
            id: videoSettigns
            x: 208
            y: 29
            width: 398
            height: 375
            color: "#00000000"
            border.width: 2

            Rectangle {
                id: videoSettingsLabelFrame
                x: 0
                y: -14
                width: 140
                height: 14
                color: "#000000"

                Text {
                    id: videoSettingsLabel
                    color: "#ffffff"
                    text: qsTr("Drone Parameters")
                    anchors.fill: parent
                    font.bold: true
                    font.pixelSize: 12
                }
            }

            Button {
                id: getParamBtn
                x: 156
                y: 312
                width: 89
                height: 26
                text: qsTr("Get Params")
                onClicked: {
                    var query = "{\"id\":0,\"name\":\"param\",\"data\":{\"cmd\":\"list\"}}"
                    controlServer.sendToDrone(qsTr(query))
                }
            }

            ComboBox {
                id: comboBox
                x: 10
                y: 8
                width: 380
                height: 32
                model: controlServer.paramList
            }

            Rectangle {
                id: paramBlock
                x: 8
                y: 49
                width: 382
                height: 221
                color: "#00000000"
                border.width: 2

                Rectangle {
                    id: paramValueFRAME
                    x: 6
                    y: 161
                    width: 368
                    height: 19
                    color: "#00000000"
                    border.width: 2

                    TextInput {
                        id: paramValue
                        text: getParamValue(comboBox.currentText)
                        anchors.topMargin: 2
                        anchors.leftMargin: 4
                        anchors.fill: parent
                        font.pixelSize: 12
                    }
                }

                Label {
                    id: paramName
                    x: 6
                    y: 28
                    width: 368
                    height: 16
                    text: getParamId(comboBox.currentText)
                }

                TextArea {
                    id: shortDescript
                    x: 6
                    y: 66
                    width: 368
                    height: 75
                    wrapMode: Text.WordWrap
                    text: mapValue(getParamId(comboBox.currentText))
                }

                Button {
                    id: setValueButton
                    x: 148
                    y: 192
                    width: 87
                    height: 21
                    text: qsTr("Set value")
                    onClicked: {
                        var query = "{\"id\":0,\"name\":\"param\",\"data\":{\"cmd\":\"set\", \"param_id\":\""+ getParamId(comboBox.currentText)
                                +"\", \"value\":" + paramValue.text + "}}"
                        print(query)
                        controlServer.sendToDrone(qsTr(query))
                        var queryList = "{\"id\":0,\"name\":\"param\",\"data\":{\"cmd\":\"list\"}}"
                        controlServer.sendToDrone(qsTr(queryList))
                    }
                }

                Label {
                    id: paramValueLabel
                    x: 6
                    y: 144
                    width: 78
                    height: 16
                    text: qsTr("Param value:")
                }

                Label {
                    id: label
                    x: 6
                    y: 8
                    width: 158
                    height: 16
                    text: qsTr("Parameter name:")
                }

                Label {
                    id: label1
                    x: 6
                    y: 50
                    width: 160
                    height: 16
                    text: qsTr("Parameter description:")
                }
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
            x: 504
            y: 408
            width: 90
            height: 30
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

/*##^## Designer {
    D{i:16;anchors_height:15;anchors_width:102;anchors_x:8;anchors_y:0}D{i:22;anchors_height:20;anchors_width:156;anchors_x:4;anchors_y:2}
}
 ##^##*/
