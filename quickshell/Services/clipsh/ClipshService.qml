pragma Singleton
import Quickshell
import Ryu.Clipsh

Singleton {
    id: root

    readonly property alias clipsh: inner

    Clipsh {
        id: inner
    }
}
