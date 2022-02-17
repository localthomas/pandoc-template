#!/bin/bash

mkdir -p out/pdf
pandoc "src/main.md" -o "out/pdf/main.pdf" --from markdown -F pandoc-drawio -F pandoc-crossref --citeproc
