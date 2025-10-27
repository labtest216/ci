#!/usr/bin/bash
set -e
set x

GITHUB_TOKEN=AK2LPPWLTWR6RBML6SJ6FT3I7PATA
GITHUB_URL=https://github.com/labtest216/ci
RUNNER_VERSION="2.329.0"
RUNNER_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/"
RUNNER_ZIP_NAME="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
RUNNER_DIR="./github-runner"

# Download the latest runner package
mkdir -p ${RUNNER_DIR}
cd ${RUNNER_DIR}
curl -o ${RUNNER_ZIP_NAME} -L ${RUNNER_URL}/${RUNNER_ZIP_NAME}

# Extract the installer
tar xzf ./${RUNNER_ZIP_NAME}

# Create the runner and start the configuration experience
./config.sh --url ${GITHUB_URL} --token ${GITHUB_TOKEN}
# Last step, run it!
./run.sh
