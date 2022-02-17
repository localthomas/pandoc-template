#!/bin/bash

mkdir -p out/pdf
pandoc "src/main.md" -o "out/pdf/main.pdf" --pdf-engine=lualatex --from markdown -F pandoc-drawio -F pandoc-crossref --citeproc
