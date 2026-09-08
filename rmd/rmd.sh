#!/usr/bin/env bash
# rmd.sh
#
# Render a Markdown file to the terminal with colour and layout.
#
# Usage:
#   rmd.sh <file.md>
#
# All visual config lives in md-config.sh.
# Each element type is handled by its own md-render-*.sh module.

set -euo pipefail

RMD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${RMD_DIR}/md-config.sh"
source "${RMD_DIR}/md-render-heading.sh"
source "${RMD_DIR}/md-render-inline.sh"
source "${RMD_DIR}/md-render-block.sh"
source "${RMD_DIR}/md-render-list.sh"
source "${RMD_DIR}/md-render-table.sh"
source "${RMD_DIR}/md-render-html.sh"

##############################################################################
# Usage guard
##############################################################################
if [[ "${#}" -lt 1 ]]; then
  printf "Usage: rmd.sh <file.md>\n" >&2
  exit 1
fi

FILE="${1}"
if [[ ! -f "${FILE}" ]]; then
  printf "rmd: file not found: %s\n" "${FILE}" >&2
  exit 1
fi

##############################################################################
# Shared utility: _repeat_char
##############################################################################
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

##############################################################################
# Temp file for link collection (survives subshell boundaries)
##############################################################################
RMD_LINK_FILE="$(mktemp)"
export RMD_LINK_FILE
trap 'rm -f "${RMD_LINK_FILE}"' EXIT

##############################################################################
# Gap tracking — sole owner of blank lines between elements.
#
# _gap        Print one blank line, but only if we haven't just printed one.
# _gap_reset  Mark that a blank line was just emitted (called after renderers
#             that consume a blank line from the source, e.g. fenced code end).
##############################################################################
_LAST_WAS_GAP=1   # Start as 1 so we don't print a leading blank at top

_gap() {
  if [[ "${_LAST_WAS_GAP}" -eq 0 ]]; then
    printf "\n"
    _LAST_WAS_GAP=1
  fi
}

_mark_content() {
  _LAST_WAS_GAP=0
}

##############################################################################
# State machine variables
##############################################################################
STATE="normal"    # normal | code_block | indented_code | blockquote | table | html_block | para
CODE_LANG=""
CODE_CONTENT=""
PARA_CONTENT=""
HTML_BLOCK_TAG=""
HTML_CONTENT=""

declare -a LIST_TYPE=()
declare -a LIST_NUMBER=()
PREV_LIST_DEPTH=-1
declare -a TABLE_LINES=()

##############################################################################
# Helpers
##############################################################################

_flush_para() {
  if [[ -n "${PARA_CONTENT}" ]]; then
    _gap
    render_paragraph "${PARA_CONTENT}"
    _mark_content
    PARA_CONTENT=""
  fi
}

_flush_list() {
  if [[ "${PREV_LIST_DEPTH}" -ge 0 ]]; then
    LIST_TYPE=()
    LIST_NUMBER=()
    PREV_LIST_DEPTH=-1
  fi
}

_flush_code() {
  if [[ "${STATE}" == "indented_code" || "${STATE}" == "code_block" ]]; then
    _gap
    render_code_block "${CODE_LANG}" "${CODE_CONTENT%$'\n'}"
    _mark_content
    CODE_LANG=""
    CODE_CONTENT=""
  fi
}

_list_depth() {
  local line="${1}"
  local spaces=0
  local ch
  while [[ "${#line}" -gt 0 ]]; do
    ch="${line:0:1}"
    if [[ "${ch}" == " " ]]; then
      spaces=$(( spaces + 1 ))
      line="${line:1}"
    elif [[ "${ch}" == $'\t' ]]; then
      spaces=$(( spaces + 2 ))
      line="${line:1}"
    else
      break
    fi
  done
  printf "%d" $(( spaces / 2 ))
}

_is_html_line() {
  [[ "${1}" =~ ^[[:space:]]*'<'[a-zA-Z/!] ]]
}

_is_html_block_open() {
  [[ "${1}" =~ ^[[:space:]]*'<'(div|section|article|header|footer|nav|aside|main|details|summary|figure|figcaption|blockquote|ul|ol|dl|form|fieldset|pre|script|style|noscript)[^'>']*'>'$ ]]
}

# Tags that wrap inline content (may contain <strong>, <em>, etc.)
_is_html_inline_block() {
  [[ "${1}" =~ ^[[:space:]]*'<'(p|h[1-6]|li|dt|dd|td|th|caption|label|legend)[^'>']*'>' ]]
}

