import QtQuick
import Quickshell.Io
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs
import qs.config
import qs.widgets
import qs.widgets.cards

Control {
    anchors.fill: parent
    padding: 16

    contentItem: RowLayout {
        M3Card {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            color: Design.colors.surface_container_low
            contentItem: RichText {
                text: "Sidebar Content"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
