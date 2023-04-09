{ config, lib, pkgs, ... }:
let ssh_pub = 
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRaCix7GyTVMJ6qhkZ69F8vRshsxdS5pER0G1ceFLGv orpheus@holycharisma.com" ;
in {

  imports = [
    ./hardware-configuration.nix
    ../../modules/sops-extend-scripts
    ../../modules/sops-template
  ];

  # QNAP v-station
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;  

  nix.package = pkgs.nixFlakes;
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';

  sops.defaultSopsFile = ./secrets/sops.yaml;
  sops.age.keyFile = "/var/lib/age/keys.txt"; # plz install me manually

  sops.secrets.ts_auth = {};
  sops.secrets.nextcloud_password = {
    owner = config.users.users.nextcloud.name;
    group = config.users.users.nextcloud.group;
  };
  sops.secrets.vaultwarden_env = {
    owner = config.users.users.vaultwarden.name;
    group = config.users.users.vaultwarden.group;
  };
  sops.secrets.minio_env = {
    owner = config.users.users.minio.name;
    group = config.users.users.minio.group;
  };


  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    helix
    tailscale
    jq
    magic-wormhole

    # some stuff for qnap-v-station
    lxqt.lxqt-policykit
  ];

  boot.cleanTmpDir = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap.enable = true;

  programs.mosh.enable = true;

  users.users.admin = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.bash;
    description = "admin";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "${ssh_pub}"
    ];
  };
    
  users.users.root.openssh.authorizedKeys.keys = [
    "${ssh_pub}"
  ];
  
  networking.hostName = "homer";
  networking.domain = "";

  # networking.networkmanager.enable = true;

  security.sudo.wheelNeedsPassword = false;
    
  system.activationScripts.makeVaultWardenDir = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/bitwarden_rs.copy/
    chown -R vaultwarden:vaultwarden /var/lib/bitwarden_rs.copy/
  '';

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/bitwarden_rs.copy";
    environmentFile = config.sops.secrets.vaultwarden_env.path;
    config = {
        DOMAIN = "https://vault.holycharisma.com";
        IP_HEADER = "X-Forwarded-For";

        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
        ROCKET_LOG = "critical";
      };
  };

  services.minio = {
    enable = true;
    rootCredentialsFile = config.sops.secrets.minio_env.path;
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud26;
    extraAppsEnable = true;
    extraApps = with pkgs.nextcloud26Packages.apps; {
      inherit calendar mail contacts tasks notes deck;
    };
    hostName = "homer";
    config.overwriteProtocol = "https"; # we will be accessing this over public https
    config.extraTrustedDomains = [ "cloud.holycharisma.com" ];
    config.trustedProxies = [ "cloud.holycharisma.com" ];
    config.adminpassFile = config.sops.secrets.nextcloud_password.path;
  };

  services.nginx.virtualHosts."homer".listen = [ { addr = "0.0.0.0"; port = 8080; } ];

  services.openssh.enable = true;
  services.tailscale.enable = true;

  networking.firewall.checkReversePath = "loose";
  networking.firewall.enable = false;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.ts_auth.path})
    '';
  };

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.utf8";

  services.printing.enable = false;
  sound.enable = false;
      
  system.stateVersion = "22.11";

}
