{
  services.rpcbind.enable = true; # needed for NFS
  fileSystems."/mnt/media" = {
    device = "nfs.voldemota.xyz:/jellyfin";
    fsType = "nfs";
  };
  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
      };
      what = "nfs.voldemota.xyz:/jellyfin";
      where = "/mnt/media";
    }
  ];
  systemd.automounts = [
    {
      wantedBy = [ "multi-user.target" ];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt/media";
    }
  ];

  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
}
