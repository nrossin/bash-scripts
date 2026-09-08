# md-render-heading.sh
#
# Renders Markdown headings (H1–H6) to the terminal.
#
# Tier system:
#   H1 — bold bordered box (═══ above and below)
#   H2 — colored with a lighter border (─── above and below)
#   H3 — bold bright color, no border
#   H4 — bright color, no border
#   H5 — bold plain, no border
#   H6 — plain color, no border
#
# Usage:
#   source md-render-heading.sh
#   render_heading <level> <text>

render_heading() {
  local level="${1:-1}"
  local text="${2:-}"
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
  local width=$(( cols < 4 ? 4 : cols ))

  case "${level}" in
    1) _render_heading_h1 "${text}" "${width}" ;;
    2) _render_heading_h2 "${text}" "${width}" ;;
    3) printf "%b\n" "${H3_STYLE}${text}${RESET}" ;;
    4) printf "%b\n" "${H4_STYLE}${text}${RESET}" ;;
    5) printf "%b\n" "${H5_STYLE}${text}${RESET}" ;;
    *) printf "%b\n" "${H6_STYLE}${text}${RESET}" ;;
  esac
}

_render_heading_h1() {
  local text="${1}"
  local width="${2}"
  local border
  border="$(_repeat_char "${H1_BORDER_CHAR}" "${width}")"

  # Strip ANSI escapes to get visible character count for centering
  local visible
  visible="$(printf "%b" "${text}" | sed 's/\x1b\[[0-9;]*m//g')"
  local pad_total=$(( width - ${#visible} - 2 ))
  [[ "${pad_total}" -lt 0 ]] && pad_total=0
  local pad_left=$(( pad_total / 2 ))
  local pad_right=$(( pad_total - pad_left ))

  printf "%b\n" "${H1_BORDER_STYLE}${border}${RESET}"
  printf "%b%*s%b%b%b%*s%b\n" \
    "${H1_BORDER_STYLE}" 1 " " \
    "${RESET}${H1_STYLE}" "${text}" \
    "${RESET}${H1_BORDER_STYLE}" $(( pad_right + 1 )) " " \
    "${RESET}"
  printf "%b\n" "${H1_BORDER_STYLE}${border}${RESET}"
}

_render_heading_h2() {
  local text="${1}"
  local width="${2}"
  local border
  border="$(_repeat_char "${H2_BORDER_CHAR}" "${width}")"

  printf "%b\n" "${H2_BORDER_STYLE}${border}${RESET}"
  printf "%b %s %b\n" "${H2_STYLE}" "${text}" "${RESET}"
  printf "%b\n" "${H2_BORDER_STYLE}${border}${RESET}"
}

# Repeat a character N times
_repeat_char() {
  local char="${1}"
  local n="${2}"
  local result=""
  local i
  for (( i = 0; i < n; i++ )); do
    result="${result}${char}"
  done
  printf "%s" "${result}"
}
