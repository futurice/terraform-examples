#!/bin/bash

# Exit if any of the following commands exit with non-0, and echo our commands back
set -ex

# For running npm "binaries"
PATH=$PATH:./node_modules/.bin

# Check that we're running the correct version of node
check-node-version --package

# Compile TypeScript into "temp" (defined is tsconfig.json)
tsc

# Install production dependencies under "temp"
cp package*.json temp
(cd temp && npm install --production)

# Create Lambda zipfile under "dist"
(cd temp && zip -r ../dist/lambda.zip *)

# Clean up
rm -rf temp
