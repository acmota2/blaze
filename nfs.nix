{
  services.rpcbind.enable = true; # needed for NFS
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

  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
}
