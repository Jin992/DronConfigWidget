import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.2
import backend.DroneConfig 1.0
import QtQuick.Layouts 1.3

Window {
    height: 324
    width: 640
    id: root

    property var curInCmd: "Enter Command"

    function find(model, criteria) {
        for(var i = 0; i < model.count; ++i) if (criteria(model.get(i))) return model.get(i)
        return null
    }

    Component.onCompleted: {
        var file = controlServer.readHistory("history.txt")
        var lines = file.split('\n')
        print(lines)
        for (var i = 0; i < lines.length; i++) {
            var line = {
                textIn:lines[i]
            }
            if (find(listModel, function(item) { return item.textIn === lines[i] }) === null) {
                listModel.append(line)
            }
        }
    }


    flags: Qt.FramelessWindowHint |
           Qt.WindowMinimizeButtonHint |
           Qt.Window | Qt.WindowStaysOnTopHint

    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        height: 322
        anchors.bottomMargin: 0
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    Rectangle {
        id: rectangle
        x: 0
        y: 0
        width: 640
        height: 324
        color: "#9a9797"
        border.color: "#37383d"
        border.width: 2


        Rectangle {
            id: cmdInputFrame
            x: 30
            y: 250
            width: 604
            height: 24
            color: "#00000000"
            border.color: "#37383d"
            border.width: 2

            TextInput {
                id: cmdInput
                x: 4
                y: 4
                width: 600
                height: 20
                text: curInCmd
                focus: true
                font.family: "Times New Roman"
                font.capitalization: Font.AllLowercase
                font.pixelSize: 14
                property int listCnt: 0
                Keys.onReturnPressed: {
                    var line = {
                        textIn:cmdInput.text
                    }
                    if (find(listModel, function(item) { return item.textIn === cmdInput.text }) === null) {
                        listModel.append(line)
                    }
                    controlServer.sendToDrone("{\"id\":0,\"name\":\"cmd\",\"data\":{\"system\":\"exec\",\"action\":\"" + cmdInput.text + "\"}}")

                }
                Keys.onDownPressed: {
                    if (listCnt < listModel.count - 1) {
                        listCnt++
                        curInCmd = listModel.get(listCnt).textIn
                    }
                }
                Keys.onUpPressed: {
                    if (listCnt > 0) {
                        listCnt--;
                        curInCmd = listModel.get(listCnt).textIn
                    }
                }
            }
        }


        MouseArea {
            id: closeBtn
            x: 618
            y: 5
            width: 14
            height: 12

            Label {
                id: closeLbl
                x: 0
                y: -8
                text: qsTr("x")
                font.bold: true
                font.pointSize: 16
            }
            onClicked: {
                var strToWrite = ""
                for(var i = 0; i < listModel.count; ++i) {
                    strToWrite += listModel.get(i).textIn + "\n"
                }
                if (!controlServer.writeHistory("history.txt", strToWrite.toString())) {
                    controlServer.uiMsg = "Write error"
                }
                root.close()}
        }

        Text {
            id: inLabel
            x: 13
            y: 253
            text: qsTr("->")
            font.pixelSize: 13
        }

        Rectangle {
            id: missionBlock
            x: 8
            y: 277
            width: 625
            height: 40
            color: "#00000000"
            border.color: "#37383d"
            border.width: 2

            Rectangle {
                id: missionNameInputFrame
                x: 119
                y: 9
                width: 359
                height: 23
                color: "#00000000"
                border.color: "#37383d"
                border.width: 2

                TextInput {
                    id: missionNameInput
                    x: 5
                    y: 6
                    width: 354
                    height: 20
                    echoMode: TextInput.Normal
                    font.pixelSize: 12
                }

                Label {
                    id: missionNameLabel
                    x: -105
                    y: 4
                    text: qsTr("Mission name:")
                }
            }

            Button {
                id: missionStart
                x: 484
                y: 9
                width: 62
                height: 23
                text: qsTr("start")
                onClicked: {
                    var query = "(echo -n 'MISSION START " + missionNameInput.text + " ') >> /tmp/missionPoint.txt"
                    var cmd = "{\"id\":0,\"name\":\"cmd\",\"data\":{\"system\":\"exec\",\"action\":\"" + query + "\"}}"
                    controlServer.sendToDrone(cmd.toString())
                    print(cmd.toString())
                }
            }

            Button {
                id: missionEnd
                x: 555
                y: 9
                width: 62
                height: 23
                text: qsTr("end")
                onClicked: {
                    var query = "(echo -n 'MISSION STOP " + missionNameInput.text + "') >> /tmp/missionPoint.txt"
                    var cmd = "{\"id\":0,\"name\":\"cmd\",\"data\":{\"system\":\"exec\",\"action\":\"" + query + "\"}}"
                    controlServer.sendToDrone(cmd.toString())
                    print(cmd.toString())
                }
            }
        }
    }

    Rectangle {
        id: cmdOutFrame
        x: 10
        y: 19
        width: 624
        height: 228
        color: "#00000000"
        border.color: "#37383d"
        border.width: 2


        ScrollView {
            id: scrollView
            x: 0
            y: 0
            width: 620
            height: 228

            TextArea {
                id: cmdOut
                x: 0
                y: 0
                width: 620
                height: 227
                text: controlServer.cmdResult
                selectByMouse: true
                padding: 4
                wrapMode: Text.NoWrap
            }
        }
    }

    ListModel {
        id: listModel
    }


}
