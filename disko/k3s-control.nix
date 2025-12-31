{ disko, ... }:
{
  imports = [ disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      vm-disk = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            BIOS = {
              type = "EF02";
              size = "2M";
            };
          };
        };
      };

      k3s-data = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
        type = "disk";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/var/lib/rancher/k3s";
        };
      };
    };
  };
}
