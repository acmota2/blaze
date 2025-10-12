{ username, ... }:
{ pkgs, ... }:
{
  users = {
    groups.${username} = { };
    users."${username}" = {
      shell = pkgs.bash;
      isNormalUser = true;
      group = "${username}";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      description = "A normal user";
    };
  };
}
