# SPDX-FileCopyrightText: 2022 localthomas
#
# SPDX-License-Identifier: MIT OR Apache-2.0
{
  description = "Template for Pandoc Markdown development";

  inputs = {
    # for eachSystem function
    flake-utils.url = "github:numtide/flake-utils";
    # use flake-compat as side-effect for flake.lock file that is read by shell.nix
    # fill the flake.lock file with `nix flake lock --update-input flake-compat`
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    pandoc-drawio = {
      url = "github:localthomas/pandoc-drawio";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pandoc-drawio, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        pandoc-drawio-bin = pandoc-drawio.defaultPackage.${system};
      in
      with pkgs;
      {
        devShell = mkShell {
          nativeBuildInputs = [
            nixpkgs-fmt
            go
            texlive.combined.scheme-full
            pandoc-drawio-bin
            pandoc
            librsvg
            haskellPackages.pandoc-crossref
          ];
        };

        packages.pdf = stdenv.mkDerivation {
          name = "pdf";
          src = self;
          nativeBuildInputs = [ self.devShell.${system}.nativeBuildInputs ];
          buildPhase = ''
            ln -s ${bash}/bin/bash /bin/bash;
            ./build-pdf.sh;
          '';
          installPhase = ''
            # copy PDF file(s)
            mkdir -p $out/pdf
            cp --verbose --recursive ./out/pdf $out;
          '';
        };

        packages.html = stdenv.mkDerivation {
          name = "html";
          src = self;
          nativeBuildInputs = [ self.devShell.${system}.nativeBuildInputs ];
          buildPhase = ''
            ln -s ${bash}/bin/bash /bin/bash;
            ./build-html.sh;
          '';
          installPhase = ''
            # copy HTML file(s)
            mkdir -p $out/html
            cp --verbose --recursive ./out/html $out;
          '';
        };

        # merge PDF and HTML outputs
        defaultPackage = stdenv.mkDerivation {
          name = "pdf-and-html";
          src = self;
          installPhase = ''
            # copy HTML file(s)
            mkdir -p $out/html
            cp --verbose --recursive ${self.packages.${system}.html}/html $out;
            # copy PDF file(s)
            mkdir -p $out/pdf
            cp --verbose --recursive ${self.packages.${system}.pdf}/pdf $out;
          '';
        };
      }
    );
}
