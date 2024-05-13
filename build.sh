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

# Define the path for the target environment file
TARGET_ENV_FILE="../pysystemtrade_config/build/env_files/$ENV.env"
PROJECT_DIR="../pysystemtrade_config"

# Check if the target .env file exists
if [ -f "$TARGET_ENV_FILE" ]; then
# Check if a local .env file exists
if [ -f ".env" ]; then
  if [ -L ".env" ]; then
    # If .env is a soft link, delete the link
    rm -f .env
  else
    # If .env is not a soft link, move it to .env.old, overwriting if .env.old already exists
    mv -f .env .env.old
  fi
fi

  # Attempt to link the local .env file to the target
  ln -s "$TARGET_ENV_FILE" .env
  if [ $? -ne 0 ]; then
    echo "Error: Failed to link .env to $TARGET_ENV_FILE"
    exit 1
  else
    echo "Linked .env to $TARGET_ENV_FILE"
  fi
elif [ -d "$PROJECT_DIR" ]; then
  echo "Building pysystemtrade_config project..."
  (cd "$PROJECT_DIR" && ./build.sh)
  if [ $? -ne 0 ]; then
    echo "Error: Failed to build pysystemtrade_config project."
    exit 1
  fi
else
  echo "Error: $TARGET_ENV_FILE does not exist and the project directory is missing. Please clone or check out the pysystemtrade_config project."
  exit 1
fi

# Source the .env file to get MARKET_DATA_PATH
if [ -f ".env" ]; then
  source .env
else
  echo "Error: .env file does not exist."
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

# Initialize the market data directory, pass user and group ID
./bc_utils/init_data_path.sh "$MARKET_DATA_PATH" "$USER_ID" "$GROUP_ID"
if [ $? -ne 0 ]; then
  echo "Error: Failed to initialize market data directory."
  exit 1
fi
