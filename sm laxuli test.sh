#!/bin/sh
printf '\033c\033]0;%s\a' sm laxuli test
base_path="$(dirname "$(realpath "$0")")"
"$base_path/sm laxuli test.x86_64" "$@"
