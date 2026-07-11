{ self, ... }:
{
  flake.modules.nixos.cad =
    { pkgs, ... }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      # gdal 3.13.1 has a flaky pytest (`test_zarr_read_simple_sharding`)
      # that breaks its installCheckPhase on nixos-unstable, taking
      # vtk → freecad down with it. Skip its checks until upstream fixes.
      nixpkgs.overlays = [
        (_final: prev: {
          gdal = prev.gdal.overrideAttrs (_: { doInstallCheck = false; });
          gdalMinimal = prev.gdalMinimal.overrideAttrs (_: { doInstallCheck = false; });
        })
      ];

      environment.systemPackages = with pkgs; [
        # freecad
        # bambu-studio
      ];
    };
}
