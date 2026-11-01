#!/usr/bin/env bash

set -eu
set -x

inittab="$1/etc/inittab"
entry='tty1::respawn:/usr/bin/fbterm'

if ! grep -Fxq "$entry" "$inittab"; then
    printf '%s\n' "$entry" >> "$inittab"
fi