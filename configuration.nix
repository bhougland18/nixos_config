# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

  let
    unstableTarball =
      fetchTarball
        https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;


  in 
  {
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # add home-manager in an updated fashion
      "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-19.09.tar.gz}/nixos"
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Add ZFS support.
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.requestEncryptionCredentials = true;

  networking.hostId = "cda96004";
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
   i18n = {
     consoleFont = "Lat2-Terminus16";
     consoleKeyMap = "us";
     defaultLocale = "en_US.UTF-8";
   };

  # Set your time zone.
  time.timeZone = "US/Eastern";

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
    allowUnfree = true;  
  };
  
  fonts.fonts = with pkgs; [
    fira-code
    fira
    cooper-hewitt
    ibm-plex
    fira-code-symbols
    powerline-fonts
  ];
  
  nixpkgs.overlays = [
    (self: super: {
      kakoune = super.wrapKakoune self.kakoune-unwrapped {
        configure = {
          plugins = with self.kakounePlugins; [
            parinfer-rust
          ];
        };
      };
    })
   ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    shells = [
      "${pkgs.bash}/bin/bash"
      "${pkgs.fish}/bin/fish"
     # "${pkgs.unstable.nushell}/bin/nu"
    ];
 

     


    etc = with pkgs; {
      "jdk11".source = jdk11;
      "openjfx11".source = openjfx11;
      "containers/policy.json" = {
          mode="0644";
          text=''
            {   
              "default": [
                {
                  "type": "insecureAcceptAnything"
                }
               ],
              "transports":
                {
                  "docker-daemon":
                    {
                      "": [{"type":"insecureAcceptAnything"}]
                    }
                }
            }
          '';
        };

      "containers/registries.conf" = {
          mode="0644";
          text=''
            [registries.search]
            registries = ['docker.io', 'quay.io']
          '';
        };
      };


    variables = {
      EDITOR = pkgs.lib.mkOverride 0 "kak";
      BROWSER = pkgs.lib.mkOverride 0 "chromium";
    };
  
    systemPackages = with pkgs; [
     
     #Commandline tools
     coreutils
     gitAndTools.gitFull
     man
     tree
     mkpasswd
     wget
     xorg.xkill
     ripgrep-all
     visidata
     youtube-dl
     chromedriver
     geckodriver
     pandoc
     jdk11
     openjfx11
     direnv
     emacs
     aspell #used by flyspell in spacemacs
     aspellDicts.en
     aspellDicts.en-computers
     chezmoi #dotfiles manager
     entr
     modd
     devd
     notify-desktop
     xclip
     exercism
     tmux
     tmuxp
     kakoune
     kitty
     taskwarrior
     tasknc
     nnn
     nq     
     fpp #facebook filepicker
     rofi

     #Rust CLI
     pazi # autojump
     exa #better ls
     skim # fuzzy finder

     #NIX tools
     nixpkgs-lint
     nixpkgs-fmt
     nixfmt

     #Containers
     unstable.podman
     unstable.buildah
     unstable.conmon
     unstable.runc
     unstable.slirp4netns
     unstable.fuse-overlayfs

     #Shells
     starship
     fish
     any-nix-shell
     unstable.nushell
     elvish

     #asciidoctor publishing
     unstable.asciidoctorj #only on unstable chanell
     graphviz
     compass
     pandoc
     ditaa

     #GUI Apps
     chromium
     dbeaver
     slack
     fondo
     torrential
     vocal
     lollypop
     unetbootin
     vscodium
     gitg
     firefox
     unstable.wpsoffice
     unclutter
     pithos
     joplin-desktop
     virtmanager

     # Gnome desktop
     gnome3.gnome-boxes
     gnome3.polari
     gnome3.dconf-editor
     gnome3.gnome-tweaks
     gnomeExtensions.impatience
     gnomeExtensions.dash-to-dock
     gnomeExtensions.dash-to-panel
     unstable.gnomeExtensions.tilingnome #broken
     gnomeExtensions.system-monitor
     
     #themes
     numix-cursor-theme
     bibata-cursors
     capitaine-cursors
     equilux-theme
     materia-theme
     mojave-gtk-theme
     nordic
     paper-gtk-theme
     paper-icon-theme
     papirus-icon-theme
     plata-theme
     sierra-gtk-theme

     #Clojure
     clojure
     clj-kondo
     leiningen
     boot
     parinfer-rust
     unstable.clojure-lsp

     #Python
     python38Full

     (vim_configurable.customize {
       name = "nvim";
       vimrcConfig.customRC = ''
	 set number relativenumber
	 syntax enable
         filetype plugin indent on
         set bg=dark
         colorscheme gruvbox

         autocmd FileType nix :packadd vim-nix
	 autocmd FileType fish :packadd vim-fish

         vnoremap <C-C> "+y
         vnoremap <S-Insert> "+y
         vnoremap <C-X> "+x
         vnoremap <S-Del> "+x
         map <C-V> "+gP
         map <S-Insert> "+gP
         cmap <C-V> <C-R>+
         cmap <S-Insert> <C-R>+
        '';

       vimrcConfig.packages.myVimPackage = with vimPlugins; {
         start = [];
         opt = [
           vim-nix
           vim-fish
           awesome-vim-colorschemes
            ];
	# loaded on lauch
	};
       # add custom .vimrc lines like this:
        
     })

    



   ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.fish.enable = true;
  programs.fish.promptInit = ''
    any-nix-shell fish --info-right | source
  '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # ZFS services
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;
  
  # To use Lorri for development
  services.lorri.enable = true; 

  # Flatpak enable
  services.flatpak.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
   services.xserver.enable = true;
   services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
   services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Enable Gnome desktop Environment
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.ben = {
     isNormalUser = true;
     #shell = pkgs.fish;
     subUidRanges = [{ startUid = 100000; count = 65536; }]; #for podman containers
     subGidRanges = [{ startGid = 100000; count = 65536; }];
     extraGroups = [ "wheel" "video" "audio" "disk" "networkmanager" ]; 
     hashedPassword = "$6$HMYj5tELGpDcdZS$IFHdcaE4c0/eoCIzaqa1EFrVqmjCZ9MFod2g3uciaFH44pa6crmmQRoz4kgRVoJ0pjJrfNer2BRwaICMrhxpE0";
     uid = 1000;
   };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.

  nix.gc.automatic = true;
  nix.gc.dates = "03:15";
  system.autoUpgrade.enable = true;
  system.stateVersion = "19.09"; # Did you read the comment?

}

