pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell.Io
import qs.Services.Paths
import qs.Configuration.Screenshot

QtObject {
    id: root

    signal lockRequested
    readonly property string screenshotPath: PathService.home + "/.cache/safalQuick/lock_bg.jpg"

    function captureAndLock() {
        ScreenshotConfig.silent = true;
        ScreenshotConfig.isCapturing = true;
        _captureConn.enabled = true;
    }

    readonly property Process _converter: Process {
        id: _converter
        running: false
    }

    readonly property Connections _converterConn: Connections {
        target: _converter
        function onExited(code, status) {
            root.lockRequested();
        }
    }

    readonly property Connections _captureConn: Connections {
        id: _captureConn
        target: ScreenshotConfig
        enabled: false
        function onCaptureReady(path: string) {
            _captureConn.enabled = false;
            ScreenshotConfig.silent = false;
            _converter.command = ["sh", "-c", "magick " + path + " -quality 80 " + root.screenshotPath + " && rm " + path];
            _converter.running = true;
        }
    }
}
