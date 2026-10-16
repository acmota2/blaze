_: {
  boot.kernelModules = [
    "br_netfilter"
    "vxlan"
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
  };

  networking.firewall = {
    allowedUDPPorts = [ 8472 ];
    trustedInterfaces = [
      "cni0"
      "flannel.1"
    ];
  };

  systemd.services.k3s = {
    after = [
      "iscsid.service"
      "network-online.target"
    ];
    requires = [ "iscsid.service" ];
  };
}
