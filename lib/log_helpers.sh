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

log_success() {
  log "${SUCCESS}${1:-}${RESET}"
}

log_important() {
  log "${IMPORTANT}${1:-}${RESET}"
}

log_warn() {
  log "${WARN}${1:-}${RESET}"
}

log_error() {
  log "${BRIGHT_RED_BG} ${BRIGHT_WHITE}${1:-} ${RESET}"
}

####################
# Inline Shortcuts #
####################
highlight() {
  log "${HIGHLIGHT}${1:-}${RESET}"
}
hotkey() {
  log "${HOTKEY}${1:-}${RESET}"
}
success() {
  log "${SUCCESS}${1:-}${RESET}"
}
important() {
  log "${IMPORTANT}${1:-}${RESET}"
}
warn() {
  log "${WARN}${1:-}${RESET}"
}
error() {
  log "${ERROR}${1:-}${RESET}"
}
bold() {
  log "${BOLD}${1:-}${RESET}"
}
underline() {
  log "${UNDERLINE}${1:-}${RESET}"
}
strike() {
  log "${STRIKE}${1:-}${RESET}"
}
blink() {
  log "${BLINK}${1:-}${RESET}"
}