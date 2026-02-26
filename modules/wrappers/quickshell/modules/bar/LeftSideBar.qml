import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs
import qs.config
import qs.widgets.buttons

M3IconButton {
    is_toggled: States.is_sidebar_left_open
    button_spec: Design.button.extra_small
    button_icon: "gemini"
    icon_color: Design.colors.primary
    is_square: false

    onClicked: {
        States.is_sidebar_left_open = !States.is_sidebar_left_open;
    }
}
