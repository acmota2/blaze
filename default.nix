{ pkgs, ... }:
{
  imports = [
    ./nvim
  ];

  environment.systemPackages = with pkgs; [
    coreutils-full
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
