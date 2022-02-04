#!/bin/bash

drawio-image-converter -inputFolder ./src/graphics/drawio -outputFolder ./src/graphics/drawio
mkdir -p out/pdf
pandoc "src/main.md" -o "out/pdf/main.pdf" --from markdown -F pandoc-crossref --citeproc
