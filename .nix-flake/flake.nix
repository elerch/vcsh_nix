{
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  outputs = { self, nixpkgs }:
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

        includeGraphical = builtins.getEnv "NIX_CONFIGURE_FULL" == "1";

        graphicalAndHeavyPackages = with pkgs; [
          # Heavier weight stuff and things that use x
          dunst         # notification daemon
          playerctl     # media controls
          qemu          # virtual machine
          maim          # X screenshot utility
          mlterm        # terminal emulator
          rofi          # Window switcher/dmenu replacement
          # vlc          # video player - use flatpak instead
          xclip         # manage x clipboard

          # It's complicated...
          # hack-font nix isn't the best way to install this
          # noto-fonts nix isn't the best way to install fonts
          podman        # user mode container stuff
                        # because docker may be on the machine, we probably
                        # don't want this everywhere
        ];
        additionalPackages = if includeGraphical then graphicalAndHeavyPackages else [];
      in
      pkgs.buildEnv {
        name = "homepkgs";
        paths = with pkgs; [
          asciinema     # terminal screen recordings
          autoconf      # auto configuration for c/c++ projects
          automake      # automake for c/c++ projects
          aws-vault     # manage multiple aws profiles
          awscli2       # aws cli, version 2
          bat           # cat, with colorization
          binutils      # gnu binary utils (ld, strip, objdump, strings, etc.
          bloaty        # bloaty mcbloatface - shows bloat in executables
          crun          # container runner for podman/docker, written in c
          eza           # a better ls
          extract_url   # extracts urls from text. A bit buggy
          feh           # image viewer - good for background images
          ffmpeg        # video manipulation
          firejail      # provides jailing for processes
          gdb           # gnu debugger
          gron          # json transformation so you can grep it
          htop          # htop, a better top
          hugo          # static site generator TODO: use nix develop for this!
          hyperfine     # benchmarking utility
          imagemagick   # image manipulation
          inotify-tools # command line access to inotify interface
          jq            # json parser
          khard         # interface to carddav data
          lsix          # image thumbnails in terminal via six
          mitmproxy     # man in the middle proxy - proxy all the things
          mold          # multi-threaded linker
          neofetch      # system information
          neomutt       # mutt for a new generation
          nettools      # ifconfig, netstat and the like
          netcat        # netcat provides nc
          nmap          # nmap port scanning, etc
          p7zip         # 7z executable
          pandoc        # swiss army knife of document translation
          qpdf          # PDF translations
          rsync         # sync files from one place to another through CLI
          screen        # screen manager
          sqlite        # sqlite database
          syncthing     # syncthing syncs all the things
          tmux          # terminal multiplexer
          tree          # file listings as a tree
          unzip         # unzip utility
          wasmtime      # run wasm (wasi) binaries
          w3m           # w3m browser
          zip           # zip utility
          zstd          # zstd compression algorithm
        ] ++ additionalPackages;
        pathsToLink = [ "/share/man" "/share/doc" "/bin" "/lib" ];
        extraOutputsToInstall = [ "man" "doc" ];
      });
  };
}
