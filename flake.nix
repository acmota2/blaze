{
  description = "My NixOS server configuration";

  inputs = {
    disko.url = "github:nix-community/disko";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      disko,
      nixpkgs,
      sops-nix,
      ...
    }@inputs:
    let
      username = "acmota2";

      defaultModules = [
        ./.
        ./con
        ./disko
        ./sops
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
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
          specialArgs = defaultSpecialArgs;
        };
        images-stack = {
          modules = [
            ./immich
          ]
          ++ defaultModules;
          specialArgs = defaultSpecialArgs;
        };
        k3s-control = {
          modules = [
            { system.stateVersion = "25.05"; }
            ./boot
            ./disko
            ./k3s/control-plane.nix
            ./machine
            ./sops
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
          ];
          specialArgs = {
            username = "root";
          };
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
            // config.specialArgs
            // {
              inherit hostname;
            };
        }
      ) systemConfigs;
    };
}
