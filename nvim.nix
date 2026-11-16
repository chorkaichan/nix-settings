{ config, pkgs, ... }:
let
  nvimConfigDir = "${config.home.homeDirectory}/.config/home-manager/nvim";
in
{
  home.packages = with pkgs; [
    neovim

    # LazyVim本体・プラグインが使うツール
    lazygit                # lazygit.nvim（lg）
    ripgrep                # Telescopeの検索
    fd                     # Telescopeのファイル検索
    fzf
    tree-sitter            # treesitterパーサーのビルド

    # Mason経由で入るLSP・フォーマッタのランタイム
    nodejs                 # Copilot、tailwind/svelte/prisma/eslint/prettier等
    python3                # lang.sql（sqlfluff）
    php
    phpPackages.composer   # lang.php（phpactor）
  ];

  home.sessionVariables.EDITOR = "nvim";

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
  };

  # リポジトリ内のnvim/を ~/.config/nvim として直接リンク
  # （lazy-lock.jsonなどをNeovim側から書き込めるようにするため）
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink nvimConfigDir;
}
