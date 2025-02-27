#!/bin/bash

# Define variables
INSTALL_DIR="$HOME/.git42"
REPO_URL="https://github.com/ababdelo/Git42.git"
ALIAS_CMD='alias git42="$HOME/.git42/git42.sh"'
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")

# Helper function to check if alias is in profile
add_alias_to_profile() {
    local profile_file="$1"
    if ! grep -q "$ALIAS_CMD" "$profile_file"; then
        echo "$ALIAS_CMD" >> "$profile_file"
        echo "Alias added to $profile_file."
    else
        echo "Alias already exists in $profile_file."
    fi
}

echo "Cloning git42 repository..."

# Clone the repository
if ! git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"; then
    echo "Error: Failed to clone repository!"
    exit 1
fi

# Check if git42.sh exists
if [[ ! -f "$INSTALL_DIR/git42.sh" ]]; then
    echo "Error: git42.sh not found in the repository!"
    exit 1
fi

# Make git42.sh executable
chmod +x "$INSTALL_DIR/git42.sh"

# Add alias to appropriate shell profile
PROFILE_FILE=""
for file in "${PROFILE_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        PROFILE_FILE="$file"
        break
    fi
done

if [[ -z "$PROFILE_FILE" ]]; then
    echo "Error: No valid shell profile found!"
    exit 1
fi

add_alias_to_profile "$PROFILE_FILE"

# Source the profile file to apply the alias immediately
echo "Sourcing $PROFILE_FILE to apply changes."
source "$PROFILE_FILE"

echo "Installation complete! Use 'git42' to run the script."
