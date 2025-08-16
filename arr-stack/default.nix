{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      radarr = {
        autoStart = true;
        volumes = [ "/srv/radarr:/config" ];
        restart = "unless-stopped";
        environment.TZ = "Europe/Berlin";
        image = "lscr.io/linuxserver/radarr:latest";
        ports = [ "7878:7878" ];
        extraOptions = [
          "--network=host"
        ];
      };

      sonarr = {
        image = "lscr.io/linuxserver/sonarr:latest";
        restart = "unless-stopped";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Berlin";
        };
        volumes = [
          "/srv/sonarr:/config"
        ];
        ports = [ "8989:8989" ];
        extraOptions = [
          "--network=host"
        ];
      };

      deluge = {
        autoStart = true;
        image = "lscr.io/linuxserver/deluge:latest";
        restart = "unless-stopped";
        volumes = [
          "/srv/deluge/config:/config"
          "/media/downloads:/downloads"
        ];
        ports = [
          "8112:8112"
          "6881:6881"
          "6881:6881/udp"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Berlin";
          DELUGE_LOGLEVEL = "error";
        };
      };

      jellyfin = {
        autoStart = true;
        image = "docker.io/jellyfin/jellyfin:latest";
        restart = "unless-stopped";
        volumes = [
          "/srv/Jellyfin/config:/config"
          "/srv/Jellyfin/cache:/cache"
          "/srv/Jellyfin/log:/log"
          "/media/Movies:/data/movies"
          "/media/TV-Series:/data/tvshows"
        ];
        ports = [ "8096:8096" ];
        environment = {
          JELLYFIN_LOG_DIR = "/log";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
