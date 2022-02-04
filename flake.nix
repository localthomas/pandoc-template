# SPDX-FileCopyrightText: 2022 localthomas
#
# SPDX-License-Identifier: MIT OR Apache-2.0
{
  description = "Template for Pandoc LaTeX development";

  inputs = {
    # for eachSystem function
    flake-utils.url = "github:numtide/flake-utils";
    # use flake-compat as side-effect for flake.lock file that is read by shell.nix
    # fill the flake.lock file with `nix flake lock --update-input flake-compat`
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        drawio-image-converter = import ./drawio-image-converter/derivation.nix
          {
            inherit pkgs;
          };
      in
      with pkgs;
      {
        devShell = mkShell {
          nativeBuildInputs = [
            nixpkgs-fmt
            go
            drawio-image-converter
            texlive.combined.scheme-full
            pandoc
            haskellPackages.pandoc-crossref
          ];
        };

        packages.pdf = stdenv.mkDerivation {
          name = "pdf";
          src = self;
          nativeBuildInputs = [ self.devShell.${system}.nativeBuildInputs ];
          buildPhase = ''
            ln -s ${bash}/bin/bash /bin/bash;
            #export PATH=${drawio-image-converter}/bin:$PATH;
            ./build-pdf.sh;
          '';
          installPhase = ''
            # copy PDF file(s)
            cp --verbose --recursive ./out/pdf $out;
          '';
        };

        defaultPackage = self.packages.${system}.pdf;
      }
    );
}
