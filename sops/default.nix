{ username, ... }:
{ sops-nix, ... }:
{
  imports = [ sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
  };
}
