{
  boot.loader = {
    grub = {
      device = "nodev";
      efiInstallAsRemovable = true;
      efiSupport = true;
      enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
