{
  pkgs ? import <nixpkgs> { },
}:

let
  pname = "Affinity";
  version = "3.2.0";

  src = pkgs.fetchurl {
    url = "https://github.com/ryzendew/Linux-Affinity-Installer/releases/download/${version}/Affinity-${version}-x86_64.AppImage";
    sha256 = "32ac7f35834dad83cfa0b426571dea356be92f19f2b01eebd3139583395d516a";
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
