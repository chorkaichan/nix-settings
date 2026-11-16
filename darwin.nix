{ pkgs, ...  }: {
  nix.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "kaito";
  users.users."kaito".home = "/Users/kaito";
  security.pam.services.sudo_local.touchIdAuth = true;
  homebrew = {
    enable = true;
    casks = [
      "claude"
    ];
  };
  system.stateVersion = 6;
}
