#!/bin/bash

pandoc \
  -f markdown \
  -t html \
  --eol lf \
  --standalone \
  --css='RustOwnership.css' \
  -o $1 \
  $2
