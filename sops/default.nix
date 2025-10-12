{ keyFilePath, ... }:
{
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "${keyFilePath}";
  };
}
