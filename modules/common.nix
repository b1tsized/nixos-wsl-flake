{ config, lib, pkgs, secrets, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "1password-cli"
  ];

  # Home Manager shared configuration
  home-manager.users.nixos = { pkgs, ... }: {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "1password-cli"
      "claude-code"
    ];

    home.packages = with pkgs; [
      # Core tools
      htop
      git
      vim
      _1password-cli
      # claude-code  # Removed - install via: bun install -g @anthropic-ai/claude-code

      # Cloud & DevOps
      awscli2
      kubectl
      gh
      opentofu
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.cloud-run-proxy
        google-cloud-sdk.components.cloud_sql_proxy
        google-cloud-sdk.components.alpha
        google-cloud-sdk.components.beta
      ])

      # JS/TS development
      nodejs_24
      bun
      typescript
      prettierd
      firebase-tools

      # Go development
      go_1_26
      gopls
      gotools
      go-tools
      delve
      gcc

      # Search and CLI tools
      ripgrep
      fd
      jq
      tree
      curl
      bat
      eza
      yq
      lazygit
      wget
      unzip
    ];

    home.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
      EDITOR = "vim";
      VISUAL = "vim";
      CLAUDE_INSTALL_TYPE = "native";
    };

    # Zsh configuration
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "asdf"
          "docker"
          "docker-compose"
          "dotenv"
          "gh"
          "git"
          "node"
          "npm"
          "terraform"
          "vscode"
        ];
      };
      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
      ];
      initContent = ''
        # Fix oh-my-zsh cache permissions
        chmod -R u+w "$HOME/.cache/oh-my-zsh" 2>/dev/null || true

        # Powerlevel10k instant prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
        # Load p10k config if it exists
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
      '';
    };

    # Development tools
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };

    programs.home-manager.enable = true;

    # SSH configuration
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks."*" = {
        extraOptions = {
          IdentityAgent = "~/.1password/agent.sock";
        };
      };
    };

    # Git configuration
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = secrets.gitName;
          email = secrets.gitEmail;
          signingKey = secrets.gitSigningKey;
        };
        gpg.format = "ssh";
        commit.gpgsign = true;
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };
    };
  };
}
