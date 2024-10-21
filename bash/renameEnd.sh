#!/bin/bash

name=$1

name=$(eval echo "$name")
filename=$(basename "$name")

path=$(dirname "$name")
newName=$2

base_name=$(basename "$name" .${name##*.})  
extension="${name##*.}"                         

mv "$name" "$path/$base_name$newName.$extension"


