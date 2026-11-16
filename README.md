# dotfiles

macOS configuration managed with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager) using Nix flakes.

## Getting Started

The steps below prepare a fresh Mac so that the Nix configuration in this repository can be applied. They cannot be managed by Nix itself and only need to be done once per machine.

### 1. Install Command Line Tools

Command Line Tools are proprietary Apple software and cannot be installed through Nix. They provide `git`, `clang`, and other tools that Homebrew and some build steps depend on.

```sh
xcode-select --install
```

Follow the dialog to complete the installation.

### 2. Install Determinate Nix

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Flakes are enabled by default in Determinate Nix, so no extra configuration is needed. Open a new terminal after the installation finishes.

### 3. Install Homebrew

nix-darwin manages Homebrew casks declaratively, but it does not install Homebrew itself.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 4. Clone this repository

Clone the repository to `~/.config/home-manager`. Use HTTPS here, because the SSH key (served by the 1Password SSH agent) is not available on a fresh machine yet.

```sh
git clone https://github.com/<your-account>/<your-repo>.git ~/.config/home-manager
```

### 5. Apply the configuration for the first time

Check the hostname of the machine:

```sh
scutil --get LocalHostName
```

Make sure the same name is used in `darwinConfigurations."<hostname>"` in `flake.nix`, then run the first build. `darwin-rebuild` is not on the `PATH` yet, so run it through `nix run`:

```sh
cd ~/.config/home-manager
sudo nix run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#<hostname>
```

If the activation stops because an existing file such as `/etc/zshrc` would be overwritten, move it aside as the error message suggests and run the command again:

```sh
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
```

After the first successful run, apply changes with:

```sh
sudo darwin-rebuild switch --flake ~/.config/home-manager
```
