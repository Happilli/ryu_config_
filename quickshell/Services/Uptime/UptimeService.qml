pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
    id: root

    property real bootTimestamp: 0
    property string uptimeText: "—"

    function _fmt(totalSeconds) {
        const days = Math.floor(totalSeconds / 86400);
        const hours = Math.floor((totalSeconds % 86400) / 3600);
        const mins = Math.floor((totalSeconds % 3600) / 60);
        const parts = [];
        if (days > 0)
            parts.push(days + "d");
        if (hours > 0)
            parts.push(hours + "h");
        if (mins > 0 || parts.length === 0)
            parts.push(mins + "m");
        return parts.join(" ");
    }

    function _recompute() {
        if (root.bootTimestamp === 0)
            return;
        const elapsed = Date.now() / 1000 - root.bootTimestamp;
        root.uptimeText = root._fmt(elapsed);
    }

    FileView {
        id: uptimeFile
        path: "file:///proc/uptime"
        onLoaded: {
            const seconds = parseFloat(text().split(" ")[0]);
            if (!isNaN(seconds)) {
                root.bootTimestamp = Date.now() / 1000 - seconds;
                root._recompute();
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root._recompute()
    }
}
