{
  lib,
  unzip,
  autoPatchelfHook,
  stdenv,
  fetchurl,
  libxcb,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libgbm,
  cairo,
  libudev-zero,
  libxkbcommon,
  nspr,
  nss,
  libcupsfilters,
  pango,
  qt5,
  alsa-lib,
  atk,
  at-spi2-core,
  at-spi2-atk,
}:

stdenv.mkDerivation rec {
  pname = "helium";
  version = "0.9.4.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
    sha256 = "a97b8352d6a7938e8ef3b8c04b1733995324d220f825a662da3f4b4817bd5423";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  runtimeDependencies = [ ];
  buildInputs = [
    unzip
    libxcb
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libgbm
    cairo
    pango
    libudev-zero
    libxkbcommon
    nspr
    nss
    libcupsfilters
    alsa-lib
    atk
    at-spi2-core
    at-spi2-atk
    qt5.qtbase
    qt5.qttools
    qt5.qtx11extras
    qt5.wrapQtAppsHook
  ];
  installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          mv * $out/bin/

          # -----  fix broken symlinks  -----
          # 1. delete every symlink that is now dangling
          find $out/bin -xtype l -delete

          # ln -sfn $out/bin/libfoo.so.2 $out/bin/libfoo.so)

          # -----

          mkdir -p $out/share/applications

          cat <<INI> $out/share/applications/${pname}.desktop
    [Desktop Entry]
    Name=${pname}
    GenericName=Web Browser
    Terminal=false
    Icon=$out/bin/product_logo_256.png
    Exec=$out/bin/${pname}
    Type=Application
    Categories=Network;WebBrowser;
    INI
  '';

  meta = with lib; {
    homepage = "https://github.com/imputnet/helium-linux";
    description = "The Chromium-based web browser made for people, with love.
    Best privacy by default, unbiased ad-blocking, no bloat and no noise. ";
    platforms = platforms.linux;
  };
}
