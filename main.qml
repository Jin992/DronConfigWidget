import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.Imagine 2.3
import QtQuick.Controls.Universal 2.0


Window {
    visible: true
    width: 200
    height: 200
    color: "#00000000"
    title: qsTr("DroneControlTool")

    flags: Qt.FramelessWindowHint |
           Qt.WindowMinimizeButtonHint |
           Qt.Window | Qt.WindowStaysOnTopHint

    x: Screen.desktopAvailableWidth - width - 20
    y: Screen.desktopAvailableHeight - height - 20

    Rectangle {
        id: rectangle
        x: 0
        y: 0
        width: 200
        height: 200
        color: "#b3404040"
        radius: 100
        border.color: "#ec3c3c"
        border.width: 2

        Text {
            id: text1
            x: 70
            y: 23
            width: 60
            height: 23
            color: "#ffffff"
            text: qsTr("LTE")
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
        }

        Text {
            id: text2
            x: 48
            y: 52
            width: 105
            height: 27
            color: "#ffffff"
            text: qsTr("-98 dBm")
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 22
        }

        Text {
            id: text3
            x: 23
            y: 83
            color: "#ffffff"
            text: qsTr("Bitrate:")
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            font.pixelSize: 16
        }

        Text {
            id: text4
            x: 98
            y: 85
            width: 87
            height: 15
            color: "#ffffff"
            text: qsTr("1.07 Mbit/s")
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 14
            font.bold: true

            Switch {
                id: switch1
                x: -6
                y: 16
                width: 74
                height: 34
            }
        }

        Text {
            id: text5
            x: 23
            y: 108
            width: 154
            height: 15
            color: "#ffffff"
            text: qsTr("Video:")
            font.bold: true
            font.pixelSize: 16
        }

        RoundButton {
            id: roundButton
            x: 70
            y: 146
            text: "Config"
            font.bold: true
        }
    }
}
