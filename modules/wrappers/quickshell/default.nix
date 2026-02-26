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
        version = "1.0";
        src = ./lib/emphshell;

        nativeBuildInputs = [
          pkgs.cmake
          pkgs.ninja
          pkgs.qt6.wrapQtAppsHook
          pkgs.pkg-config
        ];
        buildInputs = [
          pkgs.qt6.qtbase
          pkgs.qt6.qtdeclarative
          pkgs.libqalculate
          pkgs.pipewire
        ];
        preConfigure = ''
          export CXXFLAGS="-fvisibility=default -fPIC"
          export LDFLAGS="-Wl,--export-dynamic -Wl,--no-as-needed"
        '';
        cmakeFlags = [
          "-DCMAKE_INSTALL_RPATH=\$ORIGIN"
          "-DCMAKE_SKIP_RPATH=OFF"
          "-DCMAKE_BUILD_TYPE=Release"
        ];
      };
      shellUiDeps = with pkgs.qt6; [
        qt5compat
        qtsvg
        qtdeclarative
        qtpositioning
      ];

      systemQmlPaths = pkgs.lib.makeSearchPath pkgs.qt6.qtbase.qtQmlPrefix shellUiDeps;

      qs-git = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      # 2. Add both to your packages output
      packages = {
        inherit emphshell-lib;

        quickshell = inputs.wrappers.lib.wrapPackage {
          inherit pkgs;
          package = qs-git;

          runtimeInputs = [
            pkgs.libqalculate
            emphshell-lib
          ]
          ++ shellUiDeps;

          env = {
            QML_IMPORT_PATH = "${emphshell-lib}/lib/qt6/qml:${systemQmlPaths}";
            LD_LIBRARY_PATH = "${emphshell-lib}/lib/qt6/qml/EmphShell:${emphshell-lib}/lib";
          };
          flags = {
            "-c" = toString ./.;
          };
        };
      };
    };
}
