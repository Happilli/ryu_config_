pragma ComponentBehavior: Bound
import QtQuick
import qs.Services.Theme
import qs.utils
import qs.Components.common

Item {
    id: root

    visible: true
    focus: true

    function closeChernobyl() {
        ToggleConfigs.chernobyl.isActive = false;
    }

    Keys.onEscapePressed: root.closeChernobyl()

    Keys.onTabPressed: {
        root.currentTab = (root.currentTab + 1) % root.tabs.length;
    }

    Keys.onBacktabPressed: {
        root.currentTab = (root.currentTab - 1 + root.tabs.length) % root.tabs.length;
    }

    readonly property var tabs: [
        {
            "label": "Clipboard",
            "component": clipsyComp
        },
        {
            "label": "Launcher",
            "component": launcherComp
        },
        {
            "label": "Daily Wars",
            "component": warComp
        },
        {
            "label": "Nihongo",
            "component": nihongoComp
        }
    ]

    property int currentTab: 0

    signal focusRequested

    function grabFocus() {
        root.forceActiveFocus();
        root.focusRequested();
    }

    Component.onCompleted: Qt.callLater(root.grabFocus)

    onCurrentTabChanged: Qt.callLater(root.grabFocus)

    HoverHandler {
        onHoveredChanged: {
            if (hovered)
                root.grabFocus();
        }
    }

    implicitWidth: mainColumn.implicitWidth
    implicitHeight: mainColumn.implicitHeight

    Component {
        id: clipsyComp
        Clipsy {
            onItemHandled: root.closeChernobyl()
        }
    }
    Component {
        id: launcherComp
        Launcher {
            onAppLaunched: root.closeChernobyl()
        }
    }
    Component {
        id: warComp
        War {}
    }
    Component {
        id: nihongoComp
        Nihongo {}
    }
    Column {
        id: mainColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: 16

        SlidingTabBar {
            id: tabBar
            anchors.horizontalCenter: parent.horizontalCenter
            tabs: root.tabs.map(t => t.label)
            currentIndex: root.currentTab
            onTabSelected: function (index) {
                root.currentTab = index;
            }
        }

        Card {
            id: contentBox
            anchors.horizontalCenter: parent.horizontalCenter

            width: Math.max(minTabWidth, tabLoader.implicitWidth)
            height: Math.max(minTabHeight, tabLoader.implicitHeight)

            cardRadius: 20
            surface: Theme.shell
            clip: true

            readonly property real minTabWidth: 400
            readonly property real minTabHeight: 280

            Behavior on width {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutExpo
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutExpo
                }
            }

            Loader {
                id: tabLoader
                sourceComponent: root.tabs[root.currentTab].component

                onLoaded: {
                    if (item && item.hasOwnProperty("chernobylRoot")) {
                        item.chernobylRoot = root;
                    } else if (item) {
                        item["chernobylRoot"] = root;
                    }
                    Qt.callLater(root.grabFocus);
                }
            }
        }
    }
}
