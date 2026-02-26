import QtQuick
import qs.services
import qs.widgets.buttons
import qs.config

M3Button {
    //THIS IS THE FUTURE\\
    button_spec: Design.button.extra_small
    // hover_color: Design.colors.primary
    button_text: Time.time
    text_color: Design.colors.on_surface

    button_symbol: Icons.get_weather_icon(Weather.data.wCode) ?? "cloud"
    // icon_color: Design.colors.primary
    // hover_icon_color: Design.colors.surface
    icon_fill: 0
}
