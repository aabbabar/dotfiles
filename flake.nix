{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    pi.url = "github:earendil-works/pi/stable";
  };

  outputs = { nixpkgs, pi, ... }: {
    nixosConfigurations.t480 = nixpkgs.lib.nixosSystem {
      modules = [
        { nixpkgs.hostPlatform = "x86_64-linux"; }
        ./nix/hosts/t480/configuration.nix
      ];
      specialArgs = { inherit pi; };
    };
  };
}
