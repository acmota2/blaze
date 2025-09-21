{ pkgs, ... }:
{
  imports = [
    ./boot
    ./localization
    ./machine
    ./nfs.nix
    ./user.nix
    ./virtualization
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
