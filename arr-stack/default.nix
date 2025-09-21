{
  virtualisation.oci-containers = {
    containers = {
      radarr = {
        autoStart = true;
        volumes = [
          "/srv/radarr:/config"
          "/mnt/media/downloads:/data/downloads"
          "/mnt/media/movies:/data/movies"
        ];
        ports = [ "7878:7878" ];
        environment = {
          PGID = "1000";
          PUID = "1000";
          TZ = "Europe/Lisbon";
        };
        image = "lscr.io/linuxserver/radarr:latest";
        extraOptions = [
          "--network=host"
        ];
      };

      sonarr = {
        autoStart = true;
        image = "lscr.io/linuxserver/sonarr:latest";
        ports = [ "8989:8989" ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Lisbon";
        };
        volumes = [
          "/srv/sonarr:/config"
          "/mnt/media/downloads:/data/downloads"
          "/mnt/media/tv_shows:/data/tv_shows"
        ];
        extraOptions = [
          "--network=host"
        ];
      };

      bazarr = {
        autoStart = true;
        image = "lscr.io/linuxserver/bazarr:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Lisbon";
        };
        volumes = [
          "/srv/bazarr:/config"
          "/mnt/media/downloads:/data/downloads"
          "/mnt/media/tv_shows:/data/tv_shows"
          "/mnt/media/movies:/data/movies"
        ];
        ports = [ "6767:6767" ];
        extraOptions = [
          "--network=host"
        ];
      };

      prowlarr = {
        autoStart = true;
        image = "lscr.io/linuxserver/prowlarr:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Lisbon";
        };
        ports = [ "9696:9696" ];
        volumes = [
          "/srv/prowlarr:/config"
          "/mnt/media/downloads:/data/downloads"
        ];
        extraOptions = [
          "--network=host"
        ];
      };

      jellyseerr = {
        autoStart = true;
        image = "fallenbagel/jellyseerr:latest";
        environment = {
          LOG_LEVEL = "error";
          TZ = "Europe/Lisbon";
        };
        ports = [ "5055:5055" ];
        volumes = [
          "/srv/jellyseerr:/app/config"
          "/mnt/media/downloads:/data/downloads"
        ];
        extraOptions = [
          "--network=host"
        ];
      };

      deluge = {
        autoStart = true;
        image = "lscr.io/linuxserver/deluge:latest";
        volumes = [
          "/srv/deluge:/config"
          "/mnt/media/downloads:/downloads"
        ];
        ports = [
          "8112:8112"
          "6881:6881"
          "6881:6881/udp"
          "58846:58846"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Lisbon";
          DELUGE_LOGLEVEL = "error";
        };
      };

      jellyfin = {
        autoStart = true;
        image = "docker.io/jellyfin/jellyfin:latest";
        volumes = [
          "/srv/Jellyfin:/config"
          "/srv/Jellyfin:/cache"
          "/srv/Jellyfin:/log"
          "/mnt/media/movies:/data/movies"
          "/mnt/media/movies_pt:/data/movies_pt"
          "/mnt/media/tv_shows:/data/tv_shows"
        ];
        ports = [ "8096:8096" ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Lisbon";
          JELLYFIN_LOG_DIR = "/log";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    5055
    6767
    7878
    8096
    8112
    8989
    9696
    58846
  ];
}
