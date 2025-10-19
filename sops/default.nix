{ keyFilePath, sops-nix, ... }:
{
  imports = [ sops-nix.nixosModules.sops ];
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "${keyFilePath}";
  };
}
