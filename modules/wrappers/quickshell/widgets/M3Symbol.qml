import QtQuick
import qs.config

RichText {
    id: root
    property int icon_size: Design?.typescale.body.medium.size
    property int icon_weight: Design?.typescale.body.medium.weight
    property int fill: 0
    property real truncatedFill: fill.toFixed(1) // Reduce memory consumption spikes from constant font remapping
    renderType: Text.NativeRendering
    font {
        hintingPreference: Font.PreferNoHinting
        family: Design?.typeface.icon_material ?? "Material Symbols Rounded"
        pointSize: root.icon_size
        weight: root.icon_weight ?? Font.Normal + (Font.DemiBold - Font.Normal) * truncatedFill
        variableAxes: {
            "FILL": truncatedFill,
            // "wght": font.weight,
            // "GRAD": 0,
            "opsz": icon_size
        }
    }
    color: Design.colors.on_surface

    Behavior on fill {
        // Leaky leaky, no good
        NumberAnimation {
            duration: Design?.animation.element_move_fast.duration ?? 200
            easing.type: Design?.animation.element_move_fast.type ?? Easing.BezierSpline
            easing.bezierCurve: Design?.animation.element_move_fast.bezierCurve ?? [0.34, 0.80, 0.34, 1.00, 1, 1]
        }
    }
}
