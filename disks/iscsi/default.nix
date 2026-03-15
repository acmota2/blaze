{ hostname, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    openiscsi
  ];

  services.openiscsi = {
    enable = true;
    name = "iqn.2025-10.xyz.voldemota:${hostname}";
  };

  # longhorn patch
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin - - - - /run/current-system/sw/bin"
  ];
}
