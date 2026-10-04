pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Quickshell.Widgets
import qs.Services.Theme
import qs.Components.common
import "./Areuok/"
import "./Siphon/"
import "./Warsa/"

Item {
    id: root
    property bool isHovered: false
    property bool isPinned: false
    property color barColor: Theme.surfaceContainerLow

    property real collapsedWidth: 0.1
    property real expandedWidth: 340

    property real currentBarWidth: (isHovered || isPinned) ? expandedWidth : collapsedWidth

    property real maskWidth: (isHovered || isPinned) ? expandedWidth : 1

    Behavior on currentBarWidth {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutCubic
        }
    }

    width: currentBarWidth
    height: parent?.height ?? 0
    anchors.right: parent.right

    Timer {
        id: unloadTimer
        interval: 700
        onTriggered: if (!root.isHovered && !root.isPinned)
            contentLoader.active = false
    }

    onIsHoveredChanged: {
        if (isHovered) {
            unloadTimer.stop();
            contentLoader.active = true;
        } else if (!isPinned) {
            unloadTimer.start();
        }
    }

    onIsPinnedChanged: {
        if (isPinned) {
            unloadTimer.stop();
            contentLoader.active = true;
        } else if (!isHovered) {
            unloadTimer.start();
        }
    }

    component Corner: WrapperItem {
        id: cornerRoot
        property int corner
        property real radius: 20
        property color color

        implicitWidth: radius
        implicitHeight: radius

        Component.onCompleted: {
            switch (corner) {
            case 1:
                anchors.top = parent.top;
                anchors.right = parent.left;
                rotation = 90;
                break;
            case 2:
                anchors.bottom = parent.bottom;
                anchors.right = parent.left;
                rotation = 180;
                break;
            }
        }

        Shape {
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 0
                fillColor: cornerRoot.color
                startX: cornerRoot.radius
                PathArc {
                    relativeX: -cornerRoot.radius
                    relativeY: cornerRoot.radius
                    radiusX: cornerRoot.radius
                    radiusY: radiusX
                    direction: PathArc.Counterclockwise
                }
                PathLine {
                    relativeX: 0
                    relativeY: -cornerRoot.radius
                }
                PathLine {
                    relativeX: cornerRoot.radius
                    relativeY: 0
                }
            }
        }
    }

    Rectangle {
        id: bar
        anchors.fill: parent
        color: root.barColor

        clip: root.currentBarWidth < 5

        Corner {
            corner: 1
            color: root.barColor
        }

        Corner {
            corner: 2
            color: root.barColor
        }

        Loader {
            id: contentLoader
            anchors.fill: parent

            active: false
            asynchronous: true
            clip: true

            property real contentOpacity: (root.isHovered || root.isPinned) ? 1 : 0
            property real contentTranslateX: (root.isHovered || root.isPinned) ? 0 : 30

            onLoaded: {
                item.opacity = 0;
                item.x = 30;
                item.opacity = Qt.binding(() => contentLoader.contentOpacity);
                item.x = Qt.binding(() => contentLoader.contentTranslateX);
            }

            sourceComponent: Component {
                Item {
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on x {
                        NumberAnimation {
                            duration: 350
                            easing.type: Easing.OutCubic
                        }
                    }

                    Column {
                        id: contentColumn
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top

                        Areuok {
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Warsa {
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Siphon {
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Pin {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        pinned: root.isPinned
                        onClicked: root.isPinned = !root.isPinned
                    }
                }
            }
        }

        HoverHandler {
            id: hand
            onHoveredChanged: root.isHovered = hovered
        }
    }
}
