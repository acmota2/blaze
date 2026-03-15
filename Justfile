install-host HOST:
  nixos-anywhere \
    --flake .#{{ HOST }} \
    --generate-hardware-config nixos-generate-config machine/{{ HOST }}.nix \
    --build-on-remote \
    nixos@{{ HOST }}.hosts.voldemota.xyz
