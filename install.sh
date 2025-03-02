#!/bin/bash
# Git42 Installer - Fixed Hanging Issue on Reinstall

# Function Definitions
smooth_update_progress() {
  local target=$1
  local message=$2
  local current=$(awk -F'|' '{print $1}' "$TMPFILE" 2>/dev/null)
  [ -z "$current" ] && current=0
  while [ "$current" -lt "$target" ]; do
    current=$(( current + 1 ))
    echo "${current}|${message}" > "$TMPFILE"
    sleep 0.05
  done
}

progress_bar_updater() {
  local LAST_PRINTED=""
  while true; do
    if [ -f "$TMPFILE" ] && [ -s "$TMPFILE" ]; then
      IFS="|" read progress message < "$TMPFILE"
      progress=${progress:-0}  # Default to 0 if empty
    else
      progress=0
      message=" Initializing..."
    fi

    local width=50
    local filled=$(( progress * width / 100 ))
    local empty=$(( width - filled ))
    local elapsed_time=$(( $(date +%s) - start_time ))
    local minutes=$(( elapsed_time / 60 ))
    local seconds=$(( elapsed_time % 60 ))
    local time_str=$(printf "%02d:%02d" $minutes $seconds)

    # Format output
    local new_line
    new_line=$(printf "  %-25s [%-${width}s] ${YELLOW}%d%%${NC}  ${time_str}" \
                "$message" \
                "$(printf '#%.0s' $(seq 1 $filled))$(printf ' %.0s' $(seq 1 $empty))" \
                "$progress")

    if [ "$new_line" != "$LAST_PRINTED" ]; then
      LAST_PRINTED="$new_line"
      printf "\r\033[K%s" "$new_line"
    fi

    sleep 0.1
  done
}

spinner_updater() {
  local spinner=(" ⠋ " " ⠙ " " ⠹ " " ⠸ " " ⠼ " " ⠴ " " ⠦ " " ⠧ " " ⠇ " " ⠏ ")
  local spinner_index=0
  while [ -f "$TMPFILE" ]; do
    printf "\r%s" "${spinner[$spinner_index]}"
    spinner_index=$(( (spinner_index + 1) % ${#spinner[@]} ))
    sleep 0.05  # Fast independent spin
  done
}

# Main Script Logic
INSTALL_DIR="$HOME/.git42"
REPO_URL="https://github.com/ababdelo/Git42.git"
ALIAS_CMD='alias git42="$HOME/.git42/git42.sh"'
PROFILE_FILES=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")

# ANSI colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Start timer
start_time=$(date +%s)

# Handle existing installation
if [ -d "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Git42 is already installed.${NC}"
  read -p "Do you want to (U)pdate, (R)emove & reinstall, or (S)kip? [U/r/s]: " choice
  case "$choice" in
    [Uu]* ) 
      echo -e "${BLUE}Updating Git42...${NC}"
      cd "$INSTALL_DIR" && git pull origin main > /dev/null 2>&1
      echo -e "${GREEN}Update complete!${NC}"
      exit 0 ;;
    [Rr]* ) 
      echo -e "${RED}Removing old installation...${NC}"
      
      # Kill progress bar & spinner before removing the folder
      if [[ -n "$PROGRESS_PID" ]]; then kill "$PROGRESS_PID" 2>/dev/null; fi
      if [[ -n "$SPINNER_PID" ]]; then kill "$SPINNER_PID" 2>/dev/null; fi

      rm -rf "$INSTALL_DIR"
      echo -e "${GREEN}Old installation removed!${NC}"
      ;;
    [Ss]* | "" ) 
      echo -e "${YELLOW}Skipping installation.${NC}"
      exit 0 ;;
    * ) 
      echo -e "${RED}Invalid option. Aborting.${NC}"
      exit 1 ;;
  esac
fi

# Create progress tracking
TMPFILE=$(mktemp /tmp/progress.XXXXXX)
cleanup() { rm -f "$TMPFILE"; }
trap cleanup EXIT

# Start progress bar and spinner
progress_bar_updater &
PROGRESS_PID=$!
spinner_updater &
SPINNER_PID=$!

smooth_update_progress 10 " Checking for updates..."
smooth_update_progress 20 " Cloning repository..."
git clone --depth=1 "$REPO_URL" "$INSTALL_DIR" > /dev/null 2>&1 &
CLONE_PID=$!

# Fill progress smoothly to 25% while cloning
current=20
while kill -0 $CLONE_PID 2>/dev/null; do
  if [ "$current" -lt 25 ]; then
    current=$(( current + 1 ))
    echo "${current}| Cloning repository..." > "$TMPFILE"
  fi
  sleep 0.05
done

smooth_update_progress 25 " Cloning complete"

wait $CLONE_PID || {
  echo "0|${RED} Failed to clone repository!${NC}" > "$TMPFILE"
  kill $PROGRESS_PID $SPINNER_PID
  printf "\r\033[K"
  echo -e "${RED} Installation aborted!${NC}"
  exit 1
}

# Verify script exists
if [[ ! -f "$INSTALL_DIR/git42.sh" ]]; then
  smooth_update_progress 0 "${RED}git42.sh not found!${NC}"
  kill $PROGRESS_PID $SPINNER_PID
  printf "\r\033[K"
  echo -e "${RED}Installation aborted: Missing git42.sh!${NC}"
  exit 1
fi

smooth_update_progress 50 " Setting up Git42..."
chmod +x "$INSTALL_DIR/git42.sh"

smooth_update_progress 75 "Configuring alias..."
# Append the alias only if it's not already present.
for file in "${PROFILE_FILES[@]}"; do
  if [[ -f "$file" ]] && ! grep -Fxq "$ALIAS_CMD" "$file"; then
    echo "$ALIAS_CMD" >> "$file"
  fi
done

# Source profiles
for file in "${PROFILE_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    source "$file" > /dev/null 2>&1
  fi
done

smooth_update_progress 100 " Finalizing installation..."

# Stop progress and spinner
kill $PROGRESS_PID $SPINNER_PID
printf "\r\033[K"

# Show install time
end_time=$(date +%s)
time_taken=$((end_time - start_time))

echo -e "${GREEN}🎉 Installation complete! Use 'git42' to run the script.${NC}"
echo -e "${YELLOW}🚀 Done in ${time_taken}s.${NC}"