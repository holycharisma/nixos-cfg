{ lib, pkgs, config, ... }: 
let ssh_pub = 
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDRaCix7GyTVMJ6qhkZ69F8vRshsxdS5pER0G1ceFLGv orpheus@holycharisma.com";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/sops-extend-scripts
    ../../modules/sops-template
  ];

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

  boot.cleanTmpDir = true;
  zramSwap.enable = true;

  networking.hostName = "marge";
  networking.domain = "";

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.utf8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    helix
    wget
    curl
    git
    jq
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "orpheus@holycharisma.com";
  };

  services.caddy = {
    enable = true;
    virtualHosts."vault.holycharisma.com" = {
      extraConfig = ''
        reverse_proxy http://homer:8222
      '';
    };  

  };

  services.openssh.enable = true;

  services.tailscale.enable = true;

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
        # check if we are already authenticated to tailscale
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then # if so, then do nothing
          exit 0
        fi

        # otherwise authenticate with tailscale
        ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.ts_auth.path})
      '';
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    checkReversePath = "loose";
    allowedUDPPorts = [ config.services.tailscale.port ];      
    allowedTCPPorts = [ 80 443 ];
  };

  security.sudo.wheelNeedsPassword = false;
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
  
  system.stateVersion = "23.05";

}
