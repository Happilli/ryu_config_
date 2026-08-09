pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme

Rectangle {
    id: root
    required property var tabs
    property int currentIndex: 0
    signal tabSelected(int index)

    height: 42
    radius: height / 2
    color: Theme.surfaceContainerLow
    border.width: 1
    border.color: Theme.outlineVariant
    width: rowContent.implicitWidth + 8

    Row {
        id: measureRow
        spacing: 6
        Repeater {
            model: root.tabs
            delegate: Text {
                required property string modelData
                text: modelData
                font.pixelSize: 14
                visible: false
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 4

        Rectangle {
            id: pill
            readonly property real pillX: {
                let x = 0;
                for (let i = 0; i < root.currentIndex; i++)
                    x += measureRow.children[i].implicitWidth + 24 + measureRow.spacing;
                return x;
            }
            x: pillX
            width: measureRow.children[root.currentIndex] ? measureRow.children[root.currentIndex].implicitWidth + 24 : 0
            height: parent.height
            radius: height / 2
            color: Theme.primaryContainer
            border.color: Theme.primaryColor
            border.width: 1
            Behavior on x {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.4
                }
            }
        }

        Row {
            id: rowContent
            anchors.centerIn: parent
            spacing: 6
            Repeater {
                model: root.tabs
                delegate: Item {
                    id: tabItem
                    required property string modelData
                    required property int index
                    readonly property bool isActive: root.currentIndex === index
                    width: label.implicitWidth + 24
                    height: root.height - 8

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: tabItem.modelData
                        font.pixelSize: 14
                        font.weight: tabItem.isActive ? Font.Medium : Font.Normal
                        color: tabItem.isActive ? Theme.onPrimaryContainer : Theme.onSurfaceVariant
                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.tabSelected(tabItem.index)
                    }
                }
            }
        }
    }
}
