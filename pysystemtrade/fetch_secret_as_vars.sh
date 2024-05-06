#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 SECRET_PATH [PREFIX]"
    exit 1
fi

SECRET_PATH=$1
PREFIX=${2:-""}

# Execute the operation and output the export statements
vault kv get -format=json "$SECRET_PATH" | \
    jq -r '.data.data' | \
    jq --arg PREFIX "$PREFIX" -r 'to_entries[] | $PREFIX + "\(.key)=\"\(.value)\""'
   # jq --arg PREFIX "$PREFIX" -r 'to_entries[] | "export " + $PREFIX + "\(.key)=\"\(.value)\""'
