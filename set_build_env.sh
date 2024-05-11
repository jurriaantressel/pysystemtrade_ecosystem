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

# Interpolate variables into the .env file from the specified environment file
./scripts/interpolate_vars.sh "../pysystemtrade_config/env_files/$ENV.env" .env
if [ $? -ne 0 ]; then
  echo "Error: Failed to interpolate variables."
  exit 1
fi

# Source the .env file to get MARKET_DATA_PATH
if [ -f ".env" ]; then
  source .env
else
  echo "Error: .env file does not exist after interpolation."
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
