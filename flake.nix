{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Only used for individual packages where the 26.05 branch lags
    # (currently: sesh — ctrl+p/ctrl+n picker navigation needs ≥2.32).
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    pi.url = "github:earendil-works/pi/stable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, pi, ... }: {
    nixosConfigurations.t480 = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        ./nix/hosts/t480/configuration.nix
      ];
      specialArgs = { inherit pi nixpkgs-unstable; };
    };
  };
}
