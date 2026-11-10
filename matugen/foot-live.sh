#!/bin/sh
f="$HOME/.local/state/foot/colors.ini"
[ -f "$f" ] || exit 0
t=/tmp/foot-live.seq
awk -F= '
function clean(s) { gsub(/[ #\r]/, "", s); return substr(s, 1, 6) }
$1 ~ /^ *foreground *$/ { printf "\033]10;#%s\007", clean($2) }
$1 ~ /^ *background *$/ { printf "\033]11;#%s\007", clean($2) }
$1 ~ /^ *regular[0-7] *$/ { n = $1; gsub(/[^0-9]/, "", n); printf "\033]4;%d;#%s\007", n, clean($2) }
$1 ~ /^ *bright[0-7] *$/ { n = $1; gsub(/[^0-9]/, "", n); printf "\033]4;%d;#%s\007", n + 8, clean($2) }
' "$f" > "$t"
for p in /dev/pts/[0-9]*; do
  [ -w "$p" ] && cat "$t" > "$p" 2>/dev/null
done
rm -f "$t"
