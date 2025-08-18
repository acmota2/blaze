    virtualization.oci.containers = {
      lazy-librarian = {
    image = "lscr.io/linuxserver/lazylibrarian:latest";
    environment = {
      PUID = "1000";
      PGID="1000"
      TZ="Europe/Lisbon"
      DOCKER_MODS="linuxserver/mods:universal-calibre|linuxserver/mods:lazylibrarian-ffmpeg"; #optional
      };
    volumes = [
      "/srv/lazy-librarian:/config"
      "/mnt/media/downloads:/downloads"
      "/mnt/audiobooks/books:/books"
      ];
    ports = [ "5299:5299" ];
    };
