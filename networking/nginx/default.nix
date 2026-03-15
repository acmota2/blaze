{ config, ... }:
let
  acmeHost = "home.voldemota.xyz";
  email = "acmota2@gmail.com";
  mkDefaultProxy = ip: port: {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "http://${ip}:${port}";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
    };
  };
in
{
  sops.secrets = {
    cloudflare-token = {
      sopsFile = ../../secrets/cloudflare.env;
      format = "binary";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
    certs.${acmeHost} = {
      domain = acmeHost;
      enableAcme = true;
      extraDomainNames = [ "*.${acmeHost}" ];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.cloudflare-token.path;
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "omv.${acmeHost}" = mkDefaultProxy "192.168.1.2" "80";
      "pelican.${acmeHost}" = mkDefaultProxy "192.168.1.6" "80";

      "pi-hole.${acmeHost}" = {
        forceSSL = true;
        useACMEHost = "${acmeHost}";

        locations."/" = {
          return = "302 /admin/";
        };

        locations."/admin/" = {
          proxyPass = "http://192.168.1.4:8080/admin/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };

        locations."/api/" = {
          proxyPass = "http://192.168.1.4:8080/api/";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };

      "pve-apps.${acmeHost}" = mkDefaultProxy "192.168.1.222" "8006";
      "pve-infra.${acmeHost}" = mkDefaultProxy "192.168.1.223" "8006";
      "wg.${acmeHost}" = mkDefaultProxy "192.168.1.3" "80";
    };
  };
}
