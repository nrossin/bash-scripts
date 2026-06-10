# Source the required ANSI color definitions
source lib/ansi-colors.sh

# Define log level colors
SUCCESS="${GREEN}"
IMPORTANT="${MAGENTA}"
WARN="${YELLOW}"
ERROR="${RED}"
HIGHLIGHT="${BLUE}"
HOTKEY="${BOLD_BRIGHT_CYAN}"

log() {
  printf "%b\n" "${1:-}"
}

log_pending() {
  printf "%b" "${1:-}"
}

#######################################
# Apply a style to text, re-applying the style after any embedded resets so
# nested inline shortcuts (e.g. "$(hotkey ...)") do not cancel the enclosing
# style.
# Globals:
#   RESET          - The unrendered ANSI reset constant
#   RESET_RENDERED - The rendered ANSI reset escape sequence
# Arguments:
#   $1 - The ANSI style code(s) to apply (e.g. "${BOLD}${RED}")
#   $2 - The text to style; may contain ANSI codes
# Outputs:
#   Writes the styled text to STDOUT
#######################################
style() {
  local applied="${1:-}"
  local text="${2:-}"

  # Embedded resets may be unrendered constants ('\033[0m') or escape
  # sequences already rendered by command substitution; handle both
  text="${text//"${RESET}"/${RESET}${applied}}"
  text="${text//"${RESET_RENDERED}"/${RESET_RENDERED}${applied}}"

  log "${applied}${text}${RESET}"
}

log_success() {
  style "${SUCCESS}" "${1:-}"
}

log_important() {
  style "${IMPORTANT}" "${1:-}"
}

log_warn() {
  style "${WARN}" "${1:-}"
}

log_error() {
  style "${BRIGHT_RED_BG}${BRIGHT_WHITE}" " ${1:-} "
}

####################
# Inline Shortcuts #
####################
highlight() {
  style "${HIGHLIGHT}" "${1:-}"
}
hotkey() {
  style "${HOTKEY}" "${1:-}"
}
success() {
  style "${SUCCESS}" "${1:-}"
}
important() {
  style "${IMPORTANT}" "${1:-}"
}
warn() {
  style "${WARN}" "${1:-}"
}
error() {
  style "${ERROR}" "${1:-}"
}
bold() {
  style "${BOLD}" "${1:-}"
}
underline() {
  style "${UNDERLINE}" "${1:-}"
}
strike() {
  style "${STRIKE}" "${1:-}"
}
blink() {
  style "${BLINK}" "${1:-}"
}