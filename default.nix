{
  pkgs,
  disko,
  sops-nix,
  ...
}:
{
  defaultModules = [
    ./boot
    ./con
    ./disko
    ./localization
    ./machine
    ./sops
    disko.nixosModules.disko
    sops-nix.nixosModules.sops
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
