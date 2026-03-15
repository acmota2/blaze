{
  description = "NixOS VM server configuration";

  inputs = {
    colmena = {
      url = "github:zhaofengli/colmena/main";
      inputs.nixpkgs.follows = "unstable";
    };
    disko.url = "github:nix-community/disko";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
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

      defaultUsername = "k8s";
      defaultUser = {
        ${defaultUsername} = { };
      };

      systemConfigs = {
        k3s-control = {
          specificModules = [
            ./disks/disko/k3s-control.nix
            ./disks/iscsi
            ./disks/nfs
            ./k3s/control-plane.nix
            ./machine/k3s-control.nix
            ./users
          ];
          tags = [ "k8s" ];
          specialArgs = {
            inherit defaultUser;
            hostAddress = "k3s-control.voldemota.xyz";
            extraUsers = {
              deploy = {
                description = "Deploy user";
                isDeploy = true;
              };
            };
          };
        };

        net-control = {
          specificModules = [
            ./disks/disko
            ./machine/net-control.nix
            ./users
          ];
          specialArgs = {
            defaultUser = {
              net = { };
            };
            hostAddress = "192.168.1.191";
            extraUsers = {
              deploy = {
                description = "Deploy user";
                isDeploy = true;
              };
            };
          };
        };
      };

      mkSystem = format: lib.mapAttrs format systemConfigs;
      lib = nixpkgs.lib;
    in
    {
      # Colmena
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
              }
              // config.specialArgs
            );
          };
        }
        // mkSystem (
          hostname: config: {
            imports = config.specificModules ++ [ ./. ];
            deployment = {
              targetUser = "deploy";
              targetHost = config.specialArgs.hostAddress;
              buildOnTarget = true;
              privilegeEscalationCommand = [
                "sudo"
                "-H"
                "--"
              ];
            };
          }
        )
      );

      # Shell
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          colmena.packages.${system}.colmena
          just
          nixos-anywhere.packages.${system}.default
          openssl
          ssh-to-age
          sops
        ];
      };

      # NixOS
      nixosConfigurations = mkSystem (
        hostname: config:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = config.specificModules ++ [ ./. ];
          specialArgs = {
            inherit hostname;
          }
          // inputs
          // config.specialArgs;
        }
      );
    };
}
