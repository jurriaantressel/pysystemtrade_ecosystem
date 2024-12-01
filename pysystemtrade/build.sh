#!/bin/bash

echo "Building pysystemtrade"

# Output directory for processed files
DEST_DIR="./build"
if [[ -d "$DEST_DIR" ]]; then
  echo "Removing existing build directory: $DEST_DIR"
  rm -rf "$DEST_DIR"
fi
mkdir -p "$DEST_DIR"

echo "Copying pysystemtrade"
mkdir -p "$DEST_DIR"/app
mkdir -p "$DEST_DIR"/app/data/csv
cp -r ./sys*  "$DEST_DIR"/app
cp -r ./private  "$DEST_DIR"/app
cp LICENSE \
  MANIFEST.in \
  ./pyproject.toml \
  ./README.md \
  ./requirements.txt \
  ./setup.py \
  "$DEST_DIR"/app

echo "Copying configs"
CONFIG_PROJECT_NAME="pysystemtrade_config"
CONFIG_PROJECT_DIR="../$CONFIG_PROJECT_NAME"
mkdir -p "$DEST_DIR/config"
cp -r "$CONFIG_PROJECT_DIR/build/pysystemtrade/." "$DEST_DIR/config/"

echo "DONE!"
