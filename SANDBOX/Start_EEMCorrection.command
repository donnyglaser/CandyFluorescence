#!/bin/bash
cd "$(dirname "$0")"

echo "Welcome to the CaNDy Lab EEM correction tool"
echo "Copy/paste the path to the directory here:"
read -r user_path

# remove surrounding quotes (happens when dragging from Finder)
# user_path=$(echo "$user_path" | sed 's/^"//;s/"$//')
user_path=$(echo "$user_path" | sed "s/^['\"]//;s/['\"]$//")

echo "Correcting EEMs in: $user_path"

/usr/bin/env Rscript MAIN.R "$user_path"

## this works!! ##