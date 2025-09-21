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
    { nixpkgs, sops-nix, ... }@inputs:
    let
      username = "acmota2";

      defaultModules = [
        ./.
        ./con
        ./sops
        sops-nix.nixosModules.sops
      ];

      defaultSpecialArgs = {
        inherit username;
      };

      system = "x86_64-linux";
      systemConfigs = {
        arr-stack = {
          modules = [
            ./arr-stack
            ./audiobooks
          ]
          ++ defaultModules;
        };

        images-stack = {
          modules = [ ./immich ] ++ defaultModules;
        };
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: config:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = config.modules;
          specialArgs =
            inputs
            // defaultSpecialArgs
            // {
              inherit hostname;
            };
        }
      ) systemConfigs;
    };
}
