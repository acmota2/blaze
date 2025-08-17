{ pkgs, ... }:
{
  imports = [
    ./virtualization
    ./boot
    ./machine
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