##############################################################################
# Main render loop
##############################################################################
while IFS= read -r line || [[ -n "${line}" ]]; do

  # ── Inside a fenced code block ──────────────────────────────────────────
  if [[ "${STATE}" == "code_block" ]]; then
    if [[ "${line}" =~ ^(\`\`\`|~~~) ]]; then
      _gap
      render_code_block "${CODE_LANG}" "${CODE_CONTENT%$'\n'}"
      _mark_content
      CODE_LANG=""
      CODE_CONTENT=""
      STATE="normal"
    else
      CODE_CONTENT+="${line}"$'\n'
    fi
    continue
  fi

  # ── Inside a table ──────────────────────────────────────────────────────
  if [[ "${STATE}" == "table" ]]; then
    if [[ "${line}" =~ ^\|.*\| ]]; then
      TABLE_LINES+=("${line}")
      continue
    else
      _gap
      render_table TABLE_LINES
      _mark_content
      TABLE_LINES=()
      STATE="normal"
      # fall through to process current line
    fi
  fi

  # ── Inside a multi-line HTML block (accumulate until closing tag or blank) ─
  if [[ "${STATE}" == "html_block" ]]; then
    HTML_CONTENT+=" ${line}"
    if [[ "${line}" =~ '</'${HTML_BLOCK_TAG}'>' ]]; then
      _gap
      render_html_line "${HTML_CONTENT}"
      _mark_content
      HTML_CONTENT=""
      STATE="normal"
    fi
    continue
  fi

  # ── Blank line ──────────────────────────────────────────────────────────
  if [[ -z "${line// /}" ]]; then
    _flush_para
    if [[ "${STATE}" == "indented_code" ]]; then
      _flush_code
    fi
    if [[ "${STATE}" == "html_block" && -n "${HTML_CONTENT}" ]]; then
      _gap
      render_html_line "${HTML_CONTENT}"
      _mark_content
      HTML_CONTENT=""
      HTML_BLOCK_TAG=""
    fi
    _flush_list
    STATE="normal"
    _gap
    continue
  fi

  # ── Fenced code block opener ────────────────────────────────────────────
  if [[ "${line}" =~ ^(\`\`\`|~~~)([a-zA-Z0-9._-]*)$ ]]; then
    _flush_para; _flush_list
    CODE_LANG="${BASH_REMATCH[2]}"
    CODE_CONTENT=""
    STATE="code_block"
    continue
  fi

  # ── ATX Headings  # ## ### ──────────────────────────────────────────────
  if [[ "${line}" =~ ^(#{1,6})[[:space:]]+(.+)$ ]]; then
    _flush_para; _flush_list
    hd_level="${#BASH_REMATCH[1]}"
    hd_text="${BASH_REMATCH[2]}"
    hd_text="${hd_text%"${hd_text##*[! #]}"}"
    hd_text="${hd_text%% }"
    _gap
    render_heading "${hd_level}" "$(render_inline "${hd_text}")"
    _mark_content
    STATE="normal"
    continue
  fi

  # ── Setext headings (=== or --- under a para line) ──────────────────────
  if [[ "${STATE}" == "para" && "${line}" =~ ^=+[[:space:]]*$ ]]; then
    _gap
    render_heading 1 "$(render_inline "${PARA_CONTENT}")"
    _mark_content
    PARA_CONTENT=""
    STATE="normal"
    continue
  fi
  if [[ "${STATE}" == "para" && "${line}" =~ ^-{2,}[[:space:]]*$ ]]; then
    _gap
    render_heading 2 "$(render_inline "${PARA_CONTENT}")"
    _mark_content
    PARA_CONTENT=""
    STATE="normal"
    continue
  fi

  # ── Horizontal rule  (--- / *** / ___ with optional spaces) ─────────────
  if [[ "${line}" =~ ^[[:space:]]*([-]{3,}|[*]{3,}|[_]{3,})[[:space:]]*$ ]]; then
    _flush_para; _flush_list
    _gap
    render_hr
    _mark_content
    STATE="normal"
    continue
  fi

  # ── GFM Table ───────────────────────────────────────────────────────────
  if [[ "${line}" =~ ^\| ]]; then
    _flush_para; _flush_list
    TABLE_LINES=("${line}")
    STATE="table"
    continue
  fi

  # ── Blockquote  > text ──────────────────────────────────────────────────
  if [[ "${line}" =~ ^([[:space:]]*'>'[[:space:]]?)(.*)$ ]]; then
    if [[ "${STATE}" != "blockquote" ]]; then
      _flush_para; _flush_list
      _gap
    fi
    bq_full="${line}"
    bq_depth=0
    bq_remaining="${bq_full}"
    while [[ "${bq_remaining}" =~ ^[[:space:]]*'>'[[:space:]]?(.*)$ ]]; do
      bq_depth=$(( bq_depth + 1 ))
      bq_remaining="${BASH_REMATCH[1]}"
    done
    render_blockquote "${bq_remaining}" "$(( bq_depth - 1 ))"
    _mark_content
    STATE="blockquote"
    continue
  fi

  # ── Unordered list  (-, *, +) ───────────────────────────────────────────
  if [[ "${line}" =~ ^([[:space:]]*)[-*+][[:space:]]+(.*)$ ]]; then
    _flush_para
    if [[ "${PREV_LIST_DEPTH}" -lt 0 ]]; then
      _gap
    fi
    ul_depth="$(_list_depth "${line}")"
    ul_text="${BASH_REMATCH[2]}"
    ul_type="ul"
    if [[ "${ul_text}" =~ ^\[[xX]\][[:space:]]+(.*) ]]; then
      ul_type="task_done"; ul_text="${BASH_REMATCH[1]}"
    elif [[ "${ul_text}" =~ ^\[[[:space:]]\][[:space:]]+(.*) ]]; then
      ul_type="task_todo"; ul_text="${BASH_REMATCH[1]}"
    fi
    render_list_item "${ul_type}" "${ul_depth}" "" "${ul_text}"
    _mark_content
    PREV_LIST_DEPTH="${ul_depth}"
    STATE="normal"
    continue
  fi

  # ── Ordered list  (1. 2.) ───────────────────────────────────────────────
  if [[ "${line}" =~ ^([[:space:]]*)([0-9]+)\.[[:space:]]+(.*)$ ]]; then
    _flush_para
    if [[ "${PREV_LIST_DEPTH}" -lt 0 ]]; then
      _gap
    fi
    ol_depth="$(_list_depth "${line}")"
    ol_num="${BASH_REMATCH[2]}"
    ol_text="${BASH_REMATCH[3]}"
    render_list_item "ol" "${ol_depth}" "${ol_num}" "${ol_text}"
    _mark_content
    PREV_LIST_DEPTH="${ol_depth}"
    STATE="normal"
    continue
  fi

  # ── Indented code block  (4 spaces or tab) ──────────────────────────────
  _TAB=$'\t'
  if [[ "${line}" =~ ^(    |${_TAB})(.*)$ ]]; then
    _flush_para; _flush_list
    if [[ "${STATE}" == "indented_code" ]]; then
      CODE_CONTENT+="${BASH_REMATCH[2]}"$'\n'
    else
      CODE_CONTENT="${BASH_REMATCH[2]}"$'\n'
      STATE="indented_code"
    fi
    continue
  fi

  # ── Raw HTML ─────────────────────────────────────────────────────────────
  if _is_html_line "${line}"; then
    _flush_para; _flush_list
    if _is_html_block_open "${line}"; then
      # True block-level elements with no inline content on the same line:
      # render immediately line by line (already handled by html_block state above)
      if [[ "${line}" =~ '<'([a-zA-Z][a-zA-Z0-9]*) ]]; then
        HTML_BLOCK_TAG="${BASH_REMATCH[1]}"
        STATE="html_block"
        HTML_CONTENT="${line}"
      fi
      # If the opening and closing tag are on the same line, render immediately
      if [[ "${line}" =~ '</'${HTML_BLOCK_TAG}'>' ]]; then
        _gap
        render_html_line "${HTML_CONTENT}"
        _mark_content
        HTML_CONTENT=""
        HTML_BLOCK_TAG=""
        STATE="normal"
      fi
    elif _is_html_inline_block "${line}"; then
      # Inline-containing block tags like <p> may span lines — accumulate
      if [[ "${line}" =~ '<'([a-zA-Z][a-zA-Z0-9]*) ]]; then
        HTML_BLOCK_TAG="${BASH_REMATCH[1]}"
      fi
      HTML_CONTENT="${line}"
      # If self-closing on same line, render immediately
      if [[ "${line}" =~ '</'${HTML_BLOCK_TAG}'>' ]]; then
        _gap
        render_html_line "${HTML_CONTENT}"
        _mark_content
        HTML_CONTENT=""
        HTML_BLOCK_TAG=""
      else
        STATE="html_block"
      fi
    else
      # Single-line inline HTML — render directly
      _gap
      render_html_line "${line}"
      _mark_content
    fi
    continue
  fi

  # ── Paragraph text ───────────────────────────────────────────────────────
  if [[ "${STATE}" == "para" ]]; then
    if [[ "${PARA_CONTENT}" =~ [[:space:]][[:space:]]$ ]]; then
      _flush_para
      PARA_CONTENT="${line}"
    else
      PARA_CONTENT+=" ${line}"
    fi
  else
    _flush_list
    PARA_CONTENT="${line}"
    STATE="para"
  fi

done < "${FILE}"

##############################################################################
# EOF flush
##############################################################################
_flush_para

case "${STATE}" in
  code_block|indented_code) _flush_code ;;
  table)
    _gap
    render_table TABLE_LINES
    _mark_content
    ;;
esac

_flush_list

render_link_footnotes
