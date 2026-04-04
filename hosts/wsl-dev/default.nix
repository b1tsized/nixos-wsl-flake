{ config, lib, pkgs, secrets, ... }:

let
  npiperelay = "/mnt/c/Users/${secrets.windowsUser}/.local/bin/npiperelay.exe";
in {
  # WSL-specific settings
  wsl.enable = true;
  wsl.defaultUser = "nixos";
  wsl.docker-desktop.enable = true;
  wsl.interop.includePath = true;
  wsl.startMenuLaunchers = true;

  system.stateVersion = "25.11";

  users.users.nixos.isNormalUser = true;
  users.users.nixos.shell = pkgs.zsh;
  programs.zsh.enable = true;

  # Home Manager configuration
  home-manager.users.nixos = { pkgs, ... }: {
    # 1Password SSH Agent bridge (WSL-specific)
    systemd.user.services."1password-ssh-agent" = {
      Unit = {
        Description = "1Password SSH Agent Bridge";
        After = [ "default.target" ];
      };
      Service = {
        ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p %h/.1password"
          "${pkgs.coreutils}/bin/rm -f %h/.1password/agent.sock"
        ];
        ExecStart = ''
          ${pkgs.socat}/bin/socat \
            UNIX-LISTEN:%h/.1password/agent.sock,fork \
            EXEC:"${npiperelay} -ei -s //./pipe/openssh-ssh-agent",nofork
        '';
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    # WSL-specific packages
    home.packages = with pkgs; [
      socat
      wslu
      xdg-utils
    ];

    # WSL-specific environment
    home.sessionVariables = {
      BROWSER = "wslview";
    };

    home.stateVersion = "25.11";
  };
}
