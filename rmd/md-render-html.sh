# md-render-html.sh
#
# Handles raw HTML lines in Markdown.
#
# Strategy:
#   - Structural void tags (<br>, <hr>) map to renderer actions
#   - Inline semantic tags (<strong>, <em>, <code>, <s>, <del>) are converted
#     to their Markdown equivalents so render_inline can style them
#   - Block wrapper tags (<p>, <div>, etc.) are stripped; their text content
#     is passed through render_inline
#   - Comments and DOCTYPE are discarded silently
#
# HTML accumulation (multi-line blocks) is handled in rmd.sh. This module
# only processes one logical line at a time.

_RX_BR='^[[:space:]]*<br[[:space:]]*/?>$'
_RX_HR_HTML='^[[:space:]]*<hr[[:space:]]*/?>$'
_RX_LI='^[[:space:]]*<li>(.*)</li>$'
_RX_COMMENT='^<!--.*-->$'
_RX_DOCTYPE='^<![Dd][Oo][Cc][Tt][Yy][Pp][Ee]'
_RX_HTML_TAG='<[^>]+>'

render_html_line() {
  local raw="${1}"

  # Discard comments and DOCTYPE
  if [[ "${raw}" =~ ${_RX_COMMENT} || "${raw}" =~ ${_RX_DOCTYPE} ]]; then
    return
  fi

  # <br> -> newline
  if [[ "${raw}" =~ ${_RX_BR} ]]; then
    printf "\n"
    return
  fi

  # <hr> -> horizontal rule
  if [[ "${raw}" =~ ${_RX_HR_HTML} ]]; then
    render_hr
    return
  fi

  # <li>content</li> -> unordered list item
  if [[ "${raw}" =~ ${_RX_LI} ]]; then
    local li_text
    li_text="$(_html_to_markdown "${BASH_REMATCH[1]}")"
    render_list_item "ul" 0 "" "${li_text}"
    return
  fi

  # General case: convert inline HTML tags to Markdown, strip block tags,
  # then pass through render_inline for styling
  local text
  text="$(_html_to_markdown "${raw}")"

  # Skip lines that were tag-only (nothing left after stripping)
  [[ -z "${text// /}" ]] && return

  local rendered
  rendered="$(render_inline "${text}")"
  printf "%b%b\n" "${rendered}" "${RESET}"
}

# Convert a string of HTML to Markdown-equivalent syntax, then strip any
# remaining unrecognised tags. Inline semantic tags become Markdown markers
# so that render_inline can apply the correct ANSI styling.
_html_to_markdown() {
  local s="${1}"

  # Inline semantic tag conversions (open and close pairs)
  # Bold: <strong> / <b>
  s="${s//<strong>/**}"
  s="${s//<\/strong>/**}"
  s="${s//<b>/**}"
  s="${s//<\/b>/**}"

  # Italic: <em> / <i>
  s="${s//<em>/*}"
  s="${s//<\/em>/*}"
  s="${s//<i>/*}"
  s="${s//<\/i>/*}"

  # Inline code: <code>
  s="${s//<code>/\`}"
  s="${s//<\/code>/\`}"

  # Strikethrough: <s> / <del>
  s="${s//<s>/~~}"
  s="${s//<\/s>/~~}"
  s="${s//<del>/~~}"
  s="${s//<\/del>/~~}"

  # Strip all remaining tags (block wrappers, unknown tags, etc.)
  while [[ "${s}" =~ ${_RX_HTML_TAG} ]]; do
    s="${s//${BASH_REMATCH[0]}/}"
  done

  # Decode common HTML entities
  s="${s//&amp;/&}"
  s="${s//&lt;/<}"
  s="${s//&gt;/>}"
  s="${s//&quot;/\"}"
  s="${s//&apos;/\'}"
  s="${s//&nbsp;/ }"

  printf "%s" "${s}"
}
