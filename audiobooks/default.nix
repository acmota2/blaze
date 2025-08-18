{
  virtualization.oci.containers = {
    lazy-librarian = {
      image = "lscr.io/linuxserver/lazylibrarian:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Lisbon";
        DOCKER_MODS = "linuxserver/mods:universal-calibre|linuxserver/mods:lazylibrarian-ffmpeg"; # optional
      };
      volumes = [
        "/srv/lazy-librarian:/config"
        "/mnt/media/downloads:/downloads"
        "/mnt/audiobooks/audiobooks:/books"
      ];
      ports = [ "5299:5299" ];
    };
    audiobookshelf = {
      image = "ghcr.io/advplyr/audiobookshelf:latest";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Lisbon";
        DOCKER_MODS = "linuxserver/mods:universal-calibre|linuxserver/mods:lazylibrarian-ffmpeg"; # optional
      };
      volumes = [
        "/srv/audiobookshelf/config:/config"
        "/srv/audiobookshelf/metadata:/metadata"
        "/mnt/audiobooks/podcasts:/podcasts"
        "/mnt/audiobooks/books:/books"
      ];
      ports = [ "13378:80" ];
    };
  };
}
