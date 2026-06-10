#########################
# ANSI Library for Bash #
#########################

# Reset
RESET='\033[0m'            # Reset ALL attributes
RESET_RENDERED=$'\033[0m'  # Rendered form, for matching codes already emitted by log()

##############
# Formatting #
##############
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
STRIKE='\033[9m'

##############################
# Foreground Colors #
##############################
BLACK='\033[30m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
MAGENTA='\033[35m'
CYAN='\033[36m'
WHITE='\033[37m'
BOLD_BLACK='\033[1;30m'
BOLD_RED='\033[1;31m'
BOLD_GREEN='\033[1;32m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_MAGENTA='\033[1;35m'
BOLD_CYAN='\033[1;36m'
BOLD_WHITE='\033[1;37m'
BRIGHT_BLACK='\033[90m'
BRIGHT_RED='\033[91m'
BRIGHT_GREEN='\033[92m'
BRIGHT_YELLOW='\033[93m'
BRIGHT_BLUE='\033[94m'
BRIGHT_MAGENTA='\033[95m'
BRIGHT_CYAN='\033[96m'
BRIGHT_WHITE='\033[97m'
BOLD_BRIGHT_BLACK='\033[1;90m'
BOLD_BRIGHT_RED='\033[1;91m'
BOLD_BRIGHT_GREEN='\033[1;92m'
BOLD_BRIGHT_YELLOW='\033[1;93m'
BOLD_BRIGHT_BLUE='\033[1;94m'
BOLD_BRIGHT_MAGENTA='\033[1;95m'
BOLD_BRIGHT_CYAN='\033[1;96m'
BOLD_BRIGHT_WHITE='\033[1;97m'

##############################
# Background Colors #
##############################
BLACK_BG='\033[40m'
RED_BG='\033[41m'
GREEN_BG='\033[42m'
YELLOW_BG='\033[43m'
BLUE_BG='\033[44m'
MAGENTA_BG='\033[45m'
CYAN_BG='\033[46m'
WHITE_BG='\033[47m'
BRIGHT_BLACK_BG='\033[100m'
BRIGHT_RED_BG='\033[101m'
BRIGHT_GREEN_BG='\033[102m'
BRIGHT_YELLOW_BG='\033[103m'
BRIGHT_BLUE_BG='\033[104m'
BRIGHT_MAGENTA_BG='\033[105m'
BRIGHT_CYAN_BG='\033[106m'
BRIGHT_WHITE_BG='\033[107m'