pragma ComponentBehavior: Bound
import Ryu.Clipsh
import QtQuick
import QtQuick.Controls
import qs.Services.Theme
import qs.Components.common

Item {
    id: root

    signal itemHandled

    property var chernobylRoot: null

    readonly property int panelSize: 450
    readonly property int panelMinHeight: 100
    readonly property int itemH: 53
    readonly property int radius: 12
    readonly property color inputBg: Theme.surfaceContainer
    readonly property color inputBorder: Theme.outlineVariant
    readonly property color itemBg: Theme.card
    readonly property color itemHoverBg: Theme.hover(Theme.card)
    readonly property color itemText: Theme.onSurface
    readonly property color itemHoverText: Theme.onSurface
    readonly property color iconColor: Theme.onSurface
    readonly property color wipeBg: Theme.card
    readonly property color wipeBgHover: Theme.errorContainer
    readonly property color wipeIcon: Theme.onSurface
    readonly property color wipeIconHover: Theme.onErrorContainer
    readonly property color emptyText: Theme.textSecondary

    implicitWidth: root.panelSize
    implicitHeight: root._filteredCount === 0 ? root.panelMinHeight : Math.min(Math.max(62 + root._filteredCount * root.itemH, root.panelMinHeight), root.panelSize)

    property var _previewCache: ({})
    property var _filtered: []
    readonly property int _filteredCount: root._filtered.length

    function _rebuildPreviewCache() {
        const cache = {};
        const h = clipsh.history;
        for (let i = 0; i < h.length; i++) {
            cache[h[i]] = clipsh.previewText(h[i]).toLowerCase();
        }
        root._previewCache = cache;
    }

    function _applyFilter() {
        const q = searchBox.text.trim().toLowerCase();
        const h = clipsh.history;
        if (q === "") {
            root._filtered = h;
            return;
        }
        const cache = root._previewCache;
        root._filtered = h.filter(e => (cache[e] ?? "").includes(q));
    }

    Component.onCompleted: {
        clipsh.fetchHistory();
    }

    Connections {
        target: clipsh
        function onHistoryChanged() {
            root._rebuildPreviewCache();
            root._applyFilter();
        }
    }

    Connections {
        target: root.chernobylRoot
        function onFocusRequested() {
            clipsh.fetchHistory();
            searchBox.forceActiveFocus();
        }
    }

    Clipsh {
        id: clipsh

        onActionFinished: root.itemHandled()
        onWiped: root.itemHandled()
        onError: msg => console.warn("[Clipsy]", msg)
    }

    Row {
        id: topRow

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 12
        }
        spacing: 8

        SearchField {
            id: searchBox
            width: parent.width - 46
            placeholderText: "Search…"
            onTextEdited: {
                root._applyFilter();
                listView.forceLayout();
            }
        }

        Rectangle {
            width: 38
            height: 38
            radius: root.radius
            color: wipeMouse.containsMouse ? root.wipeBgHover : root.wipeBg
            clip: true

            Text {
                anchors.centerIn: parent
                text: "\udb80\uddb4"
                font.pixelSize: 16
                color: wipeMouse.containsMouse ? root.wipeIconHover : root.wipeIcon
            }

            MouseArea {
                id: wipeMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: clipsh.wipe()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }
        }
    }

    Item {
        id: listContainer

        anchors {
            top: topRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            margins: 12
            topMargin: 10
        }

        ListView {
            id: listView

            anchors.fill: parent
            spacing: 5
            clip: true
            model: root._filtered

            EmptyState {
                anchors.centerIn: parent
                visible: listView.count === 0 && !clipsh.loading
                title: "No clipboard history"
            }

            EmptyState {
                anchors.centerIn: parent
                visible: clipsh.loading
                title: "Loading…"
            }

            add: Transition {
                NumberAnimation {
                    property: "y"
                    from: ViewTransition.destination.y + 10
                    to: ViewTransition.destination.y
                    duration: 260
                    easing.type: Easing.OutExpo
                }
            }

            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            delegate: Item {
                id: delegateRoot

                required property var modelData

                readonly property bool isImg: clipsh.isImage(modelData)
                property real dragX: 0
                property bool actioning: false
                readonly property real swipeThreshold: delegateRoot.width * 0.32

                width: listView.width
                height: delegateRoot.isImg ? 110 : 48

                Rectangle {
                    anchors.fill: parent
                    radius: root.radius
                    visible: delegateRoot.dragX < 0
                    color: Theme.errorContainer

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.margins: 16
                        spacing: 6

                        Text {
                            text: delegateRoot.actioning ? "Deleting…" : "Delete"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: Theme.onErrorContainer
                        }
                    }
                }

                Rectangle {
                    id: foreground

                    width: parent.width
                    height: parent.height
                    x: delegateRoot.dragX
                    radius: root.radius
                    clip: true
                    color: itemMouse.containsMouse ? root.itemHoverBg : root.itemBg

                    Behavior on x {
                        enabled: !dragHandler.active
                        SpringAnimation {
                            spring: 4.5
                            damping: 0.6
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                            easing.type: Easing.OutQuad
                        }
                    }

                    Image {
                        id: thumbImage
                        visible: delegateRoot.isImg && status !== Image.Error && source !== ""
                        anchors.fill: parent
                        anchors.margins: 6
                        source: delegateRoot.isImg ? clipsh.tempImagePath(delegateRoot.modelData) : ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                        sourceSize.width: 400
                        sourceSize.height: 220
                    }

                    Text {
                        visible: !delegateRoot.isImg || thumbImage.status === Image.Error || thumbImage.source === ""
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        text: delegateRoot.isImg ? "[image — preview unavailable]" : clipsh.previewText(delegateRoot.modelData)
                        color: itemMouse.containsMouse ? root.itemHoverText : root.itemText
                        font.pixelSize: 12
                        elide: Text.ElideRight

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                                easing.type: Easing.OutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: Math.abs(delegateRoot.dragX) < 4
                        onClicked: clipsh.copyItem(delegateRoot.modelData)
                    }

                    DragHandler {
                        id: dragHandler
                        target: null
                        xAxis.enabled: true
                        yAxis.enabled: false

                        onTranslationChanged: {
                            if (dragHandler.active && !delegateRoot.actioning) {
                                delegateRoot.dragX = Math.min(0, Math.max(-delegateRoot.width, translation.x));
                            }
                        }

                        onActiveChanged: {
                            if (dragHandler.active) {
                                return;
                            }

                            if (delegateRoot.dragX <= -delegateRoot.swipeThreshold) {
                                delegateRoot.actioning = true;
                                actionTimer.restart();
                            } else {
                                delegateRoot.dragX = 0;
                            }
                        }
                    }
                }

                Timer {
                    id: actionTimer
                    interval: 260
                    onTriggered: {
                        clipsh.deleteItem(delegateRoot.modelData);
                        delegateRoot.actioning = false;
                        delegateRoot.dragX = 0;
                    }
                }
            }
        }
    }
}
