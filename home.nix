{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kaito";
  home.homeDirectory = "/Users/kaito";
  programs.zsh.enable = true;

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
    neovim
    lazygit      # LazyVimのGit UI（<leader>gg）
    ripgrep
    fd
    fzf
    tree-sitter  # treesitterパーサーのビルドに必要
    nodejs       # 一部LSPのインストールに必要
  ];

  home.sessionVariables.EDITOR = "nvim";

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/home-manager/nvim";

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Kaito Kikuchi";
      user.email = "sin180degree@gmail.com";
    };
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
