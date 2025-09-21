{
  description = "My NixOS server configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      username = "acmota2";

      defaultModules = [
        ./.
        ./con
        ./nfs.nix
        ./sops
        ./user.nix
      ];

      defaultSpecialArgs = {
        inherit inputs username;
      };

      systemConfigs = {
        arr-stack = {
          modules = [
            ./arr-stack
            ./audiobooks
          ]
          ++ defaultModules;
        };

        images-stack = {
          modules = [ ./immich ];
        }
        ++ defaultModules;
      };
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: config:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = config.modules;
          specialArgs = {
            inherit hostname;
          }
          // defaultSpecialArgs;
        }
      ) systemConfigs;
    };
}
