{
  disko,
  pkgs,
  sops-nix,
  ...
}:
{
  imports = [
    { system.stateVersion = "25.05"; }
    ./boot/default.nix
    ./con/default.nix
    ./disko/default.nix
    ./localization/default.nix
    ./sops/default.nix
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
