pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Singleton {
    id: root

    readonly property var model: ToplevelManager.toplevels
    property list<var> enriched: []

    property var _entryIndex: ({})
    property bool _rebuildPending: false

    function _rebuildEntryIndex() {
        const idx = {};
        const apps = DesktopEntries.applications.values;
        for (let i = 0; i < apps.length; i++) {
            const e = apps[i];
            if (!e?.id) {
                continue;
            }
            const eid = e.id.toLowerCase();
            const bare = eid.endsWith(".desktop") ? eid.slice(0, -8) : eid;
            idx[bare] = e;
            idx[`${bare}.desktop`] = e;
            if (e.name)
                idx[e.name.toLowerCase()] = e;
        }
        root._entryIndex = idx;
    }

    function _lookupEntry(appId) {
        const id = (appId ?? "").toLowerCase();
        if (!id)
            return null;
        const lastToken = id.split(".").pop();
        return root._entryIndex[id] ?? root._entryIndex[lastToken] ?? null;
    }

    function _buildHyprIndex() {
        const idx = {};
        const hypr = Hyprland.toplevels.values;
        for (let i = 0; i < hypr.length; i++) {
            const h = hypr[i];
            if (h?.title !== undefined)
                idx[h.title] = h;
        }
        return idx;
    }

    function _rebuildEnriched() {
        const tls = ToplevelManager.toplevels?.values ?? [];
        const hyprIndex = root._buildHyprIndex();
        const groups = {};
        const order = [];

        for (let i = 0; i < tls.length; i++) {
            const tl = tls[i];
            if (!tl)
                continue;

            const rawAppId = tl.appId ?? "unknown";
            const key = rawAppId.toLowerCase();

            let group = groups[key];
            if (!group) {
                const entry = root._lookupEntry(rawAppId);
                group = {
                    appId: rawAppId,
                    name: entry?.name ?? rawAppId,
                    icon: entry?.icon ? Quickshell.iconPath(entry.icon) : "",
                    toplevels: [],
                    count: 0
                };
                groups[key] = group;
                order.push(group);
            }

            group.toplevels.push({
                toplevel: tl,
                hypr: hyprIndex[tl.title] ?? null
            });
            group.count++;
        }

        root.enriched = order;
        root._rebuildPending = false;
    }

    function _scheduleRebuild() {
        if (root._rebuildPending)
            return;
        root._rebuildPending = true;
        Qt.callLater(root._rebuildEnriched);
    }

    function toggleGroup(appGroup) {
        const insts = appGroup?.toplevels;
        if (!insts?.length)
            return;
        const active = insts.find(inst => inst?.toplevel?.activated);
        if (active) {
            active.toplevel.minimized = true;
        } else {
            insts[0]?.toplevel?.activate();
        }
    }

    Component.onCompleted: {
        root._rebuildEntryIndex();
        root._scheduleRebuild();
    }

    Connections {
        target: DesktopEntries.applications
        function onValuesChanged() {
            root._rebuildEntryIndex();
            root._scheduleRebuild();
        }
    }

    Connections {
        target: ToplevelManager.toplevels
        function onValuesChanged() {
            root._scheduleRebuild();
        }
    }
}
