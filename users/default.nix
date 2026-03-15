{
  defaultUser,
  extraUsers ? { },
  pkgs,
  ...
}:
let
  lib = pkgs.lib;
  users = extraUsers // defaultUser;
in
{
  users = {
    groups.deploy = { };
    users = lib.mapAttrs (
      name:
      {
        description ? "Kubernetes user",
        isDeploy ? false,
      }:
      {
        inherit description;
        shell = pkgs.bash;
        isNormalUser = true;
        extraGroups = [
          "docker"
          "networkmanager"
          "podman"
          "wheel"
        ]
        ++ (if isDeploy then [ "deploy" ] else [ ]);
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB1Bu1KY2x3DGuvOGFhDh00BrXXddgatGno21uEtpOLu acmota2@EnderDragon"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJhL+Z4YaPU5hDtjjsl9HlKCUPekgGKMI3acWEGfffrp acmota2@Allay"
        ];
      }
    ) users;
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        groups = [ "deploy" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/journalctl";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
