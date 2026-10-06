pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Item {
    id: root

    property bool pinned: false
    signal clicked

    width: 28
    height: 28

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.hover(Theme.shell)
        opacity: mouse.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "\uf08d"
        font.pixelSize: 16
        color: root.pinned ? Theme.primaryColor : Theme.textSecondary
        rotation: root.pinned ? 0 : 45

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }

        Behavior on rotation {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
