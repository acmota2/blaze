{ my-neovim, pkgs, ... }:
{
  imports = [
    { system.stateVersion = "25.11"; }
    ./boot/default.nix
    ./con/default.nix
    ./localization/default.nix
    ./sops/default.nix
  ];

  environment.systemPackages = with pkgs; [
    btop
    coreutils-full
    curl
    file
    git
    my-neovim
    unzip
    wget
    zip
    zsh
  ];
}
