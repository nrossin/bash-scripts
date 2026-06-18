# input.sh
#
# Interactive prompt and menu helpers used by CL Dev Manager tasks.
# Provides reusable functions for waiting on user input, rendering hotkey
# options, displaying one- or two-column menus, and validating selected hotkeys.
#
# Requires log/style helper functions from log.sh.

# Enable extended globbing, required to strip ANSI codes in visible_length()
shopt -s extglob

#
# Define the character(s) to use as the prompt when user input is expected
CARET="->"

wait_continue() {
  log
  log_pending "$(style "${BOLD}" "Press [$(hotkey "ENTER")] to continue ${CARET} ")"
  read -r
}

continue_or_exit() {
  local choice

  log
  log_pending "$(style "${BOLD}" "Press [$(hotkey "ENTER")] to continue or [$(hotkey "X")] to exit now. ${CARET} ")"
  read -r choice

  case "$choice" in
    [Xx])
      log "Exiting script immediately ..."
      exit 0
      ;;
    *)
      return 0
      ;;
  esac
}

#######################################
# Calculate the visible length of a string, ignoring any ANSI escape codes.
# Handles both unrendered codes (the literal '\033[0m' held by the constants
# in ansi-colors.sh) and escape sequences already rendered by log().
# Globals:
#   None
# Arguments:
#   $1 - The string to measure; may contain ANSI codes
# Outputs:
#   Writes the visible character count to STDOUT
#######################################
visible_length() {
  local text="${1:-}"

  text="${text//\\033\[*([0-9;])m/}"
  text="${text//$'\033'\[*([0-9;])m/}"

  printf "%s" "${#text}"
}

#######################################
# Format a single option as "[hotkey] text" with the hotkey styled.
# Globals:
#   None
# Arguments:
#   $1 - The option, formatted as "hotkey|text" (e.g. "Q|Quit"); the text
#        portion is optional (e.g. "Q" displays as "[Q]" alone)
# Outputs:
#   Writes the formatted option to STDOUT
#######################################
format_option() {
  local option="${1:-}"
  local key="${option%%|*}"
  local text="${option#*|}"

  if [[ "$option" == *"|"* ]]; then
    printf "%s" "[$(hotkey "$key")] $text"
  else
    printf "%s" "[$(hotkey "$key")]"
  fi
}

#######################################
# Display a menu of options, one per row. When there are 10 or more options,
# the menu is split into two equal, aligned columns instead.
# Globals:
#   None
# Arguments:
#   $@ - The options array; each element formatted as "hotkey|text"
#        (e.g. "Q|Quit" displays as "[Q] Quit")
# Outputs:
#   Writes the formatted menu to STDOUT
#######################################
display_menu() {
  local options=("$@")
  local option

  if (( ${#options[@]} >= 10 )); then
    display_menu_columns "${options[@]}"
    return 0
  fi

  for option in "${options[@]}"; do
    log "$(format_option "$option")"
  done
}

#######################################
# Display a menu of options split into two equal, aligned columns.
# Globals:
#   None
# Arguments:
#   $@ - The options array; each element formatted as "hotkey|text"
# Outputs:
#   Writes the formatted two-column menu to STDOUT
#######################################
display_menu_columns() {
  local options=("$@")
  local count=${#options[@]}
  local rows=$(( (count + 1) / 2 ))
  local index width=0 length left right padding

  # Find the widest entry in the left column so the right column aligns
  for (( index = 0; index < rows; index++ )); do
    length=$(visible_length "$(format_option "${options[index]}")")
    if (( length > width )); then
      width=$length
    fi
  done

  for (( index = 0; index < rows; index++ )); do
    left="$(format_option "${options[index]}")"
    right=""
    if (( index + rows < count )); then
      right="$(format_option "${options[index + rows]}")"
    fi

    # Pad manually; a printf field width would count the invisible ANSI codes
    padding=$(( width - $(visible_length "$left") + 2 ))
    log "${left}$(printf "%*s" "$padding" "")${right}"
  done
}

#######################################
# Display a prompt and loop until the user enters one of the available
# hotkeys (case-insensitive). An error is shown for invalid input.
# Globals:
#   SELECTED_HOTKEY - Set to the chosen hotkey, cased as defined in options
#   CARET           - Appended to the prompt
# Arguments:
#   $1 - The fully formatted prompt text, including any option list
#   $@ - The options array; each element formatted as "hotkey|text" or
#        "hotkey"
# Outputs:
#   Writes the prompt and any error messages to STDOUT
# Returns:
#   0 once a valid hotkey has been selected
#######################################
prompt_for_hotkey() {
  local prompt="${1:-}"
  shift
  local options=("$@")
  local choice option key

  while true; do
    log_pending "${prompt} ${CARET} "
    read -r choice

    for option in "${options[@]}"; do
      key="${option%%|*}"
      if [[ "${choice^^}" == "${key^^}" ]]; then
        SELECTED_HOTKEY="$key"
        return 0
      fi
    done

    log_error "Invalid option: \"${choice}\". Please try again."
  done
}

#######################################
# Prompt the user inline with the available options (hotkey and text) and
# loop until a valid hotkey is entered (case-insensitive).
# Example: "Do you want to delete this file? [Y] Yes, [N] No -> "
# Globals:
#   SELECTED_HOTKEY - Set to the chosen hotkey, cased as defined in options
# Arguments:
#   $1 - The prompt text to display
#   $@ - The options array; each element formatted as "hotkey|text"
#        (e.g. "Y|Yes"); the text portion is optional (e.g. "Y")
# Outputs:
#   Writes the prompt and any error messages to STDOUT
# Returns:
#   0 once a valid hotkey has been selected
#######################################
inline_prompt() {
  local prompt="${1:-}"
  shift
  local options=("$@")
  local option_list="" option

  for option in "${options[@]}"; do
    option_list+="${option_list:+, }$(format_option "$option")"
  done

  prompt_for_hotkey "${prompt} ${option_list}" "${options[@]}"
}

#######################################
# Prompt the user inline with the available hotkeys only (no display text)
# and loop until a valid hotkey is entered (case-insensitive).
# Example: "Do you want to delete this file? Y, N -> "
# Globals:
#   SELECTED_HOTKEY - Set to the chosen hotkey, cased as defined in options
# Arguments:
#   $1 - The prompt text to display
#   $@ - The options array; each element formatted as "hotkey|text" or
#        "hotkey" (any display text is ignored)
# Outputs:
#   Writes the prompt and any error messages to STDOUT
# Returns:
#   0 once a valid hotkey has been selected
#######################################
hotkey_prompt() {
  local prompt="${1:-}"
  shift
  local options=("$@")
  local option_list="" option

  for option in "${options[@]}"; do
    option_list+="${option_list:+, }$(hotkey "${option%%|*}")"
  done

  prompt_for_hotkey "${prompt} ${option_list}" "${options[@]}"
}

#######################################
# Prompt the user with a simple Yes/No question and loop until a valid
# hotkey is entered (case-insensitive).
# Globals:
#   SELECTED_HOTKEY - Set to "Y" or "N"
# Arguments:
#   $1 - The prompt text to display
# Outputs:
#   Writes the prompt and any error messages to STDOUT
# Returns:
#   0 once a valid hotkey has been selected
#######################################
get_yes_no() {
  inline_prompt "${1:-}" "Y|Yes" "N|No"
}
