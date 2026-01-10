install-k3s-control:
  nixos-anywhere \
    --flake .#k3s-control \
    --generate-hardware-config nixos-generate-config machine/k3s-control.nix \
    --build-on-remote \
    nixos@k3s-control.voldemota.xyz
