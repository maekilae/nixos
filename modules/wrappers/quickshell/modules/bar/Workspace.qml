import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

import qs.config
import qs.widgets.buttons

Item {
    id: root
    property int ws_count: Config.options.bar?.ws?.count || 1
    property int ws_button_size: Config.options.bar?.ws?.button_size || 32
    property int rounding: ws_mouse_area.pressed ? Design.corner.small : Design.corner.full

    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    readonly property int workspaceGroup: Math.floor((monitor.activeWorkspace?.id - 1) / (Config.options.bar?.ws?.count || 1))
    property list<bool> workspaceOccupied: []
    property int workspaceIndexInGroup: (monitor.activeWorkspace?.id - 1) % (Config.options.bar?.ws?.count || 1)

    function updateWorkspaceOccupied() {
        var shown = Config.options.bar?.ws?.count || 1;
        workspaceOccupied = Array.from({
            length: shown
        }, (_, i) => {
            return Hyprland.workspaces.values.some(ws => ws.id === workspaceGroup * shown + i + 1);
        });
    }
    // Initialize workspaceOccupied when the component is created
    Component.onCompleted: updateWorkspaceOccupied()

    // Listen for changes in Hyprland.workspaces.values
    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() {
            updateWorkspaceOccupied();
        }
    }
    implicitWidth: ((Config.options.bar.ws.button_size * (Config.options.bar.ws.count - 1) + Config.options.bar.ws.active_width) + (Config.options.bar.ws.spacing * 2)) * 1.4
    implicitHeight: Config.options.bar.height * 0.7

    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch(`workspace r+1`);
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch(`workspace r-1`);
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }
    MouseArea {
        id: ws_mouse_area
        anchors.fill: parent
        hoverEnabled: true
    }

    M3Button {
        button_spec: Design.button.extra_small
        anchors {
            fill: parent
            verticalCenter: parent.verticalCenter
        }
        Grid {
            anchors.centerIn: parent

            rowSpacing: 0
            columnSpacing: Config.options.bar.ws.spacing
            columns: root.ws_count
            rows: 1
            Repeater {
                model: root.ws_count

                Rectangle {
                    z: 1
                    required property int index
                    radius: Design.corner.full
                    implicitHeight: Config.options.bar.ws.button_size
                    implicitWidth: (monitor.activeWorkspace?.id === index + 1) ? Config.options.bar.ws.active_width : root.ws_button_size

                    opacity: !(monitor.activeWorkspace?.id === index + 1) ? 1 : 0
                    //x: !(monitor.activeWorkspace?.id < index + 1) ? 30 : 30

                    color: Design.colors.on_surface
                }
            }
        }
        //active workspace
        Rectangle {
            implicitHeight: Config.options.bar.ws.active_height
            implicitWidth: Config.options.bar.ws.active_width

            radius: Design.corner.full
            anchors {
                verticalCenter: parent.verticalCenter
            }

            x: root.ws_button_size + ((monitor.activeWorkspace?.id - 1) * (root.ws_button_size + Config.options.bar.ws.spacing))

            color: Design.colors.primary
            border.color: Design.colors.on_surface
            border.width: 2
        }
    }
}
