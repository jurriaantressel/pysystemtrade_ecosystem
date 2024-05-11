#!/bin/bash

# Check if a base directory path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <base_directory>"
  exit 1
fi

BASE_DIR=$1

# Check if the base directory exists, and attempt to create it if it does not
if [ ! -d "$BASE_DIR" ]; then
  echo "Base directory '$BASE_DIR' does not exist. Attempting to create it..."
  # Try to create the directory with mkdir -p
  if ! mkdir -p "$BASE_DIR"; then
    echo "Error: Failed to create base directory '$BASE_ADDR'."
    exit 1
  else
    echo "Successfully created base directory '$BASE_DIR'."
  fi
fi

# List of subdirectories to process
declare -a subdirs=("yahoo" "ibkr" "barchart")

# Process each subdirectory
for subdir in "${subdirs[@]}"; do
  # Construct the full path to the subdirectory
  full_path="$BASE_DIR/$subdir"

  # Create the subdirectory if it doesn't exist, change owner, and set permissions
  sudo mkdir -p "$full_path" && sudo chown -R 99:100 "$full_path" && sudo chmod -R 775 "$full_path"
  echo "Processed directory: $full_path"
done
