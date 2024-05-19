#!/bin/bash

# Function to check environment variables and issue warnings
check_env_var() {
  local var_name="$1"

  # Check if the variable is set
  if [ -z "${!var_name}" ]; then
    echo "Error: $var_name is not set. Please set this environment variable." >&2

    # Check if running as superuser and the variable is missing
    if [ "$(id -u)" -eq 0 ]; then
      echo "Notice: Running as superuser. If $var_name is set in your usual environment, consider using 'sudo -E' to preserve it." >&2
    fi

    exit 1
  fi
}

# Check both VAULT_ADDR and VAULT_TOKEN
check_env_var "VAULT_ADDR"
check_env_var "VAULT_TOKEN"

# Check for command-line argument and use it to override ENV if provided
if [ ! -z "$1" ]; then
  ENV="$1"
elif [ -z "$ENV" ]; then
  echo "Error: ENV variable is not set and no command-line argument provided."
  exit 1
fi

create_link() {
  local target_file="$1"
  local link_name="$2"
  local target_dir="$3"

  # Check if a local .env file exists
  if [ -f "$link_name" ]; then
    if [ -L "$link_name" ]; then
      # If .env is a soft link, delete the link
      rm -f "$link_name"
    else
      # If .env is not a soft link, move it to .env.old, overwriting if .env.old already exists
      mv -f "$link_name" "$link_name".old
    fi
  fi
  # Attempt to link the local .env file to the target
  # Extract the directory path
  local path=$(dirname "$link_name")
  mkdir -p "$path"
  ln -s "$target_file" "$link_name"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to link $link_name to $target_file"
    exit 1
  else
    echo "Linked $link_name to $target_file"
  fi
}

copy_file() {
  local source_file="$1"
  local destination_file="$2"
  local destination_dir="$3"

  # Check if a local destination file exists
  if [ -f "$destination_file" ]; then
    if [ -L "$destination_file" ]; then
      # If it is a soft link, delete the link
      echo "Removing existing symlink: $destination_file"
      rm -f "$destination_file"
    else
      # If it is not a soft link, move it to .old, overwriting if .old already exists
      echo "Moving existing file to $destination_file.old"
      mv -f "$destination_file" "$destination_file.old"
    fi
  fi

  # Ensure the directory for the destination file exists
  local path=$(dirname "$destination_file")
  mkdir -p "$path"

  # Copy the source file to the destination
  cp "$source_file" "$destination_file"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to copy $source_file to $destination_file"
    exit 1
  else
    echo "Copied $source_file to $destination_file"
  fi
}


# Define the path for the target environment file
CONFIG_PROJECT_NAME="pysystemtrade_config"
CONFIG_PROJECT_DIR="../$CONFIG_PROJECT_NAME"
CONFIG_PROJECT_ARTIFACT_DIR="$CONFIG_PROJECT_DIR/build/$ENV"
TARGET_ENV_FILE="$CONFIG_PROJECT_ARTIFACT_DIR/.env"
TARGET_PRIVATE_FILE="$CONFIG_PROJECT_ARTIFACT_DIR/pysystemtrade/private_config.yaml"

# Check if the target .env file exists
if [[ -f $TARGET_ENV_FILE && -f $TARGET_PRIVATE_FILE ]]; then
  create_link "$TARGET_ENV_FILE" ".env" "."

  rm -rf "./build/pysystemtrade"
  cp -ra ../pysystemtrade "./build/"
  copy_file "$TARGET_PRIVATE_FILE" "./build/pysystemtrade/private/private_config.yaml"

  rm -rf "./build/bc-utils"
  mkdir -p "./build/bc-utils/configs/"
  cp -ra ../bc-utils "./build/"
  cp -ra "$CONFIG_PROJECT_ARTIFACT_DIR"/bc-utils/*.* "./build/bc-utils/configs/"

elif [ -d "$CONFIG_PROJECT_DIR" ]; then
  echo "Building $CONFIG_PROJECT_NAME project..."
  (cd "$CONFIG_PROJECT_DIR" && ./build.sh)
  if [ $? -ne 0 ]; then
    echo "Error: Failed to build $CONFIG_PROJECT_NAME project."
    exit 1
  fi
else
  echo "Error: $CONFIG_PROJECT_DIR directory is missing. Please clone or check out the $CONFIG_PROJECT_NAME project."
  exit 1
fi

