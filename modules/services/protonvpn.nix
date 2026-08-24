{
  # The GUI drives NetworkManager rather than its own daemon, so it needs
  # `networking.networkmanager.enable` (set per host) and a running Secret
  # Service to keep the account credentials - gnome-keyring under COSMIC,
  # kwallet under the Hyprland session.
  flake.modules.nixos.protonvpn =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        proton-vpn
      ];
    };
}
