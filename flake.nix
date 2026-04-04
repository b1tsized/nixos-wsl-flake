{
  description = "NixOS WSL configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }:
    let
      system = "x86_64-linux";
      # Secrets are stored outside the repo at /home/nixos/.config/nixos-secrets/secrets.nix
      secrets = import /home/nixos/.config/nixos-secrets/secrets.nix;
    in {
      nixosConfigurations = {
        wsl-dev = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit secrets; };
          modules = [
            nixos-wsl.nixosModules.wsl
            home-manager.nixosModules.home-manager
            ./hosts/wsl-dev
            ./modules/common.nix
          ];
        };
      };
    };
}
