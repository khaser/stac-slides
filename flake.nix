{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem ( system:
    let
      pkgs = import nixpkgs { inherit system; };
      patchedFira = pkgs.fira.overrideDerivation (oldAttrs: {
          tlType = "run";
          pname = "patched-fira";
      });
      latexFonts = { pkgs = [ patchedFira ]; };
      texliveEnv = with pkgs; texlive.combine {
        inherit (texlive)
          scheme-small

          pdftex
          latexmk

          ucs

          collection-langenglish
          collection-langcyrillic

          glossaries
          glossaries-english
          glossaries-extra

          minted
          paratype

          import
          enumitem

          pgf
          pgfplots
          pgfopts

          beamer
          beamertheme-metropolis
          wrapfig

          svg

          biber # biblatex provider

          # Dependencies somehow missing
          logreq xstring fvextra ifplatform framed catchfile
          ;

        inherit latexFonts;
      };
    in {
      devShell = pkgs.mkShell {
        name = "tex slides";
        buildInputs = with pkgs; [
          texliveEnv
          liberation_ttf_v1
          python310Packages.pygments # for minted package
        ];
      };
    });
}
