{
  flake.modules.nixos.vscode =
    {
      pkgs,
      ...
    }:
    {
      programs.nix-ld.enable = true;
      environment.systemPackages = with pkgs; [
        nixd
        nil
        alejandra
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            jnoortheen.nix-ide
            ms-python.python
            ms-azuretools.vscode-docker
            ms-vscode-remote.remote-ssh

            anthropic.claude-code
          ];
        })
      ];

    };
}
