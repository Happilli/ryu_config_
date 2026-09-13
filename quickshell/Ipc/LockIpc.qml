pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io
import qs.utils

IpcHandler {
    target: "lock"

    function lock(): string {
        LockConfig.captureAndLock();
        return "Screen locked";
    }
}
