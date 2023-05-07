
{ lib, pkgs, system, devenv, ...}: {

    xdg.enable = true;

    programs.kitty = {
      enable = true;
      extraConfig = builtins.readFile ./kitty.conf;
    };

    home.packages = [
      devenv.packages.${system}.devenv
      pkgs.cachix
      pkgs.mosh
      pkgs.wget
      pkgs.tig
      pkgs.just
      pkgs.jq
    ];
    
    home.stateVersion = "22.11";

    programs.exa = {
      enableAliases = true;
      enable = true;
    };

    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_latte";
      };
    };

    programs.git = {
      enable = true;
      userName = "Holy Charisma";
      userEmail = "orpheus@lisa.elf-lizard.ts.net";
      aliases = {
        root = "rev-parse --show-toplevel";
      };
      extraConfig = {
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = ""; # needs to be empty to use terminal for ask pass
        credential.helper = "store"; # want to make this more secure
        push.default = "tracking";
        init.defaultBranch = "main";
      };
    };

    programs.fish = {
      enable = true;
      interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
        (builtins.readFile ./config.fish)
        "set -g SHELL ${pkgs.fish}/bin/fish"
      ]);

      shellAliases = {
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gl = "git prettylog";
        gp = "git push";
        gs = "git status";
        gt = "git tag";    
      };

    };

      programs.starship = {
        enable = true;
        # Configuration written to ~/.config/starship.toml
        settings = {
          # add_newline = false;

          # character = {
          #   success_symbol = "[➜](bold green)";
          #   error_symbol = "[➜](bold red)";
          # };

          # package.disabled = true;
        };
      };


}