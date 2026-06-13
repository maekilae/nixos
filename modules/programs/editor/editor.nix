{ inputs, ... }:
{
  flake.modules.nixos.editor = {
    imports = with inputs.self.modules.nixos; [
      zed
      vscode
      nvim
    ];
  };
}
