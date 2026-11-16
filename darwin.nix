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
      "docker-desktop"
      "font-cica"
      "google-chrome"
      "slack"
      "1password"
      "1password-cli"
    ];
  };
  environment.systemPath = [ "/opt/homebrew/bin" ];
  system.defaults = {
    # スクロール方向を逆にする（ナチュラルスクロールをオフ）
    NSGlobalDomain."com.apple.swipescrolldirection" = false;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;  # 追加：タップでクリック

    trackpad.Clicking = true;                          # 追加：タップでクリック

    # 日本語入力のライブ変換をオフ
    CustomUserPreferences."com.apple.inputmethod.Kotoeri" = {
      JIMPrefLiveConversionKey = false;
    };
    CustomUserPreferences."com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "64" = {
          enabled = true;
          value = {
            parameters = [ 108 37 262144 ];  # "l"の文字コード, Lキーのキーコード, Ctrl
            type = "standard";
          };
        };
      };
    };
  };

  # 自動スリープをオフ
  power.sleep.computer = "never";
  power.sleep.display = "never";

  system.stateVersion = 6;
}
