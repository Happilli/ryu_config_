import QtQuick
import qs.Services.Theme
import Quickshell
import qs.Components.common

Item {
    id: root
    anchors.fill: parent

    Rectangle {
        id: contextMenu
        width: 140
        height: 162
        color: Theme.surfaceContainer
        radius: 8
        visible: false
        z: 1000

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 6

            MenuRow {
                icon: "\uefa7"
                label: "Refresh"
                iconRotation: containsMouse ? 360 : 0
                onClicked: {
                    contextMenu.visible = false;
                    Quickshell.execDetached(["bash", Qt.resolvedUrl("../../Scripts/refresh.sh").toString().replace("file://", "")]);
                }
            }

            MenuRow {
                icon: Theme.isDarkMode ? "\udb81\udd94" : "\uf522"
                label: Theme.isDarkMode ? "Light" : "Dark"
                onClicked: {
                    contextMenu.visible = false;
                    Theme.toggleMode();
                    Quickshell.execDetached(["python3", Qt.resolvedUrl("../../Scripts/obsidianAppearance.py").toString().replace("file://", ""), Theme.isDarkMode ? "dark" : "light"]);
                }
            }

            MenuRow {
                icon: "\uf11c"
                label: "Monkey"
                onClicked: {
                    contextMenu.visible = false;
                    Quickshell.execDetached(["python3", Qt.resolvedUrl("../../Scripts/monkeymode.py").toString().replace("file://", "")]);
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                contextMenu.x = Math.min(mouse.x, root.width - contextMenu.width - 10);
                contextMenu.y = Math.min(mouse.y, root.height - contextMenu.height - 10);
                contextMenu.visible = true;
            } else if (contextMenu.visible) {
                contextMenu.visible = false;
            }
        }
    }
}
