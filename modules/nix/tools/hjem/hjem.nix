{
  inputs,
  ...
}:
{
  # Declarative home / dotfile management — this repo's replacement for Home
  # Manager. Provides the `hjem.users.<name>` option (files, packages,
  # environment.sessionVariables). Home dir + user are derived from
  # `users.users.<name>`. https://github.com/feel-co/hjem
  flake.modules.darwin.hjem.imports = [ inputs.hjem.darwinModules.default ];
  flake.modules.nixos.hjem.imports = [ inputs.hjem.nixosModules.default ];
}
