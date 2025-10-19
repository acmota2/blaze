{ pkgs, ... }:
{
  services.k3s = {
    role = "server";
    enable = true;
    extraFlags = toString [
      "--disable traefik"
      "--disable servicelb"
      "--disable local-storage"
    ];
  };

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 6443 ];
  };
}
