pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

import qs.config

Item {
    id: root
    property int icon_size: Design.buttons.extra_small.icon_size
    property string color: ""
    property string source: ""
    property string iconFolder: Qt.resolvedUrl(Quickshell.shellPath("assets/icons"))  // The folder to check first
    width: icon_size
    height: icon_size

    IconImage {
        id: icon_image
        anchors.fill: parent
        source: {
            const fullPathWhenSourceIsIconName = root.iconFolder + "/" + root.source;
            if (root.iconFolder && fullPathWhenSourceIsIconName) {
                return fullPathWhenSourceIsIconName;
            }
            return root.source;
        }
        implicitSize: root.icon_size
    }

    Loader {
        active: root.color !== ""
        anchors.fill: icon_image
        sourceComponent: ColorOverlay {
            source: icon_image
            color: root.color
        }
    }
}
