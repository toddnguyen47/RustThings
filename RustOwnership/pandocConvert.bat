pandoc ^
  -f markdown ^
  -t html ^
  --eol lf ^
  --standalone ^
  -o %1 ^
  %2
