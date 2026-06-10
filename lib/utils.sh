command_exists() {
  if command -v "$1" >/dev/null 2>&1; then
      return 0
  fi

  return 1
}