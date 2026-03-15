{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nfs-utils
  ];
  services.rpcbind.enable = true;
  boot.supportedFilesystems = [ "nfs" ];
}
