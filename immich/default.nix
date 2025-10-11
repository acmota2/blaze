{ username, ... }:
_: {
  imports = [ ./docker-compose.nix ];
  networking.firewall.allowedTCPPorts = [
    2283
  ];
  sops = {
    secrets.immich-settings = {
      format = "dotenv";
      owner = "${username}";
      sopsFile = ../immich/immich.env;
    };
  };
}
