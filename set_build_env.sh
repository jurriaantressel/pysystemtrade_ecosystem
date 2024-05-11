#!/bin/bash

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

# Initialize the market data directory
./bc_utils/init_data_path.sh "$MARKET_DATA_PATH"
if [ $? -ne 0 ]; then
  echo "Error: Failed to initialize market data directory."
  exit 1
fi
