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

  networking.hostId = "238330f5";
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    shells = [
      "${pkgs.bash}/bin/bash"
      "${pkgs.fish}/bin/fish"
    ];

    etc = with pkgs; {
      "jdk11".source = jdk11;
    };

    variables = {
      EDITOR = pkgs.lib.mkOverride 0 "vim";
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
     vim
     xorg.xkill
     ripgrep-all
     visidata
     youtube-dl
     chromedriver
     geckodriver
     exa
     pandoc
     jdk11
     direnv
     emacs
     aspell #used by flyspell in spacemacs
     aspellDicts.en
     aspellDicts.en-computers
     chezmoi #dotfiles manager
     neovim

     #Shells
     starship
     fish
     any-nix-shell
     powerline-go
     unstable.nushell

     #asciidoctor publishing
     #asciidoctorj #only on unstable chanell
     graphviz
     compass
     pandoc
     ditaa

     #GUI Apps
     tilix
     chromium
     dbeaver
     slack
     fondo
     calibre
     torrential
     vocal
     lollypop
     unetbootin
     visidata
     vscodium
     jetbrains.idea-community
     gitg
     planner
     firefox
     unstable.spotify
     unstable.wpsoffice
     mousetweaks
    
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
     solarc-gtk-theme     

     #Clojure
     clojure
     clj-kondo
     leiningen

     #Python
     python38Full

   ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
  programs.fish.enable = true;
  programs.zsh.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # ZFS services
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoScrub.enable = true;

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
     shell = pkgs.fish;
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

