{
  description = "The homepage of Yatima Inc";
 
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    hugo-theme = {
      url = "github:zerostaticthemes/hugo-hero-theme";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, hugo-theme }: 
    utils.lib.eachDefaultSystem (system:
    let
      name = "homepage-yatima-io";
      pkgs = import nixpkgs {};
      buildInputs = with pkgs; [
        hugo
        hugo-theme
      ];
      linkThemeScript = ''
        mkdir -p themes
        ln -snf "${hugo-theme}" themes/hugo-hero-theme
      '';
      project = pkgs.stdenv.mkDerivation {
        inherit name buildInputs system;
        localSystem = system;
        src = ./.;
        configurePhase = linkThemeScript;
        buildPhase = ''
          hugo
        '';
        installPhase = ''
          cp -r public $out
        '';
      };
    in
    {
      packages.${name} = project;
      defaultPackage = self.packages.${system}.${name};
      devShell = pkgs.mkShell {
        inherit buildInputs system;
        shellHook = linkThemeScript;
      };

    });
}
