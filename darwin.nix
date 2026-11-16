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
  system.defaults = {
    # スクロール方向を逆にする（ナチュラルスクロールをオフ）
    NSGlobalDomain."com.apple.swipescrolldirection" = false;

    # 日本語入力のライブ変換をオフ
    CustomUserPreferences."com.apple.inputmethod.Kotoeri" = {
      JIMPrefLiveConversionKey = false;
    };
  };

  # 自動スリープをオフ
  power.sleep.computer = "never";

  system.stateVersion = 6;
}
