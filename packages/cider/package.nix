{
  pkgs ? import <nixpkgs> { },
}:
let
  pname = "cider2";
  version = "3.1.8"; # Update this to match your actual version
  src = ./cider2.AppImage; # References the AppImage in the same directory
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
