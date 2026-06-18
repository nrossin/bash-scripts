# system.sh
#
# System-level helper functions.

group_exists() {
  local group_name="$1"

  getent group "$group_name" >/dev/null 2>&1
}

current_user_in_group() {
  local group_name="$1"

  id -nG "$USER" | tr ' ' '\n' | grep -Fxq "$group_name"
}

create_group() {
  local group_name="$1"

  if ! group_exists "$group_name"; then
    sudo groupadd "$group_name"
  fi

  return 0
}

add_current_user_to_group() {
  local group_name="$1"
  local username
  username="${USER:-$(id -un)}"

  if ! group_exists "$group_name"; then
    return 1
  fi

  if ! current_user_in_group "$group_name"; then
    sudo usermod -aG "$group_name" "$username"
  fi
}

command_exists() {
  if command -v "$1" >/dev/null 2>&1; then
      return 0
  fi
  return 1
}