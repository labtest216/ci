#!/bin/bash
set -e

# Utils functions.
debug_print() {
    local msg="$1"
    echo "################################################"
    echo "######### $msg #########"
    echo "################################################"
}

# Set default.
LOCAL="true"
VALUES_GROUP_SERVICE="false"
VALUES_GROUP_SERVICE_BACKEND_FILE="backend-values.yaml"

# Parse arguments.
usage() {
    debug_print "TEMPLATE SERVICE"
    echo "default: --local true"
    echo "options:"
    echo "  --local <true|false>"
    echo "  --aws-eks-ns  <dev|prd>"
    echo "  --service-name>"
    exit 1
}