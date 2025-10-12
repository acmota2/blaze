{
  fileSystems."/mnt/media" = {
    device = "nfs.voldemota.xyz:/jellyfin";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "sync"
      "x-systemd.idle-timeout=600"
      "x-systemd.automount"
    ];
  };

  fileSystems."/mnt/audiobooks" = {
    device = "nfs.voldemota.xyz:/audiobooks";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "sync"
      "x-systemd.idle-timeout=600"
      "x-systemd.automount"
    ];
  };
}
