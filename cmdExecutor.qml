import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Window 2.2
import backend.DroneConfig 1.0
import QtQuick.Layouts 1.3

Window {
    height: 282
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
        anchors.bottomMargin: 33
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    Rectangle {
        id: rectangle
        x: 0
        y: 0
        width: 640
        height: 282
        color: "#9a9797"
        border.color: "#37383d"
        border.width: 2


        Rectangle {
            id: cmdInputFrame
            x: 12
            y: 33
            width: 510
            height: 24
            color: "#00000000"
            border.color: "#37383d"
            border.width: 2

            TextInput {
                id: cmdInput
                x: 4
                y: 8
                width: 506
                height: 20
                text: curInCmd
                font.family: "Times New Roman"
                font.capitalization: Font.AllLowercase
                font.pixelSize: 12
                onFocusChanged:{
                    historyBox.visible = !historyBox.visible
                }
            }

            Label {
                id: cmdInputLbl
                x: 0
                y: -24
                width: 263
                height: 18
                text: qsTr("Command:")
            }
        }


        MouseArea {
            id: closeBtn
            x: 618
            y: 8
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
        Button {
            id: executeBtn
            x: 531
            y: 34
            width: 94
            height: 25
            text: qsTr("Execute")
            onClicked: {
                var line = {
                    textIn:cmdInput.text
                }
                if (find(listModel, function(item) { return item.textIn === cmdInput.text }) === null) {
                    listModel.append(line)
                }
                controlServer.sendToDrone("{\"id\":0,\"name\":\"cmd\",\"data\":{\"system\":\"exec\",\"action\":\"" + cmdInput.text + "\"}}")
            }
        }
    }

    Rectangle {
        id: cmdOutFrame
        x: 12
        y: 97
        width: 620
        height: 177
        color: "#00000000"
        border.color: "#37383d"
        border.width: 2


        Label {
            id: cmdOutLabel
            x: 0
            y: -24
            width: 163
            height: 18
            text: qsTr("Drone Response:")
        }

        ScrollView {
            id: scrollView
            x: 0
            y: 0
            width: 620
            height: 177

            TextArea {
                id: cmdOut
                x: 0
                y: 0
                width: 620
                height: 177
                text: controlServer.cmdResult
                padding: 4
                wrapMode: Text.NoWrap
            }
        }
    }

    Rectangle {
        id: historyBox
        visible: false
        x: 14
        y: 55
        width: 506
        height: listModel.count * 20 < 200 ?  listModel.count * 20 : 200
        color: "#ffffff"
        border.width: 1
        z: 0


        ListView {
            id: listView
            x: 5
            y: 0
            width: 501
            height: 200
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
                id: listModel
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
                       curInCmd = textIn
                   }
                }
            }
        }

    }
}

/*##^## Designer {
    D{i:62;anchors_height:200;anchors_width:506;anchors_x:0;anchors_y:0}
}
 ##^##*/
