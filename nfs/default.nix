{
  services.rpcbind.enable = true; # needed for NFS
  # optional, but ensures rpc-statsd is running for on demand mounting
  boot.supportedFilesystems = [ "nfs" ];
}
