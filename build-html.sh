#!/bin/bash

mkdir -p out/html
pandoc "src/main.md" -o "out/html/main.html" --from markdown --to html5 --self-contained -F pandoc-drawio -F pandoc-crossref --citeproc
