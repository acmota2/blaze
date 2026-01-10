{
  boot.loader = {
    grub = {
      device = "nodev";
      efiSupport = true;
      enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
