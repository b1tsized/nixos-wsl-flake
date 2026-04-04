# NixOS WSL Flake

NixOS configuration for WSL development environment.

## Prerequisites

- Windows 10 (2004+) or Windows 11
- WSL2 enabled
- [1Password](https://1password.com/) with SSH agent enabled (optional, for SSH key management)
- [npiperelay](https://github.com/jstarks/npiperelay) installed on Windows (for 1Password SSH agent bridge)

## Installing NixOS on WSL

### 1. Enable WSL2

Open PowerShell as Administrator:

```powershell
wsl --install --no-distribution
wsl --set-default-version 2
```

Restart your computer if prompted.

### 2. Download NixOS WSL

Download the latest NixOS WSL tarball from the [releases page](https://github.com/nix-community/NixOS-WSL/releases):

```powershell
# In PowerShell
Invoke-WebRequest -Uri "https://github.com/nix-community/NixOS-WSL/releases/latest/download/nixos-wsl.tar.gz" -OutFile "$env:USERPROFILE\Downloads\nixos-wsl.tar.gz"
```

### 3. Import into WSL

```powershell
# Create a directory for NixOS
mkdir $env:USERPROFILE\WSL\NixOS

# Import the tarball
wsl --import NixOS $env:USERPROFILE\WSL\NixOS $env:USERPROFILE\Downloads\nixos-wsl.tar.gz
```

### 4. Launch NixOS

```powershell
wsl -d NixOS
```

### 5. Set as Default (optional)

```powershell
wsl --set-default NixOS
```

## Setting Up npiperelay (for 1Password SSH)

npiperelay allows WSL to communicate with Windows named pipes, enabling 1Password SSH agent access.

### 1. Install Go on Windows

Download and install Go from [go.dev](https://go.dev/dl/).

### 2. Build npiperelay

```powershell
go install github.com/jstarks/npiperelay@latest
```

### 3. Copy to accessible location

```powershell
mkdir -p $env:USERPROFILE\.local\bin
cp $env:USERPROFILE\go\bin\npiperelay.exe $env:USERPROFILE\.local\bin\
```

### 4. Enable 1Password SSH Agent

In 1Password Desktop App:
1. Go to Settings → Developer
2. Enable "Use the SSH agent"
3. Enable "Integrate with 1Password CLI"

## Using This Flake

### 1. Clone the repository

```bash
mkdir -p ~/github.com/b1tsized
cd ~/github.com/b1tsized
git clone git@github.com:b1tsized/nixos-wsl-flake.git
cd nixos-wsl-flake
```

### 2. Create your secrets file

Secrets are stored outside the repo at `~/.config/nixos-secrets/secrets.nix`:

```bash
mkdir -p ~/.config/nixos-secrets
cp secrets.nix.template ~/.config/nixos-secrets/secrets.nix
```

Edit `~/.config/nixos-secrets/secrets.nix` with your personal information:

```nix
{
  gitName = "Your Name";
  gitEmail = "your@email.com";
  gitSigningKey = "ssh-ed25519 AAAA...";
  windowsUser = "your-windows-username";
}
```

### 3. Enable flakes (if not already enabled)

```bash
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --update
```

Add to `/etc/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

Or run with:
```bash
sudo nixos-rebuild switch --flake .#wsl-dev --experimental-features "nix-command flakes"
```

### 4. Build and switch

```bash
sudo nixos-rebuild switch --flake .#wsl-dev
```

## Repository Structure

```
.
├── flake.nix              # Flake entry point, pins dependencies
├── flake.lock             # Locked dependency versions
├── secrets.nix.template   # Template for secrets
├── hosts/
│   └── wsl-dev/           # WSL-specific host config
│       └── default.nix
└── modules/
    └── common.nix         # Shared configuration

~/.config/nixos-secrets/
└── secrets.nix            # Personal config (outside repo)
```

### What's Included

**Development Tools:**
- Go 1.26 with gopls, delve, and tools
- Node.js 24, Bun, TypeScript LSP
- Ripgrep, fd, jq, bat, eza, lazygit

**Cloud & DevOps:**
- AWS CLI, kubectl, GitHub CLI
- Google Cloud SDK with GKE auth
- OpenTofu (Terraform alternative)

**Shell:**
- Zsh with oh-my-zsh
- Powerlevel10k theme
- Syntax highlighting & autosuggestions
- fzf, zoxide, direnv

**WSL Integration:**
- 1Password SSH agent bridge
- Windows PATH inclusion
- wslview for opening URLs in Windows browser

## Commands

| Command | Description |
|---------|-------------|
| `sudo nixos-rebuild switch --flake .#wsl-dev` | Apply configuration |
| `nix flake update` | Update all dependencies |
| `nix flake update nixpkgs` | Update only nixpkgs |
| `nix flake lock --update-input home-manager` | Update only home-manager |

## Adding a New Host

1. Create `hosts/new-host/default.nix`
2. Add the host to `flake.nix` under `nixosConfigurations`:
   ```nix
   new-host = nixpkgs.lib.nixosSystem {
     inherit system;
     specialArgs = { inherit secrets; };
     modules = [
       ./hosts/new-host
       ./modules/common.nix
     ];
   };
   ```
3. Build with `sudo nixos-rebuild switch --flake .#new-host`

## Troubleshooting

### SSH agent not working

1. Check if the service is running:
   ```bash
   systemctl --user status 1password-ssh-agent
   ```

2. Verify 1Password SSH agent is enabled on Windows

3. Check npiperelay path matches your Windows username in `secrets.nix`

4. Restart the service:
   ```bash
   systemctl --user restart 1password-ssh-agent
   ```

### WSL interop not working

After changing WSL settings, restart WSL:
```powershell
wsl --shutdown
wsl -d NixOS
```

### Flake not found

Ensure you're in the repository directory when running `nixos-rebuild`:
```bash
cd ~/github.com/b1tsized/nixos-wsl-flake
sudo nixos-rebuild switch --flake .#wsl-dev
```
