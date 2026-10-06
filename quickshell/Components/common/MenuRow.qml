pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property real iconRotation: 0
    property alias containsMouse: mouse.containsMouse
    signal clicked

    width: parent.width
    height: 44
    color: mouse.containsMouse ? Theme.hover(Theme.shell) : "transparent"
    radius: 6

    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: Theme.primaryColor
            font.pixelSize: 18
            rotation: root.iconRotation
            Behavior on rotation {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: Theme.onSurface
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
