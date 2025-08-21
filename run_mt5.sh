#!/bin/bash

# Set virtual display
Xvfb :0 -screen 0 1024x768x16 >/dev/null 2>&1 &
export DISPLAY=:0

# Path to MT5
MT5_DIR="/root/.wine/drive_c/Program Files/MetaTrader 5"
LOG_DIR="$MT5_DIR/MQL5/Logs"

# Create log directory if not exists
mkdir -p "$LOG_DIR"

# Start MT5 in headless mode
wine "$MT5_DIR/terminal64.exe" /config /app/mt5_config.ini /skipupdate /headless >/dev/null 2>&1 &

# Wait for MT5 to start
sleep 30

# Attach EA to a chart (using script)
#wine "$MT4_DIR/terminal.exe" /s:attach_ea.mq4 >/dev/null 2>&1

# Get the latest log file
LATEST_LOG=$(ls -t "$LOG_DIR" | head -1)
LOG_FILE="$LOG_DIR/$LATEST_LOG"

# Tail the log file to stdout (Docker logs)
tail -n 0 -F "$LOG_FILE"