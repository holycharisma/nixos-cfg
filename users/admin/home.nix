
{ lib, pkgs, ...}: {

    home.packages = [

    ];      
    
    home.stateVersion = "22.05";

    programs.git = {
      enable = true;
      userName = "holycharisma";
      userEmail = "admin@holycharisma.com";
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

}