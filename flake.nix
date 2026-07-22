{
  description = "AI Literature wiki";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # tools specific to this wiki project — adjust freely
        pandoc 	# document conversion
	ripgre	# fast search
	fd	# fast find
	fzf	# fuzzy finder
	jq	# json on command line
	lazygit
	nerd-fonts.hack			
      ];
      fonts.fontconfig.enable = true;
      home.sessionVariables.EDITOR = "nvim";

      shellHook = ''
        echo "AI_Literature dev shell ready"
      '';
    };
  };
}
