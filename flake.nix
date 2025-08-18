{
  description = "My NixOS server configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        "arr-stack" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./.
            ./arr-stack
            ./audiobooks
            ./con
            ./nfs.nix
          ];
          specialArgs = {
            inherit inputs;
            username = "acmota2";
            hostname = "arr-stack";
          };
        };
      };
    };
}
