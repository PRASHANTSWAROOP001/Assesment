#!/bin/bash

OUTPUT_FILE='schema.tsv'

curl -s https://portal.amfiindia.com/spages/NAVAll.txt \
 | awk -F ';' 'NF >= 5 {print $4 "\t" $5}' \
 > "$OUTPUT_FILE"

echo "saved the file inside the address $OUTPUT_FILE"
   