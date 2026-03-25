#!/usr/bin/env bash
set -euo pipefail
TOKEN="8347194542:AAEYApge3l1KBsndVyThD0Y0Ex87tKtMD7c"
CHAT_ID="2129253829"
TEXT="Cài Chat AI xong chưa?"
curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "text=${TEXT}" >/dev/null

# remove this cron job after run
TAG="#remind_20260325_1700"
crontab -l 2>/dev/null | grep -v "$TAG" | crontab -
