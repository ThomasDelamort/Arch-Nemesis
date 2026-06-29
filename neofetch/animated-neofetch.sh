#!/usr/bin/env bash
# ============================================================
#  animated-neofetch.sh — Gargantua that keeps orbiting with
#  your system info shown right beside it. Loops until you
#  press any key, then leaves a fresh static fetch on screen.
#
#  Usage:  animated-neofetch.sh [delay_seconds]   (default 0.05)
# ============================================================
set -u
DELAY="${1:-0.05}"
DIR="$HOME/.config/neofetch"
FRAMES="$DIR/frames_colour"
CONF="$DIR/config.conf"
LOGO_W=54        # frames are padded to this many visible columns
GAP=4            # spaces between the logo and the info column
TOP=2            # blank lines above the whole fetch

# Grab the info block ONCE (no logo), preserving colours by faking a
# tty with `script` — neofetch strips colour when piped normally.
mapfile -t INFO < <(script -qec "neofetch --config '$CONF' --backend off" /dev/null 2>/dev/null | sed 's/\r$//')

shopt -s nullglob
FRAME_FILES=("$FRAMES"/frame_*.txt)
[[ ${#FRAME_FILES[@]} -eq 0 ]] && { echo "No frames in $FRAMES"; exit 1; }

printf -v BLANK '%*s' "$LOGO_W" ''         # a logo-width blank line
cleanup(){ printf '\033[?25h\n'; }          # restore cursor on exit
trap cleanup EXIT INT TERM
printf '\033[?25l'; clear

while true; do
    for f in "${FRAME_FILES[@]}"; do
        mapfile -t L < "$f"
        rows=$(( ${#L[@]} > ${#INFO[@]} ? ${#L[@]} : ${#INFO[@]} ))
        printf '\033[H'
        for ((t=0; t<TOP; t++)); do printf '\033[K\n'; done
        for ((i=0; i<rows; i++)); do
            left="${L[i]-$BLANK}"
            printf '%s%*s%s\033[0m\n' "$left" "$GAP" '' "${INFO[i]-}"
        done
        # the sleep AND the keypress check, in one call
        read -rsn1 -t "$DELAY" && { clear; for ((t=0;t<TOP;t++)); do echo; done; neofetch --config "$CONF"; exit 0; }
    done
done
