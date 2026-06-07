{ inputs, ... }:
{
  flake.modules.nixos.theming = {
    imports = with inputs.self.modules.nixos; [
      gtk
      qt
      fonts
    ];
  };
}
