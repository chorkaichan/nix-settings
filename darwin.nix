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
      "claude-code"
      "docker-desktop"
      "font-cica"
      "google-chrome"
      "last-window-quits"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "mongodb-compass"
      "slack"
      "1password"
      "1password-cli"
    ];
  };
  environment.systemPath = [ "/opt/homebrew/bin" ];

  # Office のライセンスヘルパーが登録されたままだと、Office の pkg の
  # postinstall がヘルパーを止められずにインストールが失敗するため、
  # Homebrew bundle の前に登録を外し、終わったら登録し直す
  system.activationScripts.preActivation.text = ''
    launchctl bootout system/com.microsoft.office.licensingV3.helper 2>/dev/null || true
  '';
  system.activationScripts.postActivation.text = ''
    if [ -f /Library/LaunchDaemons/com.microsoft.office.licensingV3.helper.plist ] \
      && ! launchctl print system/com.microsoft.office.licensingV3.helper >/dev/null 2>&1; then
      launchctl bootstrap system /Library/LaunchDaemons/com.microsoft.office.licensingV3.helper.plist
    fi
  '';
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
