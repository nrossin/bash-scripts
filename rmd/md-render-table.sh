# md-render-table.sh
#
# Renders GFM pipe tables to the terminal.
# Column widths are based on visible character counts (Markdown syntax markers
# and ANSI escape sequences excluded) so padding is always correct.
#
# Caller collects table lines then calls:
#   render_table <lines_array_name>

# Return the visible display width of a cell after rendering.
# Renders the cell through render_inline, then strips ANSI codes to count
# only printable characters — this is the only accurate way to measure
# display width when cells may contain Markdown syntax or plain text.
_visible_len() {
  local s="${1}"
  local rendered visible
  rendered="$(render_inline "${s}")"
  # Strip ANSI escape sequences (ESC [ ... m) to get plain visible text
  visible="$(printf "%b" "${rendered}" | sed 's/\x1b\[[0-9;]*m//g')"
  printf "%d" "${#visible}"
}

render_table() {
  local -n _table_lines="${1}"

  # ── Parse rows ──────────────────────────────────────────────────────────
  local -a headers=()
  local -a data_rows=()
  local header_done=0
  local sep_done=0

  local row
  for row in "${_table_lines[@]}"; do
    row="${row#|}"
    row="${row%|}"

    if [[ "${header_done}" -eq 0 ]]; then
      IFS='|' read -ra headers <<< "${row}"
      header_done=1
    elif [[ "${sep_done}" -eq 0 ]]; then
      sep_done=1   # separator row — skip
    else
      data_rows+=("${row}")
    fi
  done

  [[ "${header_done}" -eq 0 ]] && return

  local col_count="${#headers[@]}"

  # ── Compute column widths using post-render visible character counts ────
  # Render each cell once up front; reuse the result for both width
  # calculation and output to avoid rendering twice per cell.
  local -a col_widths=()
  local ci
  # Header visible widths
  local -a rendered_headers=()
  for (( ci = 0; ci < col_count; ci++ )); do
    local h="${headers[$ci]}"
    h="${h## }"; h="${h%% }"
    local rh
    rh="$(render_inline "${h}")"
    rendered_headers[$ci]="${rh}"
    local vis
    vis="$(printf "%b" "${rh}" | sed 's/\x1b\[[0-9;]*m//g')"
    col_widths[$ci]="${#vis}"
  done

  # Data cell visible widths
  local -a rendered_data=()
  local row_idx=0
  local data_row
  for data_row in "${data_rows[@]}"; do
    IFS='|' read -ra cells <<< "${data_row}"
    local row_rendered=""
    for (( ci = 0; ci < col_count; ci++ )); do
      local c="${cells[$ci]:-}"
      c="${c## }"; c="${c%% }"
      local rc
      rc="$(render_inline "${c}")"
      local vis
      vis="$(printf "%b" "${rc}" | sed 's/\x1b\[[0-9;]*m//g')"
      local clen="${#vis}"
      if (( clen > col_widths[ci] )); then
        col_widths[$ci]="${clen}"
      fi
      # Store rendered cell: encode as "rendered\x01visible_len" pairs
      row_rendered+="${rc}"$'\x01'"${clen}"$'\x02'
    done
    rendered_data[$row_idx]="${row_rendered}"
    row_idx=$(( row_idx + 1 ))
  done

  # ── Render helper: one horizontal border row ────────────────────────────
  _render_table_border() {
    local left="┌" mid="┬" right="┐" fill="─"
    [[ "${1}" == "mid" ]] && left="├" mid="┼" right="┤"
    [[ "${1}" == "bot" ]] && left="└" mid="┴" right="┘"
    local line="${TABLE_BORDER_STYLE}${left}"
    for (( ci = 0; ci < col_count; ci++ )); do
      line+="$(_repeat_char "${fill}" $(( col_widths[ci] + 2 )))"
      if (( ci < col_count - 1 )); then line+="${mid}"; fi
    done
    line+="${right}${RESET}"
    printf "%b\n" "${line}"
  }

  # ── Render ───────────────────────────────────────────────────────────────
  _render_table_border top

  # Header row
  local hline="${TABLE_BORDER_STYLE}${TABLE_COL_SEP}${RESET}"
  for (( ci = 0; ci < col_count; ci++ )); do
    local h="${headers[$ci]}"
    h="${h## }"; h="${h%% }"
    local rendered_h="${rendered_headers[$ci]}"
    local vis
    vis="$(printf "%b" "${rendered_h}" | sed 's/\x1b\[[0-9;]*m//g')"
    local pad=$(( col_widths[ci] - ${#vis} ))
    hline+=" ${TABLE_HEADER_STYLE}${rendered_h}${RESET}"
    hline+="$(printf '%*s' "${pad}" '')"
    hline+=" ${TABLE_BORDER_STYLE}${TABLE_COL_SEP}${RESET}"
  done
  printf "%b\n" "${hline}"

  _render_table_border mid

  # Data rows — decode from rendered_data cache
  local ri
  for (( ri = 0; ri < ${#rendered_data[@]}; ri++ )); do
    local dline="${TABLE_BORDER_STYLE}${TABLE_COL_SEP}${RESET}"
    local row_data="${rendered_data[$ri]}"
    # Split on \x02 (cell separator), then split each chunk on \x01
    local -a cell_chunks=()
    IFS=$'\x02' read -ra cell_chunks <<< "${row_data}"
    for (( ci = 0; ci < col_count; ci++ )); do
      local chunk="${cell_chunks[$ci]:-}"
      local rendered_c="${chunk%%$'\x01'*}"
      local vis_len="${chunk##*$'\x01'}"
      local pad=$(( col_widths[ci] - vis_len ))
      dline+=" ${TABLE_CELL_STYLE}${rendered_c}${RESET}"
      dline+="$(printf '%*s' "${pad}" '')"
      dline+=" ${TABLE_BORDER_STYLE}${TABLE_COL_SEP}${RESET}"
    done
    printf "%b\n" "${dline}"
  done

  _render_table_border bot

  unset -f _render_table_border
}
