{
  description = "Home Manager configuration of kikuchi";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # スキルのタグは rebuild コマンドが「公開から7日以上経った最新リリース」に書き換える
    yomiyasu = {
      url = "github:nanaism/yomiyasu/v2.5.0";
      flake = false;
    };
    natural-japanese = {
      url = "github:coji/natural-japanese/v2.0.0";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, nix-darwin, home-manager, ... }: {
    darwinConfigurations."kikuchinoMacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users."kikuchi" = import ./home.nix;
        }
      ];
    };
  };
}
