{ hostname, ... }:
_: {
  imports = [
    ./${hostname}.nix
  ];
  system.stateVersion = "25.05";
}
