# md-render-list.sh
#
# Renders Markdown lists:
#   - Unordered  (-, *, +)
#   - Ordered    (1. 2. 3.)
#   - Task lists (- [ ] / - [x])
#   - Nested lists (indent-aware, up to 3 levels)
#
# Usage:
#   source md-render-list.sh
#   render_list_item <type> <depth> <number> <text>
#     type  = "ul" | "ol" | "task_done" | "task_todo"
#     depth = 0-based nesting depth
#     number = item number (used for ol only)
#     text  = item text (inline Markdown will be rendered)

render_list_item() {
  local type="${1}"    # ul | ol | task_done | task_todo
  local depth="${2}"   # 0-based
  local number="${3}"  # used for ol
  local text="${4}"

  # Build indent string
  local indent=""
  local i
  for (( i = 0; i < depth; i++ )); do
    indent+="${LIST_INDENT}"
  done

  # Choose bullet/marker
  local marker
  case "${type}" in
    ol)
      marker="${LIST_BULLET_STYLE}${number}${OL_SUFFIX}${RESET}"
      ;;
    task_done)
      marker="${LIST_BULLET_STYLE}${CHECKBOX_CHECKED}${RESET}"
      ;;
    task_todo)
      marker="${LIST_BULLET_STYLE}${CHECKBOX_UNCHECKED}${RESET}"
      ;;
    *)  # ul — cycle through bullet symbols by depth
      local bullet_count="${#UL_BULLETS[@]}"
      local bullet_idx=$(( depth % bullet_count ))
      marker="${LIST_BULLET_STYLE}${UL_BULLETS[${bullet_idx}]}${RESET}"
      ;;
  esac

  local rendered
  rendered="$(render_inline "${text}")"
  printf "%b %b\n" "${indent}${marker}" "${rendered}"
}
