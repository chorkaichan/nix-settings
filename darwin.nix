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
      "font-cica"
      "google-chrome"
      "1password"
      "1password-cli"
    ];
  };
  environment.systemPath = [ "/opt/homebrew/bin" ];
  system.stateVersion = 6;
}
