pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.Services.Theme
import qs.Services.clipsh
import qs.Components.common
import Ryu.Extraa

Item {
    id: root

    signal itemHandled

    property var chernobylRoot: null

    readonly property var clipsh: ClipshService.clipsh

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
    implicitHeight: root._filteredCount === 0 ? root.panelMinHeight : Math.min(Math.max(34 + topRow.height + listView.contentHeight, root.panelMinHeight), root.panelSize)
    property var _previewCache: ({})
    property var _filtered: []
    readonly property int _filteredCount: root._filtered.length

    function _rebuildPreviewCache() {
        const cache = {};
        const h = root.clipsh.history;
        for (let i = 0; i < h.length; i++) {
            cache[h[i]] = root.clipsh.previewText(h[i]).toLowerCase();
        }
        root._previewCache = cache;
    }

    function _applyFilter() {
        const q = searchBox.text.trim().toLowerCase();
        const h = root.clipsh.history;
        if (q === "") {
            root._filtered = h;
            return;
        }
        const cache = root._previewCache;
        root._filtered = h.filter(e => (cache[e] ?? "").includes(q));
    }

    Component.onCompleted: {
        root._rebuildPreviewCache();
        root._applyFilter();
        root.clipsh.fetchHistory();
    }

    Connections {
        target: root.clipsh
        function onHistoryChanged() {
            root._rebuildPreviewCache();
            root._applyFilter();
        }
        function onActionFinished() {
            root.itemHandled();
        }
        function onWiped() {
            root.itemHandled();
        }
        function onError(msg) {
            console.warn("[Clipsy]", msg);
        }
    }

    Connections {
        target: root.chernobylRoot
        function onFocusRequested() {
            root.clipsh.fetchHistory();
            searchBox.forceActiveFocus();
        }
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

        MaterialIconButton {
            width: 38
            height: 38
            type: MaterialIconButton.Tonal
            shape: MaterialIconButton.Square
            iconText: "\udb80\uddb4"
            iconSize: 16
            color: hovered ? root.wipeBgHover : root.wipeBg
            iconColor: hovered ? root.wipeIconHover : root.wipeIcon
            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
            onClicked: root.clipsh.wipe()
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
                visible: listView.count === 0 && !root.clipsh.loading
                title: "No clipboard history"
            }

            EmptyState {
                anchors.centerIn: parent
                visible: root.clipsh.loading && listView.count === 0
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

                readonly property bool isImg: root.clipsh.isImage(modelData)
                property string imageUrl: isImg ? root.clipsh.tempImagePath(modelData) : ""
                property real dragX: 0
                property bool actioning: false
                readonly property real swipeThreshold: delegateRoot.width * 0.32

                width: listView.width
                height: delegateRoot.isImg ? 110 : 48

                Connections {
                    target: root.clipsh
                    function onImageReady(entry, url) {
                        if (entry === delegateRoot.modelData)
                            delegateRoot.imageUrl = url;
                    }
                }

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
                        visible: delegateRoot.isImg && delegateRoot.imageUrl !== "" && status !== Image.Error
                        anchors.fill: parent
                        source: delegateRoot.imageUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        sourceSize.width: 400
                        sourceSize.height: 220
                    }

                    Text {
                        visible: !thumbImage.visible
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        text: !delegateRoot.isImg ? root.clipsh.previewText(delegateRoot.modelData) : (delegateRoot.imageUrl === "" ? "[image — decoding…]" : "[image — preview unavailable]")
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
                        onClicked: root.clipsh.copyItem(delegateRoot.modelData)
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
                        root.clipsh.deleteItem(delegateRoot.modelData);
                        delegateRoot.actioning = false;
                        delegateRoot.dragX = 0;
                    }
                }
            }
        }
    }
}
