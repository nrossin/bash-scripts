# md-render-inline.sh
#
# Renders inline Markdown elements within a line of text.
#
# Links are written to RMD_LINK_FILE (a temp file set by rmd.sh) so they
# survive subshell boundaries. Call render_link_footnotes at doc end.

# Pre-compiled regex patterns (assigned to variables to avoid bash parser
# bugs with ) and ] inside character classes in [[ =~ ]])
_RX_IMAGE='^!\[([^]]*)\]\(([^)]+)\)(.*)$'
_RX_LINK='^(\[([^]]+)\])\(([^)]+)\)(.*)$'
_RX_AUTOLINK='^<(https?://[^>]+)>(.*)$'
_RX_BOLD_ITALIC='^\*\*\*([^*]+)\*\*\*(.*)$'
_RX_BOLD_STAR='^\*\*([^*]+)\*\*(.*)$'
_RX_BOLD_UNDER='^__([^_]+)__(.*)$'
_RX_ITALIC_STAR='^\*([^*]+)\*(.*)$'
_RX_ITALIC_UNDER='^_([^_]+)_(.*)$'
_RX_STRIKE='^~~([^~]+)~~(.*)$'
_RX_CODE='^`([^`]+)`(.*)$'
_RX_ESCAPE='^\\(.)(.*)$'

render_inline() {
  local line="${1}"
  local out=""
  local remaining="${line}"

  while [[ -n "${remaining}" ]]; do

    # Images  ![alt](url)
    if [[ "${remaining}" =~ ${_RX_IMAGE} ]]; then
      out+="${IMAGE_STYLE}${IMAGE_PREFIX} ${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[3]}"
      continue
    fi

    # Links  [text](url)
    if [[ "${remaining}" =~ ${_RX_LINK} ]]; then
      local ltext="${BASH_REMATCH[2]}"
      local lurl="${BASH_REMATCH[3]}"
      local rest="${BASH_REMATCH[4]}"
      # Write to link file if available (survives subshell)
      [[ -n "${RMD_LINK_FILE:-}" ]] && printf "%s|%s\n" "${ltext}" "${lurl}" >> "${RMD_LINK_FILE}"
      out+="${LINK_TEXT_STYLE}${ltext}${RESET}"
      remaining="${rest}"
      continue
    fi

    # Auto-links  <https://...>
    if [[ "${remaining}" =~ ${_RX_AUTOLINK} ]]; then
      [[ -n "${RMD_LINK_FILE:-}" ]] && printf "%s|%s\n" "${BASH_REMATCH[1]}" "${BASH_REMATCH[1]}" >> "${RMD_LINK_FILE}"
      out+="${LINK_TEXT_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Bold + Italic  ***text***
    if [[ "${remaining}" =~ ${_RX_BOLD_ITALIC} ]]; then
      out+="${BOLD_STYLE}${ITALIC_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Bold  **text**
    if [[ "${remaining}" =~ ${_RX_BOLD_STAR} ]]; then
      out+="${BOLD_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Bold  __text__
    if [[ "${remaining}" =~ ${_RX_BOLD_UNDER} ]]; then
      out+="${BOLD_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Italic  *text*
    if [[ "${remaining}" =~ ${_RX_ITALIC_STAR} ]]; then
      out+="${ITALIC_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Italic  _text_
    if [[ "${remaining}" =~ ${_RX_ITALIC_UNDER} ]]; then
      out+="${ITALIC_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Strikethrough  ~~text~~
    if [[ "${remaining}" =~ ${_RX_STRIKE} ]]; then
      out+="${STRIKE_STYLE}${BASH_REMATCH[1]}${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Inline code  `code`
    if [[ "${remaining}" =~ ${_RX_CODE} ]]; then
      out+="${CODE_INLINE_STYLE} ${BASH_REMATCH[1]} ${RESET}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # Escaped character  \X
    if [[ "${remaining}" =~ ${_RX_ESCAPE} ]]; then
      out+="${BASH_REMATCH[1]}"
      remaining="${BASH_REMATCH[2]}"
      continue
    fi

    # No match: consume one literal character
    out+="${remaining:0:1}"
    remaining="${remaining:1}"
  done

  # %b interprets the \033 escape sequences stored in ANSI color variables
  printf "%b" "${out}"
}

# Read links from RMD_LINK_FILE, deduplicate, and print a footnotes section.
render_link_footnotes() {
  [[ -z "${RMD_LINK_FILE:-}" || ! -s "${RMD_LINK_FILE}" ]] && return

  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
  local border
  border="$(_repeat_char "${HR_CHAR}" "${cols}")"

  printf "\n%b\n" "${HR_STYLE}${border}${RESET}"
  printf "%b  %s  %b\n\n" "${H3_STYLE}" "${LINK_FOOTNOTE_HEADER}" "${RESET}"

  local seen_file
  seen_file="$(mktemp)"

  local entry ltext lurl
  while IFS= read -r entry; do
    ltext="${entry%%|*}"
    lurl="${entry#*|}"

    # Skip duplicate URLs
    if grep -qxF "${lurl}" "${seen_file}" 2>/dev/null; then
      continue
    fi
    printf "%s\n" "${lurl}" >> "${seen_file}"

    printf "%b%s%b  →  %b%s%b\n" \
      "${LINK_TEXT_STYLE}" "${ltext}" "${RESET}" \
      "${LINK_REF_STYLE}" "${lurl}" "${RESET}"
  done < "${RMD_LINK_FILE}"

  rm -f "${seen_file}"
}
