{ sops-nix, username, ... }:
{
  imports = [ sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  };
}
