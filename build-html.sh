#!/bin/bash

drawio-image-converter -inputFolder ./src/graphics/drawio -outputFolder ./src/graphics/drawio
mkdir -p out/html
pandoc "src/main.md" -o "out/html/main.html" --from markdown --to html5 --self-contained -F pandoc-crossref --citeproc
