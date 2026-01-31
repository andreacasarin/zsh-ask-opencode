: ${ASK_OPENCODE_MODEL:="github-copilot/gpt-5-mini"}
: ${ASK_OPENCODE_DEBUG:=0}

# Spinner animation
_ask_opencode_spinner() {
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  while true; do
    printf "\r${spinstr:0:1} Asking OpenCode for '$user_prompt'..." > /dev/tty
    spinstr="${spinstr:1}${spinstr:0:1}"
    sleep 0.1
  done
}

# Trim whitespace from string
_trim() {
  local str="$1"
  str="${str#"${str%%[![:space:]]*}"}"
  str="${str%"${str##*[![:space:]]}"}"
  echo "$str"
}

# Show spinner and run command
_run_with_spinner() {
  _ask_opencode_spinner &
  local spinner_pid=$!
  
  local output
  output=$("$@" 2>&1)
  local exit_code=$?
  
  { kill $spinner_pid && wait $spinner_pid } 2>/dev/null
  printf "\r\033[K" > /dev/tty
  
  echo "$output"
  return $exit_code
}

# Main widget
ask_opencode() {
  setopt LOCAL_OPTIONS NO_NOTIFY NO_MONITOR
  
  local user_prompt="$BUFFER"
  [[ -z "$user_prompt" ]] && return
  
  zle kill-whole-line
  zle redisplay
  
  # Generate commands
  local output
  output=$(_run_with_spinner opencode run --model "$ASK_OPENCODE_MODEL" \
    "Generate the 3 simpliest shell commands to: $user_prompt
    Output format: command1\\0command2\\0command3
    Requirements:
    - Each command must be one line, no actual newlines
    - Separate with \\0 (backslash-zero)
    - Rank by best (speed/safety/reliability)
    - No explanations, code blocks, or markdown
    - Output only the commands")

  if [[ $? -ne 0 ]]; then
    echo "Error: $output" > /dev/tty
    zle reset-prompt
    return 1
  fi

  if [[ "$ASK_OPENCODE_DEBUG" == "1" ]]; then
    echo "[ask_opencode] Raw output (NUL-separated):" > /dev/tty
    print -r -- "$output" | tr '\0' '\n' | nl -ba > /dev/tty
  fi

  # Convert literal \0 to real NUL, then split
  output="${output//$'\n'/}"
  output=${output//\\0/$'\0'}
  local -a commands
  local IFS=$'\0'
  commands=(${=output})

  if [[ "$ASK_OPENCODE_DEBUG" == "1" ]]; then
    echo "[ask_opencode] Parsed commands:" > /dev/tty
    print -r -l -- "${commands[@]}" | nl -ba > /dev/tty
  fi
  
  if [[ ${#commands[@]} -eq 0 ]]; then
    echo "No commands generated" > /dev/tty
    zle reset-prompt
    return 1
  fi
  
  local selected="${commands[1]}"
  if command -v fzf >/dev/null 2>&1; then
    selected=$(print -r -l -- "${commands[@]}" | \
      fzf --height=10% --reverse --prompt="$user_prompt > " --border) || {
      BUFFER="$user_prompt"
      CURSOR=${#BUFFER}
      zle reset-prompt
      return 0
    }
  fi
  
  BUFFER="$selected"
  CURSOR=${#BUFFER}
  zle reset-prompt
}

zle -N ask_opencode
bindkey '^O' ask_opencode
