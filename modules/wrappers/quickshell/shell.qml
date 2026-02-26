import qs.config
import qs.modules.runner
import qs.modules.bar
import qs.modules.sidebarleft
import qs.modules.notification
import qs.modules

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services

import qs.utils

ShellRoot {
    id: root

    Component.onCompleted: {
        // Set organization properties for QSettings first, before any other initialization
        Qt.application.organizationName = "Quickshell";
        Qt.application.organizationDomain = "quickshell.org";
        Qt.application.applicationName = "Quickshell";
        ThemeLoader.reapplyTheme();
    }
    //ReloadPopup {}

    ModuleLoader {
        condition: true
        component: Runner {}
    }
    ModuleLoader {
        condition: true
        component: Bar {}
    }
    ModuleLoader {
        condition: true
        component: SidebarLeft {}
    }
    ModuleLoader {
        condition: true
        component: Notification {}
    }

    component ModuleLoader: LazyLoader {
        required property bool condition
        active: Config.ready && condition
    }
}
