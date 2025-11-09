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
      nixos-anywhere,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      systemConfigs = {
        k3s-control = {
          specificModules = [
            ./iscsi
            ./k3s/control-plane.nix
            ./machine/k3s-control.nix
            ./nfs/default.nix
          ];
          specialArgs = {
            username = "root";
          };
          tags = [ "k8s" ];
          targetHost = "k3s-control.voldemota.xyz";
          targetUser = "root";
          specialArgs = {
            address = "k3s-control.voldemota.xyz";
            keyFilePath = "/root/keys.txt";
          };
        };
      };

      mkSystem = format: lib.mapAttrs format systemConfigs;
      lib = nixpkgs.lib;
    in
    {
      colmenaHive = colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = import nixpkgs {
              inherit system;
            };
            specialArgs = inputs;
            nodeSpecialArgs = mkSystem (
              hostname: config:
              {
                inherit hostname;
                username = config.targetUser;
              }
              // config.specialArgs
            );
          };
        }
        // mkSystem (
          hostname: config: {
            imports = config.specificModules ++ [ ./. ];
            deployment = {
              inherit (config)
                tags
                targetUser
                targetHost
                ;
            };
          }
        )
      );

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.sops
          colmena.packages.${system}.colmena
          nixos-anywhere.packages.${system}.default
        ];
      };

      nixosConfigurations = mkSystem (
        hostname: config:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = config.specificModules ++ [ ./. ];
          specialArgs = {
            inherit hostname;
            username = config.targetUser;
          }
          // inputs;
        }
      );
    };
}
