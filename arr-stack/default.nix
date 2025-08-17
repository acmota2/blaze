{
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      radarr = {
        autoStart = true;
        volumes = [ "/srv/radarr:/config" ];
        environment.TZ = "Europe/Lisbon";
        image = "lscr.io/linuxserver/radarr:latest";
        ports = [ "7878:7878" ];
        extraOptions = [
          "--network=host"
        ];
      };

      sonarr = {
        autoStart = true;
        image = "lscr.io/linuxserver/sonarr:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Europe/Lisbon";
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
        volumes = [
          "/srv/deluge:/config"
          "/mnt/media/downloads:/downloads"
        ];
        ports = [
          "8112:8112"
          "6881:6881"
          "6881:6881/udp"
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
          JELLYFIN_LOG_DIR = "/log";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
