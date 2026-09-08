# rmd — Markdown Renderer for the Terminal

## Overview

**rmd** is a lightweight, terminal-native Markdown renderer written in pure Bash.
It converts `.md` files into styled, colour-highlighted terminal output using
ANSI escape codes — no external dependencies, no runtime installs.

Pipe it through `less -R` for paginated reading of longer documents.

## Usage

```bash
bash rmd.sh <file.md>
bash rmd.sh README.md | less -R
```

## Features

### Headings

All six Markdown heading levels are supported. H1 and H2 receive bordered
treatment; H3 through H6 are styled with distinct colours and weights.

### Inline Formatting

The following inline styles are recognised anywhere in paragraph text,
list items, blockquotes, and table cells:

| Style           | Syntax                   | Result                         |
|-----------------|--------------------------|--------------------------------|
| Bold            | `**text**` or `__text__` | **Bold**                       |
| Italic          | `*text*` or `_text_`     | *Italic*                       |
| Bold + Italic   | `***text***`             | ***Bold and italic***          |
| Strikethrough   | `~~text~~`               | ~~Crossed out~~                |
| Inline code     | `` `code` ``             | `monospaced`                   |

### Links and Images

Links are rendered inline with a highlight colour and collected into a
reference section at the bottom of the output — similar to footnotes.

Visit the [Markdown Guide](https://www.markdownguide.org) or the
[Bash Reference Manual](https://www.gnu.org/software/bash/manual/) for
further reading. Auto-links like <https://example.com> are also captured.

Images cannot be displayed in a terminal, so they are noted in place:

![The rmd rendering pipeline](docs/pipeline.png)

### Lists

#### Unordered Lists

Nested unordered lists use rotating bullet symbols to visually distinguish
depth levels:

- First level item
- Another first level item
  - Second level item
  - Another second level
    - Third level — deepest bullet style
    - Still third level
  - Back to second
- Back to first

#### Ordered Lists

1. Clone the repository
2. Copy the scripts to a directory on your `$PATH`
3. Make `rmd.sh` executable with `chmod +x rmd.sh`
4. Run it: `bash rmd.sh yourfile.md`

#### Task Lists

- [x] Headings (H1–H6)
- [x] Bold, italic, strikethrough
- [x] Inline code and fenced code blocks
- [x] Ordered and unordered lists
- [x] Nested lists and task lists
- [x] Blockquotes with nesting
- [x] Tables (GFM)
- [x] Links with footnote collection
- [x] Images (noted inline)
- [x] Horizontal rules
- [x] HTML stripping
- [ ] Syntax highlighting inside code blocks

### Code Blocks

Fenced code blocks display a language label and are highlighted with a
background colour. Indented blocks (4 spaces or one tab) are also supported.

```bash
#!/usr/bin/env bash
# Source the renderer and run it against a file
source ./rmd.sh
bash rmd.sh docs/guide.md | less -R
```

```javascript
// Works with any language label — highlighting is colour only, not semantic
const greet = (name) => console.log(`Hello, ${name}!`);
greet("terminal");
```

Plain indented code block:

    this_is_indented = true
    no_fence_needed  = true

### Blockquotes

> **Note:** All configuration lives in `md-config.sh`. Edit that single file
> to change colours, border characters, bullet symbols, and code block styles
> across the entire renderer.

Blockquotes can be nested:

> This is the first level of quoting.
>> Nested inside — this is the second level.

### Tables

Tables use box-drawing characters for borders and automatically size each
column to its widest cell.

| File                    | Purpose                                      |
|-------------------------|----------------------------------------------|
| `rmd.sh`                | Entry point and document-level state machine |
| `md-config.sh`          | Central configuration for all styles         |
| `md-render-heading.sh`  | H1–H6 heading renderer                       |
| `md-render-inline.sh`   | Bold, italic, links, images, code            |
| `md-render-block.sh`    | Code blocks, blockquotes, paragraphs, HR     |
| `md-render-list.sh`     | Ordered, unordered, and task lists           |
| `md-render-table.sh`    | GFM pipe table renderer                      |
| `md-render-html.sh`     | HTML tag stripping and entity decoding       |

### Horizontal Rules

A horizontal rule (`---`, `***`, or `___`) renders as a full-width line:

---

### HTML

Inline and block HTML is handled gracefully. Structural tags like `<br>` and
`<hr>` are mapped to their rendered equivalents. All other tags are stripped
and the remaining text is passed through the inline renderer.

<p>This paragraph was written in <strong>raw HTML</strong> and will render
as plain styled text with tags removed.</p>

## Configuration

Every visual choice is controlled by a single file: `md-config.sh`. Nothing
is hardcoded in the renderer modules. Key settings include:

```bash
HR_CHAR="─"             # Character used for horizontal rules
H1_BORDER_CHAR="═"      # Character used for H1 box borders
UL_BULLETS=("•" "◦" "▸")   # Bullet symbols per nesting depth
CODE_BLOCK_STYLE="${BRIGHT_BLACK_BG}${BRIGHT_GREEN}"  # Code block colours
LINK_FOOTNOTE_HEADER="Links"  # Heading for the link reference section
```

Any constant defined in `ansi-colors.sh` can be used as a style value.

## Pagination

Pipe to `less -R` to enable paginated scrolling with full colour support:

```bash
bash rmd.sh README.md | less -R
```

Set `LESS="-R"` in your shell profile to make this automatic:

```bash
echo 'export LESS="-R"' >> ~/.bashrc
```

## Setext-Style Heading Examples

The renderer also supports the older setext heading syntax, where `===`
underlines produce H1 and `---` underlines produce H2.

An Alternative H1 Heading
=========================

An Alternative H2 Heading
--------------------------

This works identically to the `#` ATX syntax.

## Requirements

- Bash 4.0 or later (for associative arrays and `=~` regex)
- A terminal that supports ANSI escape codes (almost all modern terminals)
- `tput` for dynamic terminal width detection (falls back to 80 columns)
- `mktemp` for link footnote collection across subshells
