import QtQuick
import qs.utils
import Quickshell.Io

Item {
    id: root

    ScreenshotIpc {
        id: screenshotIpc
    }
    LockIpc {
        id: lockIpc
    }

    ToggleIpc {
        ipcName: "chernobyl"
        config: ToggleConfigs.chernobyl
    }
    ToggleIpc {
        ipcName: "artiqa"
        config: ToggleConfigs.artiqa
    }
    ToggleIpc {
        ipcName: "wow"
        config: ToggleConfigs.wow
    }

    OsdIpc {
        id: osdIpc
    }
    RecorderIpc {
        id: recorderIpc
    }
    IpcHandler {
        target: "debug"
        function collect(): string {
            gc();
            return "ok";
        }   // not named gc(), it would recurse
    }
}
