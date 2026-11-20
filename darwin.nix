{ pkgs, ...  }: {
  nix.enable = false;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "kaito";
  users.users."kaito".home = "/Users/kaito";
  security.pam.services.sudo_local.touchIdAuth = true;
  homebrew = {
    enable = true;
    # masApps のインストールに使う
    brews = [
      "mas"
    ];
    casks = [
      "adobe-creative-cloud"
      "android-studio"
      "claude"
      "claude-code"
      "discord"
      "displaylink"
      "docker-desktop"
      "figma"
      "firefox"
      "font-cica"
      "google-chrome"
      "last-window-quits"
      "microsoft-edge"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "mongodb-compass"
      "slack"
      "vercel"
      "whatsapp"
      "zoom"
      "1password"
      "1password-cli"
    ];
    # App Store にサインインしている必要がある
    masApps = {
      LINE = 539883307;
      Xcode = 497799835;
    };
  };
  environment.systemPath = [ "/opt/homebrew/bin" ];

  # CleanShot は 4 系に固定したいので、Homebrew の cask（常に最新）ではなく
  # 4 系最新の DMG を直接パッケージ化して入れる
  environment.systemPackages = [
    (pkgs.stdenvNoCC.mkDerivation rec {
      pname = "cleanshot";
      version = "4.8.10";
      src = pkgs.fetchurl {
        url = "https://updates.getcleanshot.com/v3/CleanShot-X-${version}.dmg";
        sha256 = "0f1b1cdda9a93908ced0341abb0d505adc55e51d145562013085b1e70f366d84";
      };
      # DMG が APFS なので undmg ではなく 7zz で展開する
      nativeBuildInputs = [ pkgs._7zz ];
      # 7zz は拡張属性を「ファイル名:属性名」の別ファイルとして書き出し、
      # 署名が壊れるので消しておく
      unpackPhase = ''
        7zz x -snld $src
        find . -name '*:com.apple.*' -delete
      '';
      sourceRoot = ".";
      installPhase = ''
        mkdir -p $out/Applications
        cp -R "CleanShot X.app" $out/Applications/
      '';
    })
  ];

  # ログイン時に CleanShot を起動する
  # （画面収録の許可を引き継ぐため、Nix ストアではなく /Applications/Nix Apps の方を開く）
  launchd.user.agents.cleanshot.serviceConfig = {
    ProgramArguments = [ "/usr/bin/open" "-a" "/Applications/Nix Apps/CleanShot X.app" ];
    RunAtLoad = true;
  };

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

    # symbolichotkeys の変更はログインし直さないと反映されないので、すぐ反映させる
    launchctl asuser "$(id -u -- kaito)" sudo --user=kaito -- \
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    # 放置しても画面がロックされないように、スクリーンセーバーを開始しないようにする
    # （ホストごとの設定なので system.defaults ではなく -currentHost で書き込む）
    launchctl asuser "$(id -u -- kaito)" sudo --user=kaito -- \
      defaults -currentHost write com.apple.screensaver idleTime -int 0
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
        # CleanShot を使うので macOS 標準のスクリーンショットのショートカットを無効にする
        "28" = {  # ⇧⌘3: 画面全体を保存
          enabled = false;
          value = { parameters = [ 51 20 1179648 ]; type = "standard"; };
        };
        "29" = {  # ⌃⇧⌘3: 画面全体をクリップボードにコピー
          enabled = false;
          value = { parameters = [ 51 20 1441792 ]; type = "standard"; };
        };
        "30" = {  # ⇧⌘4: 選択部分を保存
          enabled = false;
          value = { parameters = [ 52 21 1179648 ]; type = "standard"; };
        };
        "31" = {  # ⌃⇧⌘4: 選択部分をクリップボードにコピー
          enabled = false;
          value = { parameters = [ 52 21 1441792 ]; type = "standard"; };
        };
        "184" = {  # ⇧⌘5: スクリーンショットと収録オプション
          enabled = false;
          value = { parameters = [ 53 23 1179648 ]; type = "standard"; };
        };
        # ⌃← / ⌃→ で左右の操作スペース（デスクトップ）に移動する
        # 矢印キーは文字コードなし(65535)、修飾キーは Ctrl(0x40000) + Fn(0x800000)
        "79" = {  # ⌃←: 左の操作スペースに移動
          enabled = true;
          value = { parameters = [ 65535 123 8650752 ]; type = "standard"; };
        };
        "81" = {  # ⌃→: 右の操作スペースに移動
          enabled = true;
          value = { parameters = [ 65535 124 8650752 ]; type = "standard"; };
        };
      };
    };
  };

  # 自動スリープをオフ
  power.sleep.computer = "never";
  power.sleep.display = "never";

  system.stateVersion = 6;
}
