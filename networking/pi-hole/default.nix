{ lib, ... }:
let
  hosts = {
    a = {
      "hosts" = {
        "k3s-control" = "192.168.1.9";
        "net-control" = "192.168.1.4";
        "nfs" = "192.168.1.2";
        "wings" = "192.168.1.7";
      };

      "." = {
        "home" = "192.168.1.4";
        "mc" = "192.168.1.7";
      };

      "svc" = {
        "nfs" = "192.168.1.2";
      };
    };

    cname = {
      "home" = [
        "omv"
        "pelican"
        "pi-hole"
        "pve-apps"
        "pve-infra"
        "wg"
      ];
    };
  };
  inherit (hosts) a cname;
  topHost = "voldemota.xyz";
  mkFqdn =
    base: record: if base == "." then "${record}.${topHost}" else "${record}.${base}.${topHost}";
in
{
  # sops.secrets = {
  #   pihole-pwhash = {
  #     sopsFile = ../../secrets/pihole.yaml;
  #     format = "yaml";
  #     key = "pwhash";
  #   };

  #   pihole-app-pwhash = {
  #     sopsFile = ../../secrets/pihole.yaml;
  #     format = "yaml";
  #     key = "app_pwhash";
  #   };
  # };

  services = {
    pihole-web = {
      enable = true;
      ports = [ "8080o" ];
    };

    pihole-ftl = {
      enable = true;

      openFirewallDNS = true;
      queryLogDeleter.enable = true;

      settings = {
        dhcp.active = false;
        domain = topHost;
        domainNeeded = true;
        expandHosts = true;

        dns = {
          cnameRecords = lib.concatLists (
            lib.mapAttrsToList (
              zone: entries: lib.map (name: "${name}.${zone}.${topHost},${zone}.${topHost}") entries
            ) cname
          );

          hosts = lib.concatLists (
            lib.mapAttrsToList (
              base: records: lib.mapAttrsToList (record: ip: "${ip} ${mkFqdn base record}") records
            ) a
          );

          upstreams = [
            "1.1.1.1"
            "1.0.0.1"
          ];
        };

        # webserver = {
        #   port = "8080o";
        #   api = {
        #     app_pwhash = config.sops.placeholder.pihole-app-pwhash;
        #     pwhash = config.sops.placeholder.pihole-pwhash;
        #   };
        # };
      };
    };

    resolved.extraConfig = ''
      DNSStubListener=no
      MulticastDNS=off
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 53 ];
  };
}
