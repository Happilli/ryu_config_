import QtQuick
import qs.utils

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
}
