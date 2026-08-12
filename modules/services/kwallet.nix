{
  flake.modules.nixos.kwallet =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs.kdePackages; [
        kwallet
        kwallet-pam
        kwalletmanager
      ];

      # Auto-unlock KWallet on login. Extend to other PAM services (greetd,
      # sddm, gdm, sudo, …) as needed for the host's display/login manager.
      security.pam.services.login.kwallet.enable = true;

      security.pam.services.sddm.kwallet.enable = true; # SDDM
      security.pam.services.hyprlock.kwallet.enable = true; # if using hyprlock to unlock on relogin
    };
}
