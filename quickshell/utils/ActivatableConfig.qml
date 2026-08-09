pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: root
    property bool isActive: false
    signal activated
    signal deactivated

    function show() {
        if (!isActive) {
            isActive = true;
            activated();
        }
    }
    function hide() {
        if (isActive) {
            isActive = false;
            deactivated();
        }
    }
    function toggle() {
        isActive ? hide() : show();
    }
}
