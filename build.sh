#!/bin/bash

echo "Building pysystemtrade_ecosystem"

BUILD_DIR="./build"
if [[ -d "$BUILD_DIR" ]]; then
  echo "Removing existing build directory: $BUILD_DIR"
  rm -rf "$BUILD_DIR"
fi

CONFIG_PROJECT_NAME="pysystemtrade_config"
CONFIG_BUILD_DIR="../$CONFIG_PROJECT_NAME/build"
echo "Copying $CONFIG_PROJECT_NAME project artifacts"
if [[ ! -d "$CONFIG_BUILD_DIR" ]]; then
  echo "Error: $CONFIG_BUILD_DIR directory is missing. Build $CONFIG_PROJECT_NAME project."
  exit 1
else
  cp -ra $CONFIG_BUILD_DIR/pysystemtrade_ecosystem/. "$BUILD_DIR"/
  rm .env
  ln -s ./build/env_files/$ENV/compose.env .env
fi

PYSYSTEMTRADE_PROJECT_NAME="pysystemtrade"
PYSYSTEMTRADE_BUILD_DIR="../$PYSYSTEMTRADE_PROJECT_NAME/build"
PYSYSTEMTRADE_DEST_DIR="$BUILD_DIR/$PYSYSTEMTRADE_PROJECT_NAME"
echo "Copying $PYSYSTEMTRADE_PROJECT_NAME project artifacts"
if [[ ! -d "$PYSYSTEMTRADE_BUILD_DIR" ]]; then
  echo "Error: $PYSYSTEMTRADE_BUILD_DIR directory is missing. Build $PYSYSTEMTRADE_PROJECT_NAME project."
  exit 1
else
  mkdir -p "$PYSYSTEMTRADE_DEST_DIR"
  cp -ra "$PYSYSTEMTRADE_BUILD_DIR/." "$PYSYSTEMTRADE_DEST_DIR/"
fi

BC_UTILS_PROJECT_NAME="bc-utils"
BC_UTILS_BUILD_DIR="../$BC_UTILS_PROJECT_NAME/build"
BC_UTILS_DEST_DIR="$BUILD_DIR/$BC_UTILS_PROJECT_NAME"
echo "Copying $BC_UTILS_PROJECT_NAME project artifacts"
if [[ ! -d "$BC_UTILS_BUILD_DIR" ]]; then
  echo "Error: $BC_UTILS_BUILD_DIR directory is missing. Build $BC_UTILS_PROJECT_NAME project."
  exit 1
else
  mkdir -p "$BUILD_DIR/bc-utils"
  cp -ra "$BC_UTILS_BUILD_DIR/." "$BC_UTILS_DEST_DIR/"
fi

echo "DONE!"
