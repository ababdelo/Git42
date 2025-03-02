#!/bin/bash

# Determine the directory where the script is located.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Define colors
WHITE="\033[1;37m"
GREY="\033[1;90m"
BLACK="\033[1;30m"
BROWN="\033[1;38;5;88m"
ORANGE="\033[1;38;5;208m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
MAGENTA="\033[1;35m"
PINK="\033[1;38;5;205m"
RESET="\033[0m"

# Configuration file location (always in the script directory)
CONFIG_FILE="$SCRIPT_DIR/.git42.conf"

# Default values (store user_db in script directory by default)
DEFAULT_USER_DB="$SCRIPT_DIR/.git42_users.db"
USER_DB="$DEFAULT_USER_DB"

# Check if the config file exists; if not, create it with default values.
if [ ! -f "$CONFIG_FILE" ]; then
  echo "USER_DB=$DEFAULT_USER_DB" > "$CONFIG_FILE"
fi

# Source the config file to load custom configurations.
source "$CONFIG_FILE"

# If USER_DB from config is a relative path, convert it to an absolute path using SCRIPT_DIR.
if [[ "$USER_DB" != /* ]]; then
  USER_DB="$SCRIPT_DIR/$USER_DB"
fi

# Function to get the next available user ID.
# It reads the last user ID from the database file and increments it.
# If the database is empty, it starts from "user1".
get_next_user_id() {
  # Ensure the file exists.
  if [ ! -f "$USER_DB" ]; then
    touch "$USER_DB"
  fi
  # Skip the header (first 3 lines) and get the last user row.
  local last_line
  last_line=$(tail -n +4 "$USER_DB" | tail -n 1)
  
  # If there are no user rows, start with user1.
  if [ -z "$last_line" ]; then
    echo "user1"
    return
  fi
  
  # Extract the first column (user ID) by removing the surrounding "|" and extra spaces.
  local last_user
  last_user=$(echo "$last_line" | sed -E 's/^\| *([^|]+) *\|.*/\1/')
  
  if [[ "$last_user" =~ user([0-9]+) ]]; then
    local next_id=$((BASH_REMATCH[1] + 1))
    echo "user$next_id"
  else
    echo "user1"
  fi
}


# Function to expand a path that starts with "~/"
# This ensures that SSH key paths are stored as absolute paths.
expand_path() {
  local path="$1"
  if [[ "$path" == "~/"* ]]; then
    echo "${HOME}/${path:2}"
  else
    echo "$path"
  fi
}

# Function to center text in a given field width.
center_text() {
  local text="$1"
  local width="$2"
  local text_length=${#text}

  if (( text_length >= width )); then
    # If the text is too long, you can either print it as is or truncate it.
    # Here we'll just print it as is.
    printf "%s" "$text"
  else
    local total_padding=$(( width - text_length ))
    local pad_left=$(( total_padding / 2 ))
    local pad_right=$(( total_padding - pad_left ))
    printf "%*s%s%*s" "$pad_left" "" "$text" "$pad_right" ""
  fi
}

# ---------------------------
# Command Functions
# ---------------------------

# Function to add a new user to the user database with a table-like format.
# It assigns a unique user ID and stores the username, email, and SSH key path.
add_user() {
  local USERNAME="$1"
  local EMAIL="$2"
  local KEY_PATH="$3"
  
  # Expand the SSH key path and store the absolute path.
  KEY_PATH=$(expand_path "$KEY_PATH")
  
  local USER_ID
  USER_ID=$(get_next_user_id)

  # Define fixed widths for the columns.
  local width_userid=16
  local width_username=24
  local width_email=42
  local width_keypath=64

  # Create the header if the user database is empty or doesn't exist.
  if [ ! -f "$USER_DB" ] || [ ! -s "$USER_DB" ]; then
    # Print a header border.
    echo -e "---------------------------------------------------------------------------------------------------------------------------------------------------------------" > "$USER_DB"
    echo -e "| $(center_text "User ID" $width_userid) | $(center_text "Username" $width_username) | $(center_text "Email" $width_email) | $(center_text "SSH Key Path" $width_keypath) |" >> "$USER_DB"
    echo -e "---------------------------------------------------------------------------------------------------------------------------------------------------------------" >> "$USER_DB"
  fi
  
  # Format the new user entry with centered text.
  printf "| %s | %s | %s | %s |\n" \
    "$(center_text "$USER_ID" $width_userid)" \
    "$(center_text "$USERNAME" $width_username)" \
    "$(center_text "$EMAIL" $width_email)" \
    "$(center_text "$KEY_PATH" $width_keypath)" >> "$USER_DB"
  
  echo -e "${GREEN}Success: ${WHITE}User added successfully with ID: $USER_ID${RESET}"
}

# Function to remove a user.
# If the selected user is found, it asks for user confirmation.
# If the user confirms, it removes the entry; otherwise, it cancels the operation.
remove_user() {
  local USER_ID="$1"
  # Updated regex pattern to match the table row format.
  if grep -qE "^\|[[:space:]]*${USER_ID}[[:space:]]*\|" "$USER_DB"; then
    read -p "Are you sure you want to remove user $USER_ID? (y/n): " CONFIRMATION
    if [[ "$CONFIRMATION" =~ ^[Yy]$ ]]; then
      # Remove the matching line using the updated pattern.
      sed -i -E "/^\|[[:space:]]*${USER_ID}[[:space:]]*\|/d" "$USER_DB"
      echo -e "${GREEN}Success: ${WHITE}User $USER_ID removed successfully.${RESET}"
    else
      echo -e "${YELLOW}Cancelled: ${WHITE}User removal aborted.${RESET}"
    fi
  else
    echo -e "${RED}Error: ${WHITE}User ID $USER_ID not found.${RESET}"
  fi
}

# Function to edit a user if it exists.
# Function to edit a user if it exists.
edit_user() {
  local USER_ID="$1"
  local NEW_NAME="$2"
  local NEW_EMAIL="$3"
  local NEW_KEY_PATH="$4"
  
  # Expand the SSH key path before saving.
  NEW_KEY_PATH=$(expand_path "$NEW_KEY_PATH")

  # Define fixed widths for the columns.
  local width_userid=16
  local width_username=24
  local width_email=42
  local width_keypath=64

  # Check if the user exists by matching the formatted row.
  if grep -qE "^\|[[:space:]]*${USER_ID}[[:space:]]*\|" "$USER_DB"; then
    # Construct the new formatted line using centered text.
    local new_line
    new_line=$(printf "| %s | %s | %s | %s |" \
      "$(center_text "$USER_ID" $width_userid)" \
      "$(center_text "$NEW_NAME" $width_username)" \
      "$(center_text "$NEW_EMAIL" $width_email)" \
      "$(center_text "$NEW_KEY_PATH" $width_keypath)")
    
    # Replace the matching line in the user DB.
    sed -i -E "s#^\|[[:space:]]*${USER_ID}[[:space:]]*\|.*#${new_line}#" "$USER_DB"
    echo -e "${GREEN}Success: ${WHITE}User info updated successfully for $USER_ID.${RESET}"
  else
    echo -e "${RED}Error: ${WHITE}User ID $USER_ID not found.${RESET}"
  fi
}

# Function to set up a specific user for Git operations.
# It updates Git's global config and adds the SSH key to ssh-agent.
setup_user() {
  local USER_ID="$1"
  # Use a pattern that matches the formatted table row.
  local USER_ENTRY
  USER_ENTRY=$(grep -E "^\|[[:space:]]*${USER_ID}[[:space:]]*\|" "$USER_DB")
  
  if [ -z "$USER_ENTRY" ]; then
    echo -e "${RED}Error: ${WHITE}User ID $USER_ID not found.${RESET}"
    return 1
  fi
  
  local USERNAME EMAIL KEY_PATH
  USERNAME=$(echo "$USER_ENTRY" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' | xargs)
  EMAIL=$(echo "$USER_ENTRY" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' | xargs)
  KEY_PATH=$(echo "$USER_ENTRY" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' | xargs)

  # Expand key path in case it still contains "~".
  KEY_PATH=$(expand_path "$KEY_PATH")
  
  # Verify that the SSH key file exists.
  if [ ! -f "$KEY_PATH" ]; then
    echo -e "${RED}Error: ${WHITE}Invalid SSH key path: $KEY_PATH${RESET}"
    return 1
  fi
  
  # Ensure ssh-agent is running.
  if [ -z "$SSH_AUTH_SOCK" ]; then
      echo -e "${RED}Error: ${WHITE}No ssh-agent detected. Please start ssh-agent before running this script.${RESET}"
      return 1
  fi
  
  # Remove previously added SSH keys.
  ssh-add -D
  
  # Add the key to the running ssh-agent.
  ssh-add "$KEY_PATH" &>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${RED}Error: ${WHITE}Failed to add SSH key to agent. Please check if it's a valid key.${RESET}"
    return 1
  fi
  
  # Update Git's global configuration.
  git config --global user.name "$USERNAME"
  git config --global user.email "$EMAIL"
  echo -e "${GREEN}Success:${WHITE} Git has been successfully configured for user ${USERNAME} (${USER_ID}), with the corresponding SSH key set up.${RESET}"
}

# Function to configure settings.
config() {
  if [ -z "$2" ]; then
    echo -e "${RED}Error: ${WHITE}Missing options. To know the usage, use the help command.${RESET}"
    exit 1
  fi
  local setting="$1"
  local value="$2"
  
  if [ "$setting" == "user_db" ]; then
    local new_path
    # If the provided value is not absolute, convert it relative to SCRIPT_DIR.
    if [[ "$value" != /* ]]; then
      new_path=$(realpath -m "$SCRIPT_DIR/$value" 2>/dev/null || echo "$SCRIPT_DIR/$value")
    else
      new_path=$(realpath -m "$value" 2>/dev/null || echo "$value")
    fi
    
    # If the new user_db file does not exist, move the old one (if present) to the new path.
    if [ ! -f "$new_path" ]; then
      if [ -f "$USER_DB" ]; then
        mv "$USER_DB" "$new_path"
        echo -e "${YELLOW}Info: ${WHITE}Moved old user_db to new path: $new_path${RESET}"
      else
        touch "$new_path"
        echo -e "${YELLOW}Info: ${WHITE}Created new user_db at: $new_path${RESET}"
      fi
    fi
    echo "USER_DB=$new_path" > "$CONFIG_FILE"
    USER_DB="$new_path"
    echo -e "${GREEN}Success: ${WHITE}User database path updated to $USER_DB${RESET}"
  else
    echo -e "${RED}Error: ${WHITE}Invalid setting. Valid settings are: user_db.${RESET}"
  fi
}

# Function to display help message.
show_help() {
  echo -e "${GREEN}git42 ${WHITE}Manage multiple GitHub identities with ease.${RESET}"
  echo -e "${BLUE}Usage:${RESET} git42 <command> [options]${RESET}"
  echo -e ""
  echo -e "${WHITE}Available commands:${RESET}"
  echo -e ""
  echo -e "${GREEN}  add    - ${RESET}Register a new Git user with a unique ID"
  echo -e "         ${GREEN}Example:${WHITE} git42 add${RESET}"
  echo -e "                   (You will be prompted to enter user name, user email, and SSH key path)"
  echo -e "${RED}  rm     - ${RESET}Delete a registered user by their unique ID"
  echo -e "         ${RED}Example:${WHITE} git42 rm${RESET}"
  echo -e "                   (You will be prompted to enter the user ID and confirm deletion)"
  echo -e "${YELLOW}  edit   - ${RESET}Modify user details such as name, email, or SSH key"
  echo -e "         ${YELLOW}Example:${WHITE} git42 edit <user id>${RESET}"
  echo -e "                   (You will be prompted to enter new values; press enter to keep current values)"
  echo -e "${BLUE}  setup  - ${RESET}Activate a registered user for Git operations"
  echo -e "         ${BLUE}Example:${WHITE} git42 setup <user id>${RESET}"
  echo -e "${ORANGE}  config - ${RESET}Customize git42 settings (e.g., change user database path)"
  echo -e "         ${ORANGE}Example:${WHITE} git42 config user_db <new user db path>${RESET}"
  echo -e "${PINK}  list   - ${RESET}List all registered users"
  echo -e "         ${PINK}Example:${WHITE} git42 list${RESET}"
  echo -e "${MAGENTA}  active - ${RESET}Show the currently active Git user"
  echo -e "         ${MAGENTA}Example:${WHITE} git42 active${RESET}"
  echo -e "${CYAN}  help   - ${RESET}Show this help message with available commands"
  echo -e "         ${CYAN}Example:${WHITE} git42 help${RESET}"
  exit 0
}

# Function to list all stored users in a simplified format.
list_users() {
  if [ ! -f "$USER_DB" ] || [ ! -s "$USER_DB" ]; then
    echo -e "${YELLOW}No users found.${RESET}"
    return
  fi

  echo -e "${WHITE}Stored Git Identities:${RESET}"
  
  # Process the user rows (skip the header lines from the user_db file).
  tail -n +4 "$USER_DB" | while IFS='|' read -r empty user username email key dummy; do
    # Trim extra spaces from each field using xargs.
    user=$(echo "$user" | xargs)
    username=$(echo "$username" | xargs)
    
    # Output the simplified format: "userID Identified as username"
    echo -e "- ${BLUE}$user ${WHITE}Identified as ${GREEN}$username${RESET}"
  done
}

# Function to display the active (setup) user.
active_user() {
  local active_name active_email user_id
  
  # Check if SSH agent has any identities
  ssh_key_check=$(ssh-add -l 2>/dev/null)
  if [ -z "$ssh_key_check" ]; then
    # If no SSH key is loaded, show the missing key message
    echo -e "${YELLOW}No SSH key is loaded for the active Git user.${RESET}"
    return 1
  fi

  # Get the current Git configuration for user name and email
  active_name=$(git config --global user.name)
  active_email=$(git config --global user.email)

  # If either name or email is not set, notify the user
  if [ -z "$active_name" ] || [ -z "$active_email" ]; then
    echo -e "${YELLOW}No active Git user is configured.${RESET}"
    return 1
  fi

  # Find the user ID from the user_db based on the active email
  user_id=$(grep -i "$active_email" "$USER_DB" | cut -d '|' -f 2 | xargs)

  # If no matching user ID is found, notify the user
  if [ -z "$user_id" ]; then
    echo -e "${YELLOW}User ID not found for $active_email.${RESET}"
    return 1
  fi

  # Display the active user information
  echo -e "${WHITE}The active Git user is: ${BLUE}$user_id${RESET}"
  echo -e "${WHITE}Identified as: ${GREEN}$active_name${RESET}"
}

# ---------------------------
# Main Logic
# ---------------------------
if [ -z "$1" ] || [ "$1" == "help" ]; then
  show_help
fi

case $1 in
  add)
    shift
    # Interactive input for add command if parameters are missing.
    if [ -z "$1" ]; then
      read -p "Enter user name: " USERNAME
    else
      USERNAME="$1"
    fi
    if [ -z "$2" ]; then
      read -p "Enter user email: " EMAIL
    else
      EMAIL="$2"
    fi
    if [ -z "$3" ]; then
      read -p "Enter SSH key path: " KEY_PATH
    else
      KEY_PATH="$3"
    fi
    if [ -z "$USERNAME" ] || [ -z "$EMAIL" ] || [ -z "$KEY_PATH" ]; then
      echo -e "${RED}Error: ${WHITE}Missing required information. To know the usage, use the help command.${RESET}"
      exit 1
    fi
    add_user "$USERNAME" "$EMAIL" "$KEY_PATH"
    ;;
  rm)
    shift
    if [ -z "$1" ]; then
      read -p "Enter user ID to remove: " USER_ID
    else
      USER_ID="$1"
    fi
    if [ -z "$USER_ID" ]; then
      echo -e "${RED}Error: ${WHITE}Missing user ID. To know the usage, use the help command.${RESET}"
      exit 1
    fi
    remove_user "$USER_ID"
    ;;
  edit)
    shift
    if [ -z "$1" ]; then
      read -p "Enter user ID to edit: " USER_ID
    else
      USER_ID="$1"
    fi

    # Retrieve the current entry using the updated regex.
    CURRENT_ENTRY=$(grep -E "^\|[[:space:]]*${USER_ID}[[:space:]]*\|" "$USER_DB")
    if [ -z "$CURRENT_ENTRY" ]; then
      echo -e "${RED}Error: ${WHITE}User ID $USER_ID not found.${RESET}"
      exit 1
    fi

    # Extract and trim each field.
    CURRENT_NAME=$(echo "$CURRENT_ENTRY" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' | xargs)
    CURRENT_EMAIL=$(echo "$CURRENT_ENTRY" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' | xargs)
    CURRENT_KEY=$(echo "$CURRENT_ENTRY" | sed -E 's/^\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|[[:space:]]*([^|]+)[[:space:]]*\|.*/\1/' | xargs)

    read -p "Enter new user name (current: $CURRENT_NAME): " NEW_NAME
    read -p "Enter new user email (current: $CURRENT_EMAIL): " NEW_EMAIL
    read -p "Enter new SSH key path (current: $CURRENT_KEY): " NEW_KEY_PATH

    # Keep current values if input is empty.
    [ -z "$NEW_NAME" ] && NEW_NAME="$CURRENT_NAME"
    [ -z "$NEW_EMAIL" ] && NEW_EMAIL="$CURRENT_EMAIL"
    [ -z "$NEW_KEY_PATH" ] && NEW_KEY_PATH="$CURRENT_KEY"

    edit_user "$USER_ID" "$NEW_NAME" "$NEW_EMAIL" "$NEW_KEY_PATH"
    ;;
  setup)
    shift
    # For setup, require the user id to be passed as an option.
    if [ -z "$1" ]; then
      echo -e "${RED}Error: ${WHITE}Missing user ID. To know the usage, use the help command.${RESET}"
      exit 1
    fi
    USER_ID="$1"
    setup_user "$USER_ID"
    ;;
  config)
    shift
    if [ -z "$1" ] || [ -z "$2" ]; then
      echo -e "${RED}Error: ${WHITE}Missing options. To know the usage, use the help command.${RESET}"
      exit 1
    fi
    config "$@"
    ;;
  list)
    list_users
    ;;
  active)
    active_user
    ;;
  *)
    echo -e "${RED}Error: ${WHITE}Invalid command: $1.${RESET}"
    exit 1
    ;;
esac
