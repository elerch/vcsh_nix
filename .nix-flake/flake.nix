{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    lerchchawan.url = "git+https://git.lerch.org/lobo/chawan-flake.git";
    lerchghostty.url = "git+https://git.lerch.org/lobo/ghostty-flake.git";
  };
  outputs = { self, nixpkgs,lerchchawan, lerchghostty }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in
    {
    defaultPackage = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        hostConfig = if builtins.pathExists ./host-config.nix
          then import ./host-config.nix { pkgs = pkgs; }
          else {
            hostPackages = [];
            basePackages = "";
          };

        includeGraphical = builtins.getEnv "NIX_CONFIGURE_FULL" == "1" ||
          hostConfig.basePackages == "full";

        graphicalAndHeavyPackages = with pkgs; [
          # Heavier weight stuff and things that use x
          asciinema     # terminal screen recordings
          aws-vault     # manage multiple aws profiles
          awscli2       # aws cli, version 2
          crun          # container runner for podman/docker, written in c
          dunst         # notification daemon
          extract_url   # extracts urls from text. A bit buggy
          feh           # image viewer - good for background images
          fira-code     # monospace font
          ffmpeg        # video manipulation
          gdb           # gnu debugger
          imagemagick   # image manipulation
          khard         # interface to carddav data
          mitmproxy     # man in the middle proxy - proxy all the things
          fastfetch     # system information
          neomutt       # mutt for a new generation
          pandoc        # swiss army knife of document translation
          playerctl     # media controls
          qemu          # virtual machine
          maim          # X screenshot utility
          mlterm        # terminal emulator
          ntfy-sh       # ntfy client/server
          rclone        # clone files to/from cloud providers
          rofi          # Window switcher/dmenu replacement
          screen        # screen manager
          syncthing     # syncthing syncs all the things
          toot          # mastodon cli/tli interface
          # vlc          # video player - use flatpak instead
          xclip         # manage x clipboard
          yt-dlp        # download video from the Internet
          meld          # diff/merge tool
          yazi          # tui file manager
          mpv           # yazi uses this video player by default, bypassing xdg-open


          # Personal stuff, using X
          lerchghostty.packages.${system}.default

          # It's complicated...
          # hack-font nix isn't the best way to install this
          # noto-fonts nix isn't the best way to install fonts
          podman        # user mode container stuff
                        # because docker may be on the machine, we probably
                        # don't want this everywhere
          podman-compose
        ];
        additionalPackages = if includeGraphical then graphicalAndHeavyPackages else [];
      in
      pkgs.buildEnv {
        name = "homepkgs";
        paths = with pkgs; [
          abduco        # lightweight terminal session management
          any-nix-shell # any-nix-shell
          bat           # cat, with colorization
          btop          # better top
          binutils      # gnu binary utils (ld, strip, objdump, strings, etc.
          bloaty        # bloaty mcbloatface - shows bloat in executables
          chafa         # images in the terminal
          # Only include lerchchawan for x86_64-linux
          (if system == "x86_64-linux" then lerchchawan.packages.${system}.default else null) # Chawan appimage
          cosign        # sign container images
          delta         # fancy diff
          direnv        # direnv
          eza           # a better ls
          firejail      # provides jailing for processes
          git           # make sure we get the git version we want
          gron          # json transformation so you can grep it
          hadolint      # Dockerfile linter
          htop          # htop, a better top (concerned btop won't work everywhere)
          hyperfine     # benchmarking utility
          inotify-tools # command line access to inotify interface
          jless         # less for json
          jq            # json parser
          khal          # command line calendar stuff
          mise          # development multi-tool version manager
          mold          # multi-threaded linker
          neovim        # neovim
          nettools      # ifconfig, netstat and the like
          # (nnn.override { withNerdIcons = true; }) # nnn file manager with nerd icons (lightweight but lots of config)
          netcat        # netcat provides nc
          nmap          # nmap port scanning, etc
          p7zip         # 7z executable
          qpdf          # PDF translations
          rekor-cli     # CLI client for signature transparency log
          rsync         # sync files from one place to another through CLI
          shellcheck    # shell script linter
          sqlite        # sqlite database
          tor           # Access tor network (cli - not the browser)
          tree          # file listings as a tree
          unzip         # unzip utility
          viu           # images in the terminal
          #wasmtime      # run wasm (wasi) binaries - does not seem to work properly
          websocat      # web sockets from command line
          yaml2json     # convert yaml to json
          zellij        # terminal multiplexer
          zip           # zip utility
          zstd          # zstd compression algorithm
        ] ++ additionalPackages ++ hostConfig.hostPackages;
        pathsToLink = [ "/share/man" "/share/doc" "/bin" "/lib" "/share/fonts" ];
        extraOutputsToInstall = [ "man" "doc" ];
      });
  };
}
