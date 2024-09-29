#!/bin/bash

echo "Building pysystemtrade_ecosystem"

BUILD_DIR="./build"
if [[ -d "$BUILD_DIR" ]]; then
  echo "Removing existing build directory: $BUILD_DIR"
  sudo rm -rf "$BUILD_DIR"
fi

install -d -m 2775 $BUILD_DIR
# chown :users $BUILD_DIR

CONFIG_PROJECT_NAME="pysystemtrade_config"
CONFIG_BUILD_DIR="../$CONFIG_PROJECT_NAME/build"
echo "Copying $CONFIG_PROJECT_NAME project artifacts"
if [[ ! -d "$CONFIG_BUILD_DIR" ]]; then
  echo "Error: $CONFIG_BUILD_DIR directory is missing. Build $CONFIG_PROJECT_NAME project."
  exit 1
else
  cp -r $CONFIG_BUILD_DIR/pysystemtrade_ecosystem/. "$BUILD_DIR"/
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
  cp -r "$PYSYSTEMTRADE_BUILD_DIR/." "$PYSYSTEMTRADE_DEST_DIR/"
fi

BCU_PROJECT_NAME="bc-utils"
BCU_BUILD_DIR="../$BCU_PROJECT_NAME/build"
BCU_DEST_DIR="$BUILD_DIR/$BCU_PROJECT_NAME"
echo "Copying $BCU_PROJECT_NAME project artifacts"
if [[ ! -d "$BCU_BUILD_DIR" ]]; then
  echo "Error: $BCU_BUILD_DIR directory is missing. Build $BCU_PROJECT_NAME project."
  exit 1
else
  mkdir -p "$BUILD_DIR/bc-utils"
  cp -r "$BCU_BUILD_DIR/." "$BCU_DEST_DIR/"
  cp "$BCU_DEST_DIR/env_files/$ENV"/*.env "$BUILD_DIR/env_files/$ENV"
fi

chmod -R 775 $BUILD_DIR

echo "DONE!"
