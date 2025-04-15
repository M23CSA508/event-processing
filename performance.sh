#!/bin/bash

TOTAL_REQUESTS=100
INTERVAL=0.1 
TARGET_URL="http://localhost:8080/publish"

echo "[INFO] Starting API load test on macOS with $TOTAL_REQUESTS requests"
echo "[INFO] Interval: $INTERVAL seconds"

for ((i=1; i<=TOTAL_REQUESTS; i++)); do
    PAYLOAD=$(jq -n --arg val "$i" '{"type":"TEMP", "value":"ALERT:'"$val"'"}')
    curl -s -X POST "$TARGET_URL" \
         -H "Content-Type: application/json" \
         -d "$PAYLOAD" &
    sleep "$INTERVAL"
done

wait
