{ config, ... }:
let
  acmeHost = "home.voldemota.xyz";
  email = "acmota2@gmail.com";
  mkDefaultProxy = ip: port: {
    forceSSL = true;
    useACMEHost = acmeHost;
    locations."/" = {
      proxyWebsockets = true;
      proxyPass = "http://${ip}:${port}";
    };
  };
  mkProxmoxProxy = ip: {
    forceSSL = true;
    useACMEHost = acmeHost;

    locations."/" = {
      proxyPass = "https://${ip}:8006";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_ssl_verify off;
      '';
    };
  };
in
{
  sops.secrets.cloudflare-token = {
    sopsFile = ../../secrets/cloudflare.env;
    format = "dotenv";
    key = "";
  };

  users.users.nginx.extraGroups = [ "acme" ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = email;
    certs.${acmeHost} = {
      dnsPropagationCheck = true;
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      domain = acmeHost;
      environmentFile = config.sops.secrets.cloudflare-token.path;
      extraDomainNames = [ "*.${acmeHost}" ];
      group = "nginx";
    };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "infisical.${acmeHost}" = mkDefaultProxy "192.168.1.10" "8080";
      "omv.${acmeHost}" = mkDefaultProxy "192.168.1.2" "80";
      "pelican.${acmeHost}" = mkDefaultProxy "192.168.1.6" "80";

      "pi-hole.${acmeHost}" = {
        forceSSL = true;
        useACMEHost = acmeHost;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
        };
      };

      "pve-apps.${acmeHost}" = mkProxmoxProxy "192.168.1.222";
      "pve-infra.${acmeHost}" = mkProxmoxProxy "192.168.1.223";
      "wg.${acmeHost}" = mkDefaultProxy "192.168.1.3" "10086";
    };
  };
}
