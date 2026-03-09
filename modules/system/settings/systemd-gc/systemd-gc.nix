{
  flake.modules.nixos.systemd-gc =
    { pkgs, ... }:
    {
      systemd.services.nixos-count-based-gc = {
        description = "Keep last 5 NixOS generations and garbage collect";
        script = ''
          # Keep last 5 system generations
          ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +5

          # Run the garbage collector to free up the space
          ${pkgs.nix}/bin/nix-collect-garbage
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };

      systemd.timers.nixos-count-based-gc = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          # Runs weekly. You can change this to "daily", etc.
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };
}
