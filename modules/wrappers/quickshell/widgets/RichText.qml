import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.config

Text {
    id: root

    property color text_color
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter

    font {
        family: Design.typescale.body.medium.font
        pointSize: Design.typescale.body.medium.size
        weight: Design.typescale.body.medium.weight
    }
    color: Design.colors.on_surface
}
