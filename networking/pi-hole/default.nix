{ config, lib, ... }:
let
  hosts = {
    a = {
      "hosts" = {
        "k3s-control" = "192.168.1.9";
        "net-control" = "192.168.1.10";
        "nfs" = "192.168.1.2";
        "wings" = "192.168.1.7";
      };

      "." = {
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
  sops.secrets = {
    pihole-pwhash = {
      sopsFile = ../../secrets/pihole.yaml;
      format = "yaml";
      key = "pwhash";
    };

    pihole-app-pwhash = {
      sopsFile = ../../secrets/pihole.yaml;
      format = "yaml";
      key = "app_pwhash";
    };
  };

  services = {
    pihole-web = {
      enable = true;
      ports = [ 8080 ];
    };
    pihole-ftl = {
      enable = true;

      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black's HOSTS";
        }
      ];

      openFirewallDNS = true;
      openFirewallWebserver = true;
      queryLogDeleter.enable = true;

      settings = {
        dhcp.active = false;
        domain = topHost;
        domainNeeded = true;
        expandHosts = true;

        dns = {
          cnameRecords = lib.concatLists (
            lib.map (zone: lib.map (name: "${zone}.${topHost},${name}.${zone}.${topHost}") zone) cname
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

          webserver.api = {
            pwhash = config.sops.placeholder.pihole-pwhash;
            app_pwhash = config.sops.placeholder.pihole-app-pwhash;
          };
        };
      };
    };
    resolved.extraConfig = ''
      DNSStubListener=no
      MulticastDNS=off
    '';
  };
}
