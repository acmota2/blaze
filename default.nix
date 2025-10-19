{ pkgs, ... }:
{
  imports = [
    { system.stateVersion = "25.05"; }
    ./boot/default.nix
    ./con/default.nix
    ./disko/default.nix
    ./localization/default.nix
    ./nfs/default.nix
    ./sops/default.nix
  ];

  environment.systemPackages = with pkgs; [
    coreutils-full
    neovim
    curl
    file
    git
    htop
    unzip
    wget
    zip
    zsh
  ];
}
