#!/bin/bash
# Simple monitor for the OpenWrt build. Appends a snapshot to build-monitor.log every 5 minutes.
LOG=build-monitor.log
BUILD_DIR=openwrt
PID_FILE=build.pid
while true; do
  echo "--- $(date) ---" >> "$LOG"
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
      echo "build PID $PID is running" >> "$LOG"
    else
      echo "build PID $PID is NOT running" >> "$LOG"
    fi
  else
    echo "build.pid not found" >> "$LOG"
  fi
  echo "Last 50 lines of build-output.log:" >> "$LOG"
  tail -n 50 build-output.log >> "$LOG" 2>/dev/null || echo "(no build-output.log yet)" >> "$LOG"
  echo "Output dir listing:" >> "$LOG"
  ls -lh "$BUILD_DIR/bin/targets/rockchip/armv8/" >> "$LOG" 2>/dev/null || echo "(no output dir yet)" >> "$LOG"
  echo "--- end snapshot ---" >> "$LOG"
  sleep 300
done
