#!/bin/bash

# This script duplicates a GitHub environment from a source repository to a destination repository.
# It copies environment variables (names and values) and lists environment secrets (names only, as values cannot be retrieved).
# Secrets values cannot be automatically copied because GitHub does not allow reading secret values via API or CLI.
# You will need to manually set the secret values in the destination environment after running this script.

# Assumptions:
# - Input variables are set as environment variables.
# - The script runs in a GitHub Actions runner or similar environment.
# - Tokens have necessary permissions: repo, read:org for source; repo for destination.

# Check OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)
echo "Operating System: $OS"
echo "Architecture: $ARCH"

# Install necessary tools based on OS
if [ "$OS" = "Linux" ]; then
    # Install jq if not present
    if ! command -v jq &> /dev/null; then
        sudo apt update -y
        sudo apt install -y jq tee
    fi
    # Install gh (GitHub CLI) if not present
    if ! command -v gh &> /dev/null; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/githubcli.list > /dev/null
        sudo apt update -y
        sudo apt install -y gh
    fi
elif [ "$OS" = "Darwin" ]; then
    # Assuming MacOS with Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install jq gh tee
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# Src
github_org_name_src=FarmersPOS
github_rep_name_src=frontend
github_token_src=
github_rep_env_src=DEV

# Des
github_org_name_des=FarmersPOS
github_rep_name_des=app
github_token_des=
github_rep_env_des=DEV

# Set repo full names
SRC_REPO="$github_org_name_src/$github_rep_name_src"
DES_REPO="$github_org_name_des/$github_rep_name_des"
SEC_JSON_PATH=/tmp/src_secrets.json
ENV_JSON_PATH=/tmp/src_variables.json

# Use source token for source operations
export GH_TOKEN="$github_token_src"

# Get environment secrets names (values cannot be retrieved)
gh secret list --repo "$SRC_REPO" --env "$github_rep_env_src" --json name | tee ${SEC_JSON_PATH}
# Get environment variables names and values
gh variable list --repo "$SRC_REPO" --env "$github_rep_env_src" --json name,value | tee ${ENV_JSON_PATH}
echo "###### ENV VARIABLES FROM SOURCE ${ENV_JSON_PATH} ######"
cat ${ENV_JSON_PATH}
echo "######################################"
echo "###### ENV SECRETS FROM SOURCE ${SEC_JSON_PATH} ######"
cat ${SEC_JSON_PATH}
echo "######################################"

# Switch to destination token
export GH_TOKEN="$github_token_des"

# Create the destination environment if it doesn't exist
echo "Creating environment ${github_rep_env_des} in ${DES_REPO}"
gh api \
  --method PUT \
  "repos/${DES_REPO}/environments/${github_rep_env_des}" \
  --silent

# Set environment variables in destination
echo "############ ${DES_REPO} ${github_rep_env_des} ############"
jq -r -c '.[]' "${ENV_JSON_PATH}" | while read -r var; do
    name=$(echo "$var" | jq -r '.name')
    value=$(echo "$var" | jq -r '.value')
    gh variable set "$name" --body "$value" --repo "$DES_REPO" --env "$github_rep_env_des"
done
echo "##############################################"

# Set environment secrets in destination
echo "############ ${DES_REPO} ${github_rep_env_des} ############"
jq -r -c '.[]' "${SEC_JSON_PATH}" | while read -r var; do
    name=$(echo "$var" | jq -r '.name')
    value="NA"
    gh secret set "$name" --body "$value" --repo "$DES_REPO" --env "$github_rep_env_des"
done

# Clean up JSON files if desired
rm ${SEC_JSON_PATH} ${ENV_JSON_PATH}