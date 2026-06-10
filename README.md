# Bash Scripts

A personal and work-oriented collection of Bash scripts, helpers, and reusable shell utilities.

This repository is currently in an early, incomplete state. The goal is to build a small library of Bash utilities that can be reused across scripts for common tasks such as terminal formatting, logging, and safer user input handling.

## Current Goals

This repository is intended to contain:

* ANSI formatting helpers for colors and text styling
* Standard logging helpers for writing formatted messages to STDOUT
* Reusable user input helpers for prompts, confirmations, menus, and other interactive flows
* General-purpose Bash utilities that may be useful for personal scripts, work scripts, or both

## Current Structure

```text
.
└── lib/
    ├── ansi-colors.sh
    ├── log_helpers.sh
    └── input.sh
```

## Library Files

### `lib/ansi-colors.sh`

Defines ANSI escape codes for terminal output formatting.

Current coverage includes:

* Reset code
* Text formatting such as bold, dim, italic, underline, blink, and strikethrough
* Standard foreground colors
* Bright foreground colors
* Bold color variants
* Standard background colors
* Bright background colors

This file is intended to be sourced by other scripts that need formatted terminal output.

### `lib/log_helpers.sh`

Provides simple logging and formatting helper functions for writing messages to STDOUT.

Current helpers include:

* `log`
* `log_pending`
* `log_success`
* `log_important`
* `log_warn`
* `log_error`

It also includes inline formatting shortcut helpers such as:

* `highlight`
* `hotkey`
* `success`
* `important`
* `warn`
* `error`
* `bold`
* `underline`
* `strike`
* `blink`

This file currently depends on `lib/ansi-colors.sh`.

### `lib/input.sh`

Contains early user-input helper functions for interactive scripts.

Current helpers include:

* `wait_continue`
* `continue_or_exit`

Planned functionality includes more robust prompt handling, yes/no confirmations, menus, and related input patterns.

This file currently depends on `lib/log_helpers.sh`.

## Usage

These scripts are intended to be sourced from other Bash scripts.

Example:

```bash
#!/bin/bash

source lib/log_helpers.sh
source lib/input.sh

log_success "Setup completed successfully."
continue_or_exit
```

## Status

This repository is a work in progress.

Many functions are experimental, incomplete, or subject to change. APIs, naming conventions, file organization, and behavior may change as the helper library develops.

## Planned Improvements

Potential future improvements include:

* More complete user input helpers
* Yes/no confirmation prompts
* Menu selection helpers
* Input validation
* Better handling for non-interactive environments
* More consistent naming conventions
* Safer sourcing behavior
* Documentation for each helper function
* Example scripts
* ShellCheck cleanup
* Basic tests or validation scripts

## Notes

These scripts are primarily intended for Bash, not POSIX `sh`.

Because this repository may contain scripts used for both personal and work-related tasks, avoid committing sensitive information, credentials, internal URLs, tokens, or environment-specific secrets.

## License

No license has been selected yet.

