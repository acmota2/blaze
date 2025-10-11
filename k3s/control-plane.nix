{ pkgs, ... }:
{
  services.k3s = {
    role = "server";
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    kubectl
    helm
  ];
}
