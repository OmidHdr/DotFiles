#!/bin/bash

name=$1

name=$(eval echo "$name")
filename=$(basename "$name")

path=$(dirname "$name")
newName=$2

mv "$name" "$path/$newName$filename"


