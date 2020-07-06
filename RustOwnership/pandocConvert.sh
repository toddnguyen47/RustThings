#!/bin/bash

# Usage
# ./pandocConvert.sh <output_file> <input_file>
# e.g.
# ./pandocConvert.sh index.html RustOwnership.md

pandoc \
  -f markdown \
  -t html \
  --eol lf \
  --standalone \
  --css='RustOwnership.css' \
  -o $1 \
  $2
