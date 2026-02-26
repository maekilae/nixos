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
        src = ./lib/emphshell;

        nativeBuildInputs = [
          pkgs.cmake
          pkgs.qt6.wrapQtAppsHook
          pkgs.pkg-config
        ];
        buildInputs = [
          pkgs.qt6.qtbase
          pkgs.qt6.qtdeclarative
          pkgs.libqalculate
          pkgs.pipewire
        ];

        CXXFLAGS = "-I${pkgs.qt6.qtbase}/include";
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
            emphshell-lib # 3. Add your local lib to the runtime environment
          ];
          env = {
            # This tells the QML engine to look inside your built library's folder
            QML_IMPORT_PATH = "${emphshell-lib}/lib/qt-6/qml";

            # This ensures the underlying .so plugin can be loaded by the system
            LD_LIBRARY_PATH = "${emphshell-lib}/lib/qt-6/qml/EmphShell";
          };
          flags = {
            "-c" = toString ./.;
          };
        };
      };
    };
}
