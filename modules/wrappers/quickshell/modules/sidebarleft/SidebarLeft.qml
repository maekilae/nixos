import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs
import qs.config

Scope {
    id: root
    Loader {
        id: sidebar_loader
        sourceComponent: PanelWindow {
            id: sidebar_root
            readonly property int sidebar_width: Config.sidebar.width

            visible: States.is_sidebar_left_open

            exclusionMode: ExclusionMode.Auto
            exclusiveZone: sidebar_width
            implicitWidth: sidebar_width

            color: "transparent"

            anchors {
                top: true
                left: true
                bottom: true
            }

            Rectangle {
                id: sidebar_background
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: Config.wm.gaps_out
                    leftMargin: Config.wm.gaps_out
                    bottomMargin: Config.wm.gaps_out
                }

                radius: Design.corner.large
                width: sidebar_root.sidebar_width
                height: parent.height

                color: Design.colors.surface

                SidebarContent {}

                Behavior on width {
                    animation: Design.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }
    }
}
