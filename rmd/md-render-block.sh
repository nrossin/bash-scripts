# md-render-block.sh
#
# Renders block-level Markdown elements:
#   - Fenced code blocks (``` or ~~~)
#   - Indented code blocks (4-space / tab)
#   - Blockquotes (> text)
#   - Horizontal rules (---, ***, ___)
#   - Paragraphs (plain text with inline rendering)
#
# Usage:
#   source md-render-block.sh
#   render_code_block <lang> <content_lines_array_name>
#   render_blockquote <text>
#   render_hr
#   render_paragraph <text>

render_hr() {
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
  local border
  border="$(_repeat_char "${HR_CHAR}" "${cols}")"
  printf "%b\n" "${HR_STYLE}${border}${RESET}"
}

# $1 = language label (may be empty)
# $2 = the code content (multi-line string)
render_code_block() {
  local lang="${1:-}"
  local content="${2}"
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)
  local border
  border="$(_repeat_char "${HR_CHAR}" "${cols}")"

  if [[ -n "${lang}" ]]; then
    printf "%b %s %b\n" "${CODE_LANG_STYLE}" "${lang}" "${RESET}"
  fi
  printf "%b\n" "${HR_STYLE}${border}${RESET}"
  while IFS= read -r code_line; do
    printf "%b%s%b\n" "${CODE_BLOCK_STYLE}" "${code_line}" "${RESET}"
  done <<< "${content}"
  printf "%b\n" "${HR_STYLE}${border}${RESET}"
}

# $1 = blockquote text (may already have nested > stripped by caller)
# $2 = nesting depth (default 0)
render_blockquote() {
  local text="${1}"
  local depth="${2:-0}"
  local gutter=""
  local i
  for (( i = 0; i <= depth; i++ )); do
    gutter+="${BLOCKQUOTE_GUTTER_STYLE}${BLOCKQUOTE_CHAR}${RESET} "
  done

  local rendered
  rendered="$(render_inline "${text}")"
  printf "%b%b%b\n" "${gutter}" "${BLOCKQUOTE_TEXT_STYLE}${rendered}" "${RESET}"
}

# $1 = paragraph text (one or more lines joined by caller)
render_paragraph() {
  local text="${1}"
  local rendered
  rendered="$(render_inline "${text}")"
  printf "%b%b%b\n" "${PARA_STYLE}" "${rendered}" "${RESET}"
}
