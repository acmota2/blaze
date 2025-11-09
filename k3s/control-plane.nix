{ address, ... }:
{
  services.k3s = {
    role = "server";
    enable = true;
    extraFlags = [
      "--bind-address 0.0.0.0"
      "--disable traefik"
      "--disable servicelb"
      "--disable local-storage"
      "--tls-san=${address}"
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 6443 ];
  };

  systemd = {
    network.wait-online.enable = true;

    services.k3s = {
      after = [
        "network-online.target"
        "local-fs.target"
      ];
      wants = [
        "network-online.target"
      ];
      serviceConfig = {
        TimeoutStopSec = "2min";
        KillSignal = "SIGTERM";
        ExecStartPre = "/run/current-system/sw/bin/sleep 10";
      };
    };
  };
}
