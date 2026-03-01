{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib)
    getExe
    ;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages.hyprland =
        (inputs.wrappers.wrapperModules.hyprland.apply {
          inherit pkgs;
          package = lib.mkForce inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          "hypr.conf".content = # Hypr
            ''
              # Hyprland configuration file
              $terminal = wezterm
              $fileManager = dolphin

              exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --type text --watch cliphist store
              exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store
              # exec-once = hypridle
              exec-once = ${
                (builtins.toString (getExe self.packages.${pkgs.stdenv.hostPlatform.system}.quickshell))
              }
              exec-once = ${inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww}/bin/awww-daemon

              monitor=,3840x2160@240,auto,1


              # See https://wiki.hyprland.org/Configuring/Permissions/
              # ecosystem {
              #   enforce_permissions = 1
              # }

              # permission = /usr/(bin|local/bin)/grim, screencopy, allow
              # permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow
              # permission = /usr/(bin|local/bin)/hyprpm, plugin, allow

              # https://wiki.hyprland.org/Configuring/Variables/#input
              input {
                  kb_layout = us
                  kb_variant =
                  kb_model =
                  kb_options =
                  kb_rules =

                  follow_mouse = 1

                  sensitivity = -0.8 # -1.0 - 1.0, 0 means no modification.

                  kb_options = caps:super

                  touchpad {
                      natural_scroll = false
                  }
              }

              # See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more

              misc {
                  force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
                  disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
                  vrr = 3
              }
              general {
                  gaps_in = 5
                  gaps_out = 10

                  border_size = 2

                  col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
                  col.inactive_border = rgba(595959aa)
                  resize_on_border = false
                  layout = dwindle
              }

              decoration {
                  rounding = 10
                  rounding_power = 2

                  active_opacity = 1.0
                  inactive_opacity = 1.0

                  shadow {
                      enabled = true
                      range = 4
                      render_power = 3
                      color = rgba(1a1a1aee)
                  }

                  blur {
                      enabled = true
                      size = 3
                      passes = 1

                  }
                #screen_shader = shader/vibrance.frag
              }

              # https://wiki.hyprland.org/Configuring/Variables/#animations
              animations {
                  enabled = true, please :)

                  bezier = easeOutQuint,0.23,1,0.32,1
                  bezier = easeInOutCubic,0.65,0.05,0.36,1
                  bezier = linear,0,0,1,1
                  bezier = almostLinear,0.5,0.5,0.75,1.0
                  bezier = quick,0.15,0,0.1,1

                  animation = global, 1, 10, default
                  animation = border, 1, 5.39, easeOutQuint
                  animation = windows, 1, 4.79, easeOutQuint
                  animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
                  animation = windowsOut, 1, 1.49, linear, popin 87%
                  animation = fadeIn, 1, 1.73, quick
                  animation = fadeOut, 1, 1.46, quick
                  animation = fade, 1, 3.03, quick
                  animation = layers, 1, 3.81, easeOutQuint
                  animation = layersIn, 1, 4, easeOutQuint, fade
                  animation = layersOut, 1, 1.5, linear, fade
                  animation = fadeLayersIn, 1, 1.79, quick
                  animation = fadeLayersOut, 1, 1.39, quick
                  animation = workspaces, 1, 1.94, quick, fade
                  #animation = workspacesIn, 1, 1.21, quick, fade
                  #animation = workspacesOut, 1, 1.94, quick, fade
              }
              dwindle {
                  pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
                  preserve_split = true # You probably want this
              }

              master {
                  new_status = master
              }

              $mainMod = SUPER # Sets "Windows" key as main modifier

              # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
              bind = $mainMod, Q, exec, ${getExe self.packages."${pkgs.stdenv.hostPlatform.system}".wezterm}
              bind = $mainMod, E, exec, $fileManager
              bind = $mainMod, B, exec, ${
                getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
              }
              bind = $mainMod, space, exec, ${
                getExe self.packages.${pkgs.stdenv.hostPlatform.system}.quickshell
              } ipc call runner toggle
              bind = $mainMod, S, exec, ${getExe pkgs.grim} -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy
              bind = $mainMod, S, exec, ${
                getExe (
                  pkgs.writeShellApplication {
                    name = "screenshot";
                    text = ''
                      ${getExe pkgs.grim} -g "$(${getExe pkgs.slurp} -w 0)" - \
                      | ${pkgs.wl-clipboard}/bin/wl-copy
                    '';
                  }
                )
              }
              bind = $mainMod, C, killactive,
              # bind = $mainMod, M, exit,
              bind = $mainMod, V, togglefloating,
              bind = $mainMod SHIFT, V, fullscreen, 0
              bind = $mainMod SHIFT, V, centerwindow
              bind = $mainMod, P, pseudo, # dwindle
              bind = $mainMod, J, togglesplit, # dwindle
              bind = $mainMod, R,  exec, qs -n

              # Move focus with mainMod + arrow keys
              bind = $mainMod, left, movefocus, l
              bind = $mainMod, right, movefocus, r
              bind = $mainMod, up, movefocus, u
              bind = $mainMod, down, movefocus, d

              # Switch workspaces with mainMod + [0-9]
              bind = $mainMod, 1, workspace, 1
              bind = $mainMod, 2, workspace, 2
              bind = $mainMod, 3, workspace, 3
              bind = $mainMod, 4, workspace, 4
              bind = $mainMod, 5, workspace, 5
              bind = $mainMod, 6, workspace, 6
              bind = $mainMod, 7, workspace, 7
              bind = $mainMod, 8, workspace, 8
              bind = $mainMod, 9, workspace, 9
              bind = $mainMod, 0, workspace, 10

              # Move active window to a workspace with mainMod + SHIFT + [0-9]
              bind = $mainMod SHIFT, 1, movetoworkspace, 1
              bind = $mainMod SHIFT, 2, movetoworkspace, 2
              bind = $mainMod SHIFT, 3, movetoworkspace, 3
              bind = $mainMod SHIFT, 4, movetoworkspace, 4
              bind = $mainMod SHIFT, 5, movetoworkspace, 5
              bind = $mainMod SHIFT, 6, movetoworkspace, 6
              bind = $mainMod SHIFT, 7, movetoworkspace, 7
              bind = $mainMod SHIFT, 8, movetoworkspace, 8
              bind = $mainMod SHIFT, 9, movetoworkspace, 9
              bind = $mainMod SHIFT, 0, movetoworkspace, 10

              # Example special workspace (scratchpad)
              bind = $mainMod, S, togglespecialworkspace, magic
              bind = $mainMod SHIFT, S, movetoworkspace, special:magic

              # Scroll through existing workspaces with mainMod + scroll
              bind = $mainMod, mouse_down, workspace, e+1
              bind = $mainMod, mouse_up, workspace, e-1

              # Move/resize windows with mainMod + LMB/RMB and dragging
              bindm = $mainMod, mouse:272, movewindow
              bindm = $mainMod, mouse:273, resizewindow

              # # Laptop multimedia keys for volume and LCD brightness
              # bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
              # bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
              # bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
              # bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
              # bindel = ,XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+
              # bindel = ,XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-

              # # Requires playerctl
              # bindl = , XF86AudioNext, exec, playerctl next
              # bindl = , XF86AudioPause, exec, playerctl play-pause
              # bindl = , XF86AudioPlay, exec, playerctl play-pause
              # bindl = , XF86AudioPrev, exec, playerctl previous
            '';

        }).wrapper;
    };
}
