#!/usr/bin/env bash

# sample_dir.sh
#
# Simple Bash script to replicate a directory hierarchy, while
# preserving only a subset of files from each directory.
#
# By default, 5 files for each file extension will be copied,
# but this is configurable through optional arguments.
#
# USAGE: sample_dir.sh <source_dir> <dest_dir> [sample_size] [sample_exts]
#
# 	source_dir: 	The parent directory to be sampled
# 	dest_dir:	The new parent for the sampled data (will be created
# 			if missing).
# 	sample_size:	The number of files for each file extension to copy.
# 			Optional. Default: 5
# 	sample_exts:	Comma-separated list of extensions to include or
# 			exclude from the sample.
# 			Optional. Example: `csv,txt` or `!log,tmp`

# Fail early, fail fast, fail completely
set -euo pipefail

# Print usage information
usage() {
	echo "Sample Dir is a simple Bash script to replicate a directory hierarchy, while"
	echo "preserving only a subset of files from each directory."
	echo
	echo "USAGE: $0 <source_dir> <dest_dir> [sample_size] [sample_exts]"
	echo
	echo "	source_dir: 	The parent directory to be sampled"
	echo "	dest_dir:	The new parent for the sampled data (will be created"
	echo "			if missing)."
	echo "	sample_size:	The number of files for each file extension to copy."
	echo "			Optional. Default: 5"
	echo "	sample_exts:	Comma-separated list of extensions to include or"
	echo "			exclude from the sample."
	echo "			Optional. Example: 'csv,txt' or '!log,tmp'"
	echo "			NOTE: Extension lists MUST be quoted"
}

# Confirm required arguments have been received
if [ $# -lt 2 ] || [ $# -gt 4 ]; then
	usage
	exit 1
fi

# Retrieve arguments and set defaults
src=$1
dest=$2
sample_size=${3:-5} 	# Default to 5 if not provided
sample_exts=${4:-}	# Default is to include all extensions

# Confirm the source directory exists
if [ ! -d $src ]; then
	echo "ERROR: Source directory ($src) does not exist!"
	exit 2
fi


# Normalize input paths to absolute paths
src=$(realpath "$src")
dest=$(realpath "$dest")

# Create destination directory (if possible)
if ! mkdir -p "$dest"; then
	echo "ERROR: Unable to create destination directory ($dest)!"
	exit 2
fi

echo "Sampling $sample_size files from $1 to $2 ..."

# Create directory tree
echo "Building directory list ..."
while IFS= read -r rel_dir; do
    if [ -d "$dest/$rel_dir" ]; then
	continue
    fi
    echo "Creating $dest/$rel_dir ..."
    mkdir -p "$dest/$rel_dir"
done < <(find "$src" -type d -printf '%P\n')

# Copy up to `sample_size` files per extension per directory
echo "Building sample of $sample_size files per directory ..."

find "$src" -type f -printf '%P\n' \
  | awk -v N="$sample_size" -v FILTERS="$sample_exts" -F/ '
    BEGIN {
        if (length(FILTERS) > 0) {
            split(FILTERS,a,",")
            if (a[1] ~ /^!/) {
                mode="exclude"
            } else {
                mode="include"
            }
            for (i in a) {
                f=a[i]
                g=(f ~ /^!/) ? substr(f,2) : f
                if (length(g) > 0) exts[g]=1
            }
        }
    }
    {
        dir=$0
        sub(/[^/]+$/, "", dir)
        base=$NF
        n=split(base,arr,".")
        ext=(n>1)?arr[n]:"__NOEXT__"

        if (length(FILTERS) > 0) {
            if (mode=="include" && !(ext in exts)) next
            if (mode=="exclude" && (ext in exts)) next
        }

        key=dir ext
        if (count[key]++ < N) print $0
    }' \
  | while IFS= read -r rel_path; do
        dir=$(dirname "$rel_path")
        [ "$dir" = "." ] && dir=""
        echo "  Copying $rel_path to $dest/$dir/ ..."
        mkdir -p "$dest/$dir"
        cp -n "$src/$rel_path" "$dest/$dir/" || echo "Failed: $rel_path" >&2
    done
