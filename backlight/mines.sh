#!/usr/bin/bash

input="config"

while IFS= read -r line
do
  echo "$line"
  $line += 0.5
done < "$input"
