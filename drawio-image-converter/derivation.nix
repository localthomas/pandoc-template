# SPDX-FileCopyrightText: 2022 localthomas
#
# SPDX-License-Identifier: MIT OR Apache-2.0
{ pkgs }:
let
  converter-binary = pkgs.stdenv.mkDerivation
    {
      name = "converter";
      src = ./.;
      buildInputs = [ pkgs.go ];
      buildPhase = "CGO_ENABLED=0 go build -o out/converter";
      installPhase = ''
        mkdir -p $out/bin;
        cp --verbose ./out/converter $out/bin;
      ''
      ;
    };
in
with pkgs;
pkgs.stdenv.mkDerivation
{
  name = "converter";
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin;

    echo "#!${bash}/bin/bash" > $out/bin/drawio-image-converter;
    echo 'export ELECTRON_DISABLE_SECURITY_WARNINGS="true"' >> $out/bin/drawio-image-converter;
    echo '${xvfb-run}/bin/xvfb-run ${converter-binary}/bin/converter -drawioCmd ${drawio}/bin/drawio "''$@"' >> $out/bin/drawio-image-converter;
    chmod +x $out/bin/drawio-image-converter
  ''
  ;
}
