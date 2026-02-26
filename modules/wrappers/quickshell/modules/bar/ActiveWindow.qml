import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.config
import qs.services

Item {
    id: root
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: `0x${activeWindow?.HyprlandToplevel?.address}`
    property bool focusingThisMonitor: HyprData.activeWorkspace?.monitor == monitor?.name
    property var biggestWindow: HyprData.biggestWindowForWorkspace(HyprData.monitors[root.monitor?.id]?.activeWorkspace.id)

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: -4

        Text {
            font.pixelSize: 10
            color: Design.colors.outline
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? root.activeWindow?.appId : (root.biggestWindow?.class) ?? "Desktop"
        }

        Text {
            font.pixelSize: 14
            color: Design.colors.on_surface
            elide: Text.ElideRight
            text: root.focusingThisMonitor && root.activeWindow?.activated && root.biggestWindow ? root.activeWindow?.title : (root.biggestWindow?.title) ?? `${"Workspace"} ${monitor?.activeWorkspace?.id ?? 1}`
        }
    }
}
