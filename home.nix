{ config, pkgs, inputs, ... }:

{
  imports = [ ./nvim.nix ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kaito";
  home.homeDirectory = "/Users/kaito";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    tig
    # サプライチェーン攻撃対策として、公開から7日以上経ったリリースだけに
    # スキルの flake input を更新してから darwin-rebuild switch する
    (writeShellApplication {
      name = "rebuild";
      runtimeInputs = [ curl jq gnused ];
      text = ''
        flake_dir="$HOME/.config/home-manager"
        min_age_days=7

        # 引数: flake input 名, GitHub の owner/repo
        update_input() {
          local input=$1 repo=$2 tag current
          tag=$(curl -fsSL "https://api.github.com/repos/$repo/releases?per_page=100" \
            | jq -r --argjson days "$min_age_days" '
                [.[] | select((.draft or .prerelease) | not)
                     | select((.published_at | fromdateiso8601) <= now - $days * 86400)]
                | sort_by(.published_at) | last | .tag_name // empty')
          current=$(sed -n "s|.*\"github:$repo/\([^\"]*\)\".*|\1|p" "$flake_dir/flake.nix")

          if [ -z "$tag" ]; then
            echo "$input: no release older than $min_age_days days; keeping $current" >&2
          elif [ "$tag" != "$current" ]; then
            echo "$input: $current -> $tag"
            sed -i "s|github:$repo/$current\"|github:$repo/$tag\"|" "$flake_dir/flake.nix"
            nix flake update "$input" --flake "$flake_dir"
          fi
        }

        update_input yomiyasu nanaism/yomiyasu
        update_input natural-japanese coji/natural-japanese

        sudo darwin-rebuild switch --flake "$flake_dir" "$@"
      '';
    })
  ];

  programs.claude-code = {
    enable = true;
    package = null; # 本体は Homebrew cask で管理
    skills = {
      yomiyasu = "${inputs.yomiyasu}/skills/yomiyasu";
      natural-japanese = "${inputs.natural-japanese}/skills/natural-japanese";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Kaito Kikuchi";
      user.email = "sin180degree@gmail.com";
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh"; # SSH 鍵は 1Password のエージェントから使う
  };

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;
    enableZshIntegration = true;

    settings = {
      # カラースキーム
      theme = "Nightfox";

      # フォント
      font-family = "Cica";
      font-size = 19;
      adjust-cell-height = "5%";  # line_height = 1.05 相当

      # キーバインド
      keybind = [
        "cmd+d=new_split:right"         # 横方向に分割
        "cmd+shift+d=new_split:down"    # 縦方向に分割
        "cmd+[=goto_split:previous"     # 前のペインへ
        "cmd+]=goto_split:next"         # 次のペインへ
      ];
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;       # 履歴からのコマンド候補（zsh-autosuggestions）
    syntaxHighlighting.enable = true;   # コマンドの色分け
    history = {
      size = 10000;
      ignoreDups = true;
      share = true;                     # 複数タブで履歴を共有
    };
    plugins = [
      {
        name = "zsh-vi-mode";           # 前の環境で使っていたviモード
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.starship.enable = true;      # プロンプト（Gitブランチ等を表示）
  programs.fzf.enable = true;           # Ctrl+Rで履歴をあいまい検索
  programs.zoxide.enable = true;        # z ディレクトリ名 で賢く移動

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kaito/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
