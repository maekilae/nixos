{
  pkgs ? import <nixpkgs> { },
}:

let
  pname = "wowup-cf";
  version = "2.22.1-beta.3";

  src = pkgs.fetchurl {
    url = "https://github.com/WowUp/WowUp.CF/releases/download/v${version}/WowUp-CF-${version}.AppImage";
    sha256 = "f37f82cb033f7e3bfef98a0a9b73f67ac6d75deab387c0723c7ec630fe665ebf";
  };

  appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
  appimageWrap = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs =
      pkgs: with pkgs; [
      ];
  };

  desktopItems = pkgs.runCommand "${pname}-desktop" { } ''
    mkdir -p $out/share/applications $out/share/icons

    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications

    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'

    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

in
pkgs.symlinkJoin {
  name = "${pname}";

  paths = [
    appimageWrap
    desktopItems
  ];
}
