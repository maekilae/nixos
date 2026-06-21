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
            ms-azuretools.vscode-docker
            ms-vscode-remote.remote-ssh

            anthropic.claude-code

            vscodevim.vim
            pkief.material-icon-theme
            github.github-vscode-theme

            ms-vscode.cpptools
            jnoortheen.nix-ide
            ms-python.python
            golang.go
	tboby.cwtools-vscode
          ];
        })
      ];

    };
}
