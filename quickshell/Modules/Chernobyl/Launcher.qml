pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.Services.Theme
import Quickshell
import qs.Components.common

Item {
    id: root

    signal appLaunched

    property var chernobylRoot: null

    readonly property int cols: 4
    readonly property int radius: 12

    property var _sortedApps: []

    function _rebuildSortedApps() {
        const apps = DesktopEntries.applications.values.filter(d => !!d.name);
        apps.sort((a, b) => a.name.localeCompare(b.name));
        root._sortedApps = apps;
    }

    function filteredApps() {
        const q = searchBox.text.trim().toLowerCase();
        if (!q) {
            return root._sortedApps;
        }
        return root._sortedApps.filter(d => d.name.toLowerCase().includes(q));
    }

    focus: true

    Component.onCompleted: root._rebuildSortedApps()

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            root._rebuildSortedApps();
            filtered.values = root.filteredApps();
        }
    }

    Connections {
        target: root.chernobylRoot
        function onFocusRequested() {
            searchBox.forceActiveFocus();
        }
    }

    ScriptModel {
        id: filtered
        values: root.filteredApps()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mouse => {
            root.forceActiveFocus();
            mouse.accepted = true;
        }
    }

    implicitWidth: 500
    implicitHeight: mainLayout.implicitHeight

    Column {
        id: mainLayout
        width: parent.width
        topPadding: 12
        bottomPadding: 12
        leftPadding: 12
        rightPadding: 12
        spacing: 8

        SearchField {
            id: searchBox
            width: parent.width - parent.leftPadding - parent.rightPadding
            placeholderText: "Search apps…"
            onTextEdited: {
                filtered.values = root.filteredApps();
                gridView.forceLayout();
            }
        }

        Item {
            width: parent.width - parent.leftPadding - parent.rightPadding
            height: Math.max(40, gridView.contentHeight)

            EmptyState {
                anchors.centerIn: parent
                visible: gridView.count === 0
                title: "No applications found"
            }

            GridView {
                id: gridView
                anchors.fill: parent
                clip: true
                interactive: false
                cellWidth: Math.floor(width / root.cols)
                cellHeight: cellWidth

                model: filtered

                add: Transition {
                    NumberAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                delegate: Item {
                    id: delegateRoot

                    required property var modelData

                    width: gridView.cellWidth
                    height: gridView.cellHeight

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: root.radius - 4
                        color: itemMouse.containsMouse ? Theme.primaryContainer : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Easing.OutQuad
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 36
                                height: 36
                                source: Quickshell.iconPath(delegateRoot.modelData.icon, "application-x-executable")
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: delegateRoot.width - 16
                                text: delegateRoot.modelData.name
                                color: Theme.onSurface
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                const entry = delegateRoot.modelData;
                                const cmd = entry.command;

                                if (entry.runInTerminal) {
                                    Quickshell.execDetached(["kitty", "-e", ...cmd]);
                                } else {
                                    Quickshell.execDetached(cmd);
                                }
                                root.appLaunched();
                            }
                        }
                    }
                }
            }
        }
    }
}
