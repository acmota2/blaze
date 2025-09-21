{ pkgs, username, ... }:
{
  users.users."${username}" = {
    shell = pkgs.bash;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    description = "A normal user";
  };
}
