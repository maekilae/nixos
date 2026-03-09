{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  libxcb,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libgbm,
  cairo,
  libxkbcommon,
  nspr,
  nss,
  libcupsfilters,
  pango,
  alsa-lib,
  atk,
  at-spi2-core,
  at-spi2-atk,
  mesa,
  gtk3,
  libdrm,
  systemd,
  libglvnd,
  gsettings-desktop-schemas,
  glib,
  widevine-cdm, # Added Widevine input
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
    makeWrapper
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
  ];

  runtimeDependencies = [ systemd ];

  buildInputs = [
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
    libxkbcommon
    nspr
    nss
    libcupsfilters
    alsa-lib
    atk
    at-spi2-core
    at-spi2-atk
    gsettings-desktop-schemas
    glib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/helium
    cp -r . $out/opt/helium/

    # --- UBLOCK ERROR FIX ---
    mkdir -p $out/opt/helium/resources/ublock
    echo "{}" > $out/opt/helium/resources/ublock/managed_storage.json

    # --- WIDEVINE DRM FIX ---
    # Symlink the entire Widevine folder directly next to the helium executable.
    # Chromium natively looks here if command-line flags are ignored.
    ln -s ${widevine-cdm}/share/google/chrome/WidevineCdm $out/opt/helium/WidevineCdm

    mkdir -p $out/bin
    makeWrapper $out/opt/helium/helium $out/bin/helium \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libxkbcommon
          mesa
          gtk3
          libdrm
          libgbm
          libglvnd
        ]
      }" \
      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}" \
      --add-flags "--enable-features=UseOzonePlatform" \
      --add-flags "--ozone-platform=wayland" \
      --add-flags "--user-agent=\"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36\"" \
      --set CHROME_VERSION_EXTRA "nixos"

    mkdir -p $out/share/applications
    substitute $out/opt/helium/helium.desktop $out/share/applications/helium.desktop \
      --replace-fail "Exec=helium" "Exec=$out/bin/helium"

    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp $out/opt/helium/product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/imputnet/helium-linux";
    description = "The Chromium-based web browser made for people, with love.";
    platforms = platforms.linux;
  };
}
