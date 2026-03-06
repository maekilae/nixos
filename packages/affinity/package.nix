{
  pkgs ? import <nixpkgs> { },
}:

let
  pname = "affinity";
  version = "3.0.2";

  src = pkgs.fetchurl {
    url = "https://github.com/ryzendew/Linux-Affinity-Installer/releases/download/${version}/Affinity-${version}-x86_64.AppImage";
    sha256 = "eb4d297d25ed7fe1b22710ed7d660848b32a2316f283a4d4166a41ee882a5d68";
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
