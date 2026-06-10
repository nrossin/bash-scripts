#!/bin/bash

source lib/log_helpers.sh

#
# Define the character(s) to use as the prompt when user input is expected
CARET="->"

wait_continue() {
  log
  printf "%b" "${BOLD}Press [$(hotkey "ENTER")${BOLD}] to continue ${CARET} ${RESET}"
  read -r
}

continue_or_exit() {
  local choice

  log
  printf "%b" "${BOLD}Press [$(hotkey "ENTER")] ${BOLD}to continue or [$(hotkey "X")] ${BOLD}to exit now. ${CARET} ${RESET}"
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

get_yes_no() {
  local prompt="$1"
  local choice
  local options=(
    "Y|es"
    "N|o"
  )

}