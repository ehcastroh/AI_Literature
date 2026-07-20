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
        pandoc          # document conversion
        # python3       # if you process papers with scripts
      ];

      shellHook = ''
        echo "AI_Literature dev shell ready"
      '';
    };
  };
}
