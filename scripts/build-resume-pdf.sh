#!/bin/sh
# Rebuild resume.pdf from the print sheet in index.html.
# GitHub Pages serves this file; the Download button does not use window.print(),
# so the PDF has no browser date, title, or URL header.
set -eu
cd "$(dirname "$0")/.."
port="${PORT:-8771}"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [ ! -x "$chrome" ]; then
  echo "Google Chrome is required to build resume.pdf" >&2
  exit 1
fi
python3 -m http.server "$port" >/tmp/resume-pdf-server.log 2>&1 &
server=$!
trap 'kill "$server" 2>/dev/null || true' EXIT
i=0
while [ "$i" -lt 50 ]; do
  if curl -sf -o /dev/null "http://127.0.0.1:${port}/"; then
    break
  fi
  i=$((i + 1))
  sleep 0.1
done
"$chrome" \
  --headless \
  --disable-gpu \
  --no-pdf-header-footer \
  --window-size=794,1123 \
  --print-to-pdf="$(pwd)/resume.pdf" \
  --virtual-time-budget=10000 \
  "http://127.0.0.1:${port}/?pdf=$(date +%s)"
echo "wrote $(pwd)/resume.pdf"
