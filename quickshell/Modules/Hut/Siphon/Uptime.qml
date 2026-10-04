pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.Services.Shapes
import qs.Services.Paths
import qs.Services.Uptime
import qs.Components.common
import Ryu.Shapes

Item {
    id: root

    Card {
        anchors.fill: parent
        cardRadius: 20
        surface: Theme.surfaceContainer

        Item {
            id: pfpItem
            width: 80
            height: 80
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 8
            anchors.bottomMargin: 8

            ShapeCanvas {
                anchors.fill: parent
                shape: MaterialShape.Ghostish
                color: "transparent"
                imageSource: "file://" + PathService.home + "/.cache/safalQuick/pfp.jpeg"
                borderWidth: 2
                borderColor: Theme.primaryContainer
            }

            Item {
                id: bubble
                width: bubbleRect.width + 24
                height: bubbleRect.height + 16
                anchors.left: pfpItem.right
                anchors.leftMargin: -12
                anchors.bottom: pfpItem.top
                anchors.bottomMargin: -40
                z: 10

                Card {
                    id: bubbleRect
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    width: bubbleText.implicitWidth + 20
                    height: bubbleText.implicitHeight + 12
                    cardRadius: 10
                    surface: Theme.surfaceContainerHigh

                    Text {
                        id: bubbleText
                        anchors.centerIn: parent
                        text: "ryu"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: Theme.onSurface
                    }
                }

                Card {
                    width: 7
                    height: 7
                    cardRadius: 4
                    surface: Theme.surfaceContainerHigh
                    x: 10
                    y: parent.height - 12
                }
            }
        }

        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 8
            anchors.rightMargin: 18
            spacing: 2

            Text {
                anchors.right: parent.right
                text: "uptime"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Theme.onSurface
                opacity: 0.7
            }

            Text {
                anchors.right: parent.right
                text: UptimeService.uptimeText
                font.pixelSize: 18
                font.weight: Font.Medium
                color: Theme.onSurface
                elide: Text.ElideRight
            }
        }
    }
}
