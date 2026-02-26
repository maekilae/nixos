{
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      # 1. Define the local library package
      emphshell-lib = pkgs.stdenv.mkDerivation {
        pname = "emphshell";
        version = "0.1.0";
        src = ./libs/emphshell;

        nativeBuildInputs = [ pkgs.cmake ];
        # Add any library dependencies your CMake project needs here
        buildInputs = [ ];
      };

      qs-git = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      # 2. Add both to your packages output
      packages = {
        inherit emphshell-lib;

        quickshell = inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = qs-git;
          runtimeInputs = with pkgs; [
            libqalculate
            emphshell-lib # 3. Add your local lib to the runtime environment
          ];
          flags = {
            "-c" = toString ./.;
          };
        };
      };
    };
}
