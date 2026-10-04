pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Mpris
import qs.Services.Theme
import qs.Services.Shapes
import Ryu.Shapes
import Ryu.Extraa

Item {
    id: root

    signal playingChanged(bool playing)

    readonly property bool isPlaying: root.player !== null && root.player.playbackState === MprisPlaybackState.Playing
    readonly property bool hasSession: root.player !== null && (root.player.playbackState === MprisPlaybackState.Playing || root.player.playbackState === MprisPlaybackState.Paused)

    implicitWidth: root.hasSession ? 450 : 0
    implicitHeight: 40
    width: implicitWidth
    height: root.hasSession ? 40 : 0
    visible: width > 0
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    property MprisPlayer player: null

    onIsPlayingChanged: root.playingChanged(isPlaying)

    Repeater {
        id: playersRepeater
        model: Mpris.players
        delegate: Item {
            required property MprisPlayer modelData
            width: 0
            height: 0
            visible: false
            Component.onCompleted: {
                if (!root.player)
                    root.player = modelData;
            }
            Component.onDestruction: {
                if (root.player === modelData) {
                    root.player = null;
                    root.playingChanged(false);
                }
            }
        }
    }

    Timer {
        id: positionTimer
        running: root.isPlaying
        interval: 500
        repeat: true
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 12
        visible: root.hasSession

        Item {
            id: trackLabelArea
            width: contentRow.width - thumbnailItem.width - progressColumn.width - controlsRow.width - contentRow.spacing * 3
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                spacing: 1

                Item {
                    width: parent.width
                    height: trackTitle.implicitHeight
                    clip: true

                    Text {
                        id: trackTitle
                        text: root.player ? root.player.trackTitle : ""
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.onSurface
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }
                }

                Item {
                    width: parent.width
                    height: trackArtist.implicitHeight
                    clip: true
                    visible: trackArtist.text.length > 0

                    Text {
                        id: trackArtist
                        text: root.player ? (root.player.trackArtist || "") : ""
                        font.pixelSize: 10
                        color: Theme.onSurface
                        width: parent.width
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Item {
            id: thumbnailItem
            width: 40
            height: 40
            anchors.verticalCenter: parent.verticalCenter

            ShapeCanvas {
                anchors.fill: parent
                shape: MaterialShape.Cookie12Sided
                color: "transparent"
                imageSource: root.player ? (root.player.trackArtUrl || "") : ""
                borderWidth: 2
                borderColor: Theme.accentColor
            }
        }

        Column {
            id: progressColumn
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: timeDisplay
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.formatTime(root.player ? root.player.position : 0) + " / " + root.formatTime(root.player ? root.player.length : 0)
                font.pixelSize: 9
                color: Theme.onSurface
            }

            Item {
                id: progressBarArea
                width: parent.width
                height: 14

                Behavior on width {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                property real value: root.player ? root.player.position : 0
                property real minVal: 0
                property real maxVal: root.player && root.player.length > 0 ? root.player.length : 1
                property bool isDragging: false
                property real tempFrac: 0
                property real extrapolatedPosition: value

                Timer {
                    id: smoothTimer
                    running: root.isPlaying && !progressBarArea.isDragging
                    interval: 16
                    repeat: true
                    onTriggered: {
                        if (progressBarArea.extrapolatedPosition < progressBarArea.maxVal)
                            progressBarArea.extrapolatedPosition += 0.016;
                    }
                }

                onValueChanged: {
                    extrapolatedPosition = value;
                }

                property real frac: isDragging ? tempFrac : (maxVal > 0 ? Math.max(0, Math.min(1, (extrapolatedPosition - minVal) / (maxVal - minVal))) : 0)
                property color activeColor: Theme.primaryColor
                property color inactiveColor: Theme.surfaceContainerHighest

                signal scrub(int delta)
                onScrub: delta => {
                    if (root.player) {
                        let newPos = root.player.position + (delta * 5);
                        root.player.position = Math.max(0, Math.min(maxVal, newPos));
                    }
                }

                WavyProgress {
                    anchors.fill: parent
                    style: WavyProgress.Linear
                    indeterminate: false
                    progress: progressBarArea.frac
                    color: progressBarArea.activeColor
                    trackColor: progressBarArea.inactiveColor
                    strokeWidth: 3
                    gap: 3
                    wavelength: 30
                    waveSpeed: 0.67
                    amplitude: root.isPlaying ? 2 : 0

                    Behavior on amplitude {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    function updateDrag(mouse) {
                        progressBarArea.tempFrac = Math.max(0, Math.min(1, mouse.x / width));
                    }
                    onPressed: mouse => {
                        progressBarArea.isDragging = true;
                        updateDrag(mouse);
                    }
                    onPositionChanged: mouse => {
                        if (pressed)
                            updateDrag(mouse);
                    }
                    onReleased: mouse => {
                        if (root.player && progressBarArea.maxVal > 0) {
                            updateDrag(mouse);
                            root.player.position = progressBarArea.tempFrac * progressBarArea.maxVal;
                        }
                        progressBarArea.isDragging = false;
                    }
                    onWheel: w => {
                        const d = w.angleDelta.y || -w.angleDelta.x;
                        if (d !== 0)
                            progressBarArea.scrub(d > 0 ? 1 : -1);
                    }
                }
            }
        }

        Row {
            id: controlsRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            Rectangle {
                width: 26
                height: 26
                radius: width / 2
                color: prevMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                border.color: Theme.outlineColor
                border.width: 2
                visible: root.player ? root.player.canGoPrevious : false
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uf04a"
                    font.pixelSize: 13
                    color: Theme.onSurface
                }
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player)
                            root.player.previous();
                    }
                }
            }

            Rectangle {
                width: 30
                height: 30
                radius: width / 2
                color: playMouse.containsMouse ? Theme.primaryContainer : Theme.primaryColor
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "\uf04c" : "\uf04b"
                    font.pixelSize: 15
                    color: Theme.onPrimary
                }
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player)
                            root.player.togglePlaying();
                    }
                }
            }

            Rectangle {
                width: 26
                height: 26
                radius: width / 2
                color: nextMouse.containsMouse ? Theme.surfaceContainerHigh : "transparent"
                border.color: Theme.outlineColor
                border.width: 2
                visible: root.player ? root.player.canGoNext : false
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\uf04e"
                    font.pixelSize: 13
                    color: Theme.onSurface
                }
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.player)
                            root.player.next();
                    }
                }
            }
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0)
            return "0:00";
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return mins + ":" + (secs < 10 ? "0" : "") + secs;
    }
}
