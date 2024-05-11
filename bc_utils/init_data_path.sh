#!/bin/bash

# Check if a base directory path is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <base_directory> [user_id] [group_id]" >&2
  exit 1
fi

BASE_DIR=$1
USER_ID=${2:-99}   # Fallback to 99 if not provided
GROUP_ID=${3:-100} # Fallback to 100 if not provided

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
    fi
  fi

  # Check and set permissions only if needed
  current_perms=$(stat -c "%a" "$full_path")
  desired_perms="775"
  if [ "$current_perms" != "$desired_perms" ]; then
    if ! chmod -R $desired_perms "$full_path"; then
      echo "Failed to set permissions for $full_path to $desired_perms" >&2
      exit 1
    fi
  fi

  echo "Processed directory: $full_path"
done
