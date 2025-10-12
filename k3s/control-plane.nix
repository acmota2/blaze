{ pkgs, ... }:
{
  services.k3s = {
    role = "server";
    enable = true;
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
