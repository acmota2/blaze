{ ... }:
{
  imports = [ ./docker-compose.nix ];
  networking.firewall.allowedTCPPorts = [
    2283
  ];
}
