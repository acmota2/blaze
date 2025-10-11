{
  description = "My NixOS server configuration";

  inputs = {
    colmena = {
      url = "github:zhaofengli/colmena/main";
      inputs.nixpkgs.follows = "unstable";
    };
    disko.url = "github:nix-community/disko";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      colmena,
      disko,
      nixos-anywhere,
      nixpkgs,
      sops-nix,
      ...
    }@inputs:
    let
      username = "acmota2";

      podmanMachineModules = [
        ./nfs.nix
        ./user.nix
        ./virtualization
      ];

      defaultSpecialArgs = {
        inherit username;
      };

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      systemConfigs = {
        arr-stack = {
          modules = [
            ./.
            ./arr-stack
            ./audiobooks
          ]
          ++ podmanMachineModules;
          specialArgs = defaultSpecialArgs;
          tags = [ "podman" ];
          targetHost = "arr.voldemota.xyz";
          targetUser = username;
        };
        images-stack = {
          modules = [
            ./.
            ./immich
          ]
          ++ podmanMachineModules;
          specialArgs = defaultSpecialArgs;
          tags = [ "podman" ];
          targetHost = "192.168.1.10";
          targetUser = username;
        };
        k3s-control = {
          modules = [
            ./.
            ./k3s/control-plane.nix
          ];
          specialArgs = {
            username = "root";
          };
          tags = [ "k8s" ];
          targetHost = "192.168.1.11";
          targetUser = "root";
        };
      };
    in
    {
      colmenaHive = colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs {
              inherit system;
            };
          };
        }
        // nixpkgs.lib.mapAttrs (hostname: config: {
          imports = config.modules;
          specialArgs = inputs // config.specialArgs // { inherit hostname; };
          deployment = {
            inherit (config) targetHost targetUser tags;
            targetPort = 22;
          };
        }) systemConfigs
      );

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          colmena.packages.${system}.colmena
          nixos-anywhere.packages.${system}.default
        ];
      };

      nixosConfigurations = nixpkgs.lib.mapAttrs (
        hostname: config:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = config.modules;
          specialArgs = inputs // config.specialArgs // { inherit hostname; };
        }
      ) systemConfigs;
    };
}
