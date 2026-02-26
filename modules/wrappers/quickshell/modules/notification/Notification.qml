import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import EmphShell

import qs
import qs.config
import qs.widgets
import qs.widgets.cards

Scope {
    id: root
    Variants {
        id: notifVariants
        model: Quickshell.screens
        PanelWindow {
            id: notifWindow
            required property var modelData
            visible: false
            WlrLayershell.namespace: "emphshell:notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            //WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            color: "Transparent"

            anchors {
                top: true
                right: true
            }

            implicitWidth: rowLayout.implicitWidth + Config.wm.gaps_out
            implicitHeight: rowLayout.implicitHeight + Config.wm.gaps_out

            RowLayout {
                id: rowLayout
                anchors {
                    fill: parent
                    topMargin: Config.wm.gaps_out
                    rightMargin: Config.wm.gaps_out
                }
                spacing: 10

                M3Card {
                    id: notificationRectangle
                    anchors.fill: parent
                    implicitWidth: 300
                    implicitHeight: 100
                }
            }
        }
    }
}
