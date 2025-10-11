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
      username = "acmota2";

      podmanMachineModules = [
        ./nfs.nix
        ./user.nix
        ./virtualization
      ];

      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      baseSystemConfigs = {
        arr-stack = {
          specificModules = [
            ./arr-stack
            ./audiobooks
          ]
          ++ podmanMachineModules;
          tags = [ "podman" ];
          targetHost = "arr.voldemota.xyz";
          targetUser = username;
        };
        images-stack = {
          specificModules = [
            ./immich
          ]
          ++ podmanMachineModules;
          tags = [ "podman" ];
          targetHost = "192.168.1.10";
          targetUser = username;
        };
        k3s-control = {
          specificModules = [
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

      lib = nixpkgs.lib;

      systemConfigs = nixpkgs.lib.mapAttrs (
        hostname: config:
        let
          username = config.targetUser;
          resolvedMod =
            path: args:
            let
              resolvedPath = if lib.filesystem.isDir path then path + "default.nix" else path;
              importedModule = import resolvedPath;
              needsCapture =
                lib.isFunction importedModule
                && (lib.any (arg: lib.hasAttr arg (lib.functionArgs importedModule)) [
                  "username"
                  "hostname"
                ]);
            in
            if needsCapture then (importedModule args) else importedModule;
        in
        {
          inherit (config)
            targetUser
            targetHost
            tags
            ;
          imports = lib.map (
            (
              mod:
              resolvedMod mod {
                inherit username hostname;
              }
            )
              (config.specificModules ++ [ ./. ])
          );
          targetPort = 22;
          specialArgs = inputs;
        }
      ) baseSystemConfigs;
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
        // systemConfigs
      );

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          colmena.packages.${system}.colmena
          nixos-anywhere.packages.${system}.default
        ];
      };

      nixosConfigurations = lib.mapAttrs (
        hostname: config:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = config.specificModules ++ [ ./. ];
          specialArgs = inputs // {
            inherit hostname;
            username = config.targetUser;
          };
        }
      ) baseSystemConfigs;
    };
}
