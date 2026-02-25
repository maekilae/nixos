{
  pkgs ? import <nixpkgs> { },
}:

let
  pname = "wowup-cf";
  version = "2.22.0";

  # 1. Download the AppImage
  src = pkgs.fetchurl {
    url = "https://github.com/WowUp/WowUp.CF/releases/download/v2.22.0/WowUp-CF-2.22.0.AppImage";
    sha256 = "5f98039e3e18059441c0911e6fcb1530da06996508f6255d58e9ac036d1b5a28";
  };

  # 2. Extract the AppImage contents to grab the desktop file and icons
  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };

  # 3. Create the wrapped binary derivation
  appimageWrap = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    # Optional: Add required dependencies that the AppImage might be missing
    extraPkgs =
      pkgs: with pkgs; [
        # e.g., libsecret, xorg.libxkbfile
      ];
  };

  # 4. Create a separate derivation just for the desktop integration
  desktopItems = pkgs.runCommand "${pname}-desktop" { } ''
    mkdir -p $out/share/applications $out/share/icons

    # Install the desktop file
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications

    # Modify the desktop file to point to the newly created wrapper binary
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    # Copy icons (adjust the source path based on how the AppImage organizes icons internally)
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

in
# 5. Join the binary and the desktop items into a single final package
pkgs.symlinkJoin {
  name = "${pname}";

  paths = [
    appimageWrap
    desktopItems
  ];
}
