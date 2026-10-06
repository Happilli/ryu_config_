pragma ComponentBehavior: Bound
import Qt.labs.folderlistmodel
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Ryu.Extraa
import Ryu.Shapes
import qs.Services.Shapes
import qs.Services.Theme
import qs.utils
import qs.Services.Paths
import qs.Components.common

Item {
    id: root
    property bool isHovered: false
    property bool isRefreshing: false
    property bool contentVisible: false
    readonly property string thumbsPath: PathService.home + "/thumbs/"
    readonly property string picturesPath: PathService.home + "/Pictures/"
    readonly property string thumbsUrl: "file://" + PathService.home + "/thumbs/"
    signal wallpaperChanged(string path)
    function positionToCurrentWallpaper() {
        if (!WallpaperConfig.currentWallpaper)
            return;
        const cur = WallpaperConfig.currentWallpaper.split('/').pop();
        for (let i = 0; i < filteredModel.count; i++) {
            if (filteredModel.get(i).fileName === cur) {
                listView.currentIndex = i;
                listView.positionViewAtIndex(i, ListView.Center);
                return;
            }
        }
    }

    function applyWallpaper(index) {
        const fn = filteredModel.get(index).fileName;
        const fp = root.picturesPath + fn;
        Theme.thumbPath = root.thumbsPath + fn;
        Theme.saveTheme();
        WallpaperConfig.currentWallpaper = fp;
        WallpaperConfig.saveConfig();
        Theme.generateColors();
        Quickshell.execDetached(["/usr/bin/notify-send", "--app-name=Wallski", "Wallpaper Applied", fn.replace(/\.[^/.]+$/, "").replace(/_/g, " ")]);
        root.wallpaperChanged(fp);
        PaimonClockConfig.randomizePosition();
    }
    function applyFilter(query) {
        filteredModel.clear();
        const q = query.toLowerCase().trim();
        for (let i = 0; i < folderModel.count; i++) {
            const fn = folderModel.get(i, "fileName");
            if (!q || fn.toLowerCase().includes(q))
                filteredModel.append({
                    fileName: fn
                });
        }
        if (!q)
            Qt.callLater(root.positionToCurrentWallpaper);
        else {
            listView.currentIndex = 0;
            listView.positionViewAtIndex(0, ListView.Center);
        }
    }

    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: content.width
    height: content.height
    FolderListModel {
        id: folderModel
        folder: root.thumbsUrl
        nameFilters: ["*.jpg", "*.jpeg"]
        showDirs: false
        onCountChanged: if (root.contentVisible)
            root.applyFilter("")
    }

    ListModel {
        id: filteredModel
    }

    HoverHandler {
        onHoveredChanged: {
            root.isHovered = hovered;
            if (hovered) {
                unloadTimer.stop();
                root.contentVisible = true;
                root.applyFilter("");
            } else {
                unloadTimer.restart();
            }
        }
    }

    Timer {
        id: unloadTimer
        interval: 400
        onTriggered: {
            root.contentVisible = false;
            searchBox.text = "";
            searchBox.clearFocus();
        }
    }

    Process {
        id: bamProcess
        command: ["/bin/bash", PathService.home + "/.config/quickshell/ryu-shell/Scripts/bam.sh"]
        running: false
        onExited: {
            root.isRefreshing = false;
            refreshShape.shape = MaterialShape.SoftBurst;
            searchBox.text = "";
            filteredModel.clear();
            folderModel.folder = "";
            folderModel.folder = root.thumbsUrl;
        }
    }

    PopoutShape {
        id: content
        width: 1600
        height: root.isHovered ? 330 : 0.1
        alignment: 1
        radius: 15
        color: Theme.shell
        clip: true

        Column {
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 10
            visible: root.contentVisible

            ClippingRectangle {
                width: parent.width
                height: 260
                radius: 14
                color: Theme.card

                ListView {
                    id: listView
                    anchors.fill: parent
                    model: root.contentVisible ? filteredModel : null
                    orientation: ListView.Horizontal
                    spacing: 10
                    highlightMoveDuration: 300
                    preferredHighlightBegin: width / 2 - 160
                    preferredHighlightEnd: width / 2 + 160
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    clip: true
                    interactive: false
                    reuseItems: true
                    cacheBuffer: 960

                    Rectangle {
                        anchors.centerIn: parent
                        width: 320
                        height: 260
                        color: "transparent"
                        radius: 14
                        border {
                            width: 3
                            color: Theme.primaryColor
                        }
                        z: 100
                    }

                    delegate: Item {
                        id: del
                        required property string fileName
                        required property int index
                        readonly property bool isCurrent: index === ListView.view.currentIndex
                        width: 320
                        height: 260

                        ClippingRectangle {
                            anchors.fill: parent
                            radius: 14
                            color: Theme.cardInner

                            Image {
                                anchors.fill: parent
                                source: root.thumbsUrl + del.fileName
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                cache: true
                                sourceSize.width: 320
                                sourceSize.height: 260
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: "black"
                                opacity: del.isCurrent ? 0.7 : 0

                                Text {
                                    anchors.centerIn: parent
                                    text: del.fileName.replace(/\.[^/.]+$/, "").replace(/_/g, " ")
                                    color: "white"
                                    elide: Text.ElideMiddle
                                    width: parent.width - 48
                                    horizontalAlignment: Text.AlignHCenter
                                    font {
                                        pixelSize: 13
                                        weight: Font.Medium
                                    }
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: del.isCurrent ? Qt.PointingHandCursor : Qt.ArrowCursor
                            enabled: del.isCurrent
                            onClicked: root.applyWallpaper(del.index)
                        }
                    }
                }

                MouseArea {
                    property real acc: 0
                    anchors.fill: parent
                    z: -1
                    acceptedButtons: Qt.NoButton
                    onWheel: wheel => {
                        if (wheel.pixelDelta.x === 0)
                            return;
                        acc -= wheel.pixelDelta.x;
                        if (Math.abs(acc) >= 50) {
                            acc > 0 ? listView.incrementCurrentIndex() : listView.decrementCurrentIndex();
                            acc = 0;
                        }
                        wheel.accepted = true;
                    }
                }

                EmptyState {
                    anchors.centerIn: parent
                    visible: filteredModel.count === 0
                    title: searchBox.text ? `No results for "${searchBox.text}"` : "No wallpapers found"
                    subtitle: searchBox.text ? "Try a different search term" : "Add images to ~/Pictures/"
                }
            }

            Item {
                width: parent.width
                height: 44

                Row {
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    SearchField {
                        id: searchBox
                        property bool expanded: searchHover.hovered || inputFocused || text !== ""
                        width: expanded ? 320 : 44
                        height: 44
                        placeholderText: "Search and  press Enter"

                        onReturnPressed: {
                            root.applyFilter(text);
                            text = "";
                        }

                        HoverHandler {
                            id: searchHover
                        }

                        Behavior on width {
                            SpringAnimation {
                                spring: 4.5
                                damping: 0.6
                                epsilon: 0.5
                            }
                        }
                    }
                    ThemedButtonGroup {
                        anchors.verticalCenter: parent.verticalCenter
                        sizeStyle: MaterialButtonGroup.Small
                        selectionMode: MaterialButtonGroup.Single
                        labels: Theme.schemeTypes.map(t => Theme.getSchemeDisplayName(t))
                        currentIndex: Theme.schemeTypes.indexOf(Theme.currentSchemeType)
                        fontWeight: Font.Normal
                        onToggled: (index, on) => Theme.setSchemeType(Theme.schemeTypes[index])
                    }
                }

                MaterialShape {
                    id: refreshShape
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    width: 44
                    height: 44
                    shape: MaterialShape.SoftBurst
                    color: Theme.primaryColor
                    loading: root.isRefreshing

                    HoverHandler {
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            if (root.isRefreshing)
                                return;
                            root.isRefreshing = true;
                            bamProcess.running = true;
                        }
                    }
                }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }
    }
}
