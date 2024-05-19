#!/bin/bash

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

env_file=$SCRIPT_DIR/../.env

# Source the .env file to get MARKET_DATA_PATH
if [ -f "$env_file" ]; then
  source $env_file
else
  echo "Error: $env_file file does not exist."
  exit 1
fi

# Check if the MARKET_DATA_PATH variable is set
if [ -z "$MARKET_DATA_PATH" ]; then
  echo "Error: MARKET_DATA_PATH variable is not set."
  exit 1
fi

# Default user and group ID
USER_ID=${USER_ID:-99}   # Fallback to 99 if not provided in .env file
GROUP_ID=${GROUP_ID:-100} # Fallback to 100 if not provided in .env file
BASE_DIR=$MARKET_DATA_PATH

# Check if the base directory exists, and attempt to create it if it does not
if [ ! -d "$BASE_DIR" ]; then
  echo "Base directory '$BASE_DIR' does not exist. Attempting to create it..."
  if ! mkdir -p "$BASE_DIR"; then
    echo "Error: Failed to create base directory '$BASE_DIR'."
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

  # Create the subdirectory if it doesn't exist
  if ! mkdir -p "$full_path"; then
    echo "Failed to create $full_path" >&2
    exit 1
  fi

  # Check and change owner only if needed
  current_owner=$(stat -c "%u:%g" "$full_path")
  desired_owner="$USER_ID:$GROUP_ID"
  if [ "$current_owner" != "$desired_owner" ]; then
    if ! chown -R $desired_owner "$full_path"; then
      echo "Failed to set ownership for $full_path to $desired_owner" >&2
      exit 1
    else
      echo "Changed ownership of $full_path to $desired_owner"
    fi
  fi

  # Check and set permissions only if needed
  current_perms=$(stat -c "%a" "$full_path")
  desired_perms="775"
  if [ "$current_perms" != "$desired_perms" ]; then
    if ! chmod -R $desired_perms "$full_path"; then
      echo "Failed to set permissions for $full_path to $desired_perms" >&2
      exit 1
    else
      echo "Set permission of $full_path to $desired_perms"
    fi
  fi

  echo "Processed directory: $full_path"
done
