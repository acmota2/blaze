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
      defaultMeta = {
        keyFilePath = "/home/${username}/.config/sops/age/keys.txt";
      };
      username = "acmota2";

      podmanMachineModules = [
        ./nfs/mounts.nix
        ./user.nix
        ./virtualization
      ];

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      systemConfigs = {
        arr-stack = {
          specificModules = [
            ./arr-stack
            ./audiobooks
            ./machine/arr-stack.nix
          ]
          ++ podmanMachineModules;
          tags = [ "podman" ];
          targetHost = "arr.voldemota.xyz";
          targetUser = username;
          specialArgs = defaultMeta;
        };
        images-stack = {
          specificModules = [
            ./immich
            ./machine/images-stack.nix
          ]
          ++ podmanMachineModules;
          tags = [ "podman" ];
          targetHost = "192.168.1.10";
          targetUser = username;
          specialArgs = defaultMeta;
        };
        k3s-control = {
          specificModules = [
            ./iscsi
            ./k3s/control-plane.nix
            ./machine/k3s-control.nix
          ];
          specialArgs = {
            username = "root";
          };
          tags = [ "k8s" ];
          targetHost = "192.168.1.11";
          targetUser = "root";
          specialArgs = {
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
