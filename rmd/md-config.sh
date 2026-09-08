# md-config.sh
#
# Central configuration for the rmd Markdown renderer.
# All characters, colors, and visual choices are defined here.
# Edit this file to change the look of the renderer globally.

# Source ANSI color definitions (path relative to this file)
source "$(dirname "${BASH_SOURCE[0]}")/../lib/ansi-colors.sh"

##############################################################################
# Characters / Symbols
# Change these to use different Unicode or ASCII characters throughout.
##############################################################################

# Horizontal rule character (repeated to fill terminal width)
HR_CHAR="─"

# H1 border characters
H1_BORDER_CHAR="═"

# H2 border characters
H2_BORDER_CHAR="─"

# Unordered list bullet symbol
UL_BULLET="•"

# Unordered list nested bullets (by depth: 1-indexed, wraps after 3)
UL_BULLETS=("•" "◦" "▸")

# Ordered list suffix character (e.g. "1." or "1)")
OL_SUFFIX="."

# Blockquote left gutter character
BLOCKQUOTE_CHAR="▎"

# Image placeholder prefix
IMAGE_PREFIX="[IMAGE]"

# Link footnote section header
LINK_FOOTNOTE_HEADER="Links"

# Checkbox symbols
CHECKBOX_CHECKED="[✓]"
CHECKBOX_UNCHECKED="[ ]"

##############################################################################
# Colors / Styles
# Reference constants from ansi-colors.sh.
##############################################################################

# Heading styles
H1_STYLE="${BOLD_BRIGHT_WHITE}"
H1_BORDER_STYLE="${BRIGHT_CYAN}"

H2_STYLE="${BOLD_BRIGHT_CYAN}"
H2_BORDER_STYLE="${CYAN}"

H3_STYLE="${BOLD_BRIGHT_YELLOW}"
H4_STYLE="${BRIGHT_YELLOW}"
H5_STYLE="${BOLD_WHITE}"
H6_STYLE="${WHITE}"

# Inline styles
BOLD_STYLE="${BOLD}"
ITALIC_STYLE="${ITALIC}"
STRIKE_STYLE="${STRIKE}"
CODE_INLINE_STYLE="${BRIGHT_BLACK_BG}${BRIGHT_WHITE}"    # fg on bg
CODE_BLOCK_STYLE="${BRIGHT_GREEN}"     # fg on bg
CODE_LANG_STYLE="${DIM}${BRIGHT_BLACK}"

# Links & images
LINK_TEXT_STYLE="${BRIGHT_BLUE}${UNDERLINE}"
LINK_REF_STYLE="${DIM}${CYAN}"
IMAGE_STYLE="${DIM}${ITALIC}"

# Blockquote
BLOCKQUOTE_GUTTER_STYLE="${BRIGHT_MAGENTA}"
BLOCKQUOTE_TEXT_STYLE="${ITALIC}${WHITE}"

# Horizontal rule
HR_STYLE="${DIM}"

# Ordered / unordered list number/bullet
LIST_BULLET_STYLE="${BRIGHT_CYAN}"
LIST_INDENT="  "   # spaces per nesting level

# Table
TABLE_HEADER_STYLE="${BOLD_BRIGHT_WHITE}"
TABLE_BORDER_STYLE="${DIM}"
TABLE_CELL_STYLE="${WHITE}"
TABLE_COL_SEP="│"
TABLE_HEADER_SEP="─"

# Link footnotes section
LINK_SECTION_STYLE="${DIM}${CYAN}"

# Paragraph text (default; empty = terminal default)
PARA_STYLE=""
