{
  pkgs ? import <nixpkgs> { },
}:

let
  pname = "wowup-cf";
  version = "2.22.0";

  # 1. Download the AppImage
  src = pkgs.fetchurl {
    url = "https://github.com/WowUp/WowUp.CF/releases/download/v2.22.0/WowUp-CF-2.22.0.AppImage";
    # Tip: Leave this blank (sha256 = lib.fakeSha256;), run the build,
    # and Nix will error out and tell you the correct hash to paste here.
    sha256 = "5f98039e3e18059441c0911e6fcb1530da06996508f6255d58e9ac036d1b5a28";
  };

  # 2. Extract the AppImage contents to grab the desktop file and icons
  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };

in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  # 3. Optional: Add required dependencies that the AppImage might be missing
  extraPkgs =
    pkgs: with pkgs; [
      # e.g., libsecret, xorg.libxkbfile
    ];

  # 4. Install desktop integration (Icons and .desktop file)
  extraInstallCommands = ''
    # Install the desktop file
    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications

    # Modify the desktop file to point to the newly created wrapper binary
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    # Copy icons (adjust the source path based on how the AppImage organizes icons internally)
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';
}
