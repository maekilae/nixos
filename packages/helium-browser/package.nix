{
  pkgs ? import <nixpkgs> { },
}:

let
  pname = "helium-browser";
  version = "0.9.4.1";

  src = pkgs.fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64.AppImage";
    sha256 = "37981d5aec4eac8b9d271ff89d8a38fd2292c5a9294c5bcbe33cc1cafe829ee8";
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
