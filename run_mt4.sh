#!/bin/bash

# Set virtual display
Xvfb :0 -screen 0 1024x768x16 >/dev/null 2>&1 &
export DISPLAY=:0

# Path to MT4
MT4_DIR="/root/.wine/drive_c/Program Files/MetaTrader 4"
LOG_DIR="$MT4_DIR/MQL4/Logs"

# Create log directory if not exists
mkdir -p "$LOG_DIR"

# Start MT4 in headless mode
wine "$MT4_DIR/terminal.exe" /config /app/mt4_config.ini /skipupdate /headless >/dev/null 2>&1 &

# Wait for MT4 to start
sleep 30

# Attach EA to a chart (using script)
wine "$MT4_DIR/terminal.exe" /s:attach_ea.mq4 >/dev/null 2>&1

# Get the latest log file
LATEST_LOG=$(ls -t "$LOG_DIR" | head -1)
LOG_FILE="$LOG_DIR/$LATEST_LOG"

# Tail the log file to stdout (Docker logs)
tail -n 0 -F "$LOG_FILE"