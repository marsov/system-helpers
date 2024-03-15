#!/bin/bash

# This script is used to calculate the SHA256 hash of a file and compare it with the expected hash.
# Usage: ./sha256.sh <file> <expected hash>

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "File not found!"
  exit 1
fi

# Calculate the SHA256 hash of the file
hash=$(shasum -a 256 "$1" | awk '{print $1}')

# Compare the calculated hash with the expected hash
if [ "$hash" = "$2" ]; then
  echo "Hash matches!"
else
  echo "Hash does not match!"
fi
