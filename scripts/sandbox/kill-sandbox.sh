#!/bin/bash

echo "Killing all NEAR sandbox processes..."

# Method 1: Kill by process name
echo "Killing near-sandbox processes..."
pkill -f near-sandbox 2>/dev/null && echo "✓ Killed near-sandbox processes" || echo "ℹ No near-sandbox processes found"

# Method 2: Kill processes listening on sandbox ports
echo "Killing processes on sandbox ports (3030, 4000, 9001)..."
PIDS=$(lsof -ti:3030,4000,9001 2>/dev/null)
if [ ! -z "$PIDS" ]; then
    kill $PIDS 2>/dev/null && echo "✓ Killed processes on sandbox ports" || echo "⚠ Failed to kill some processes"
else
    echo "ℹ No processes found on sandbox ports"
fi

# Method 3: Check if any sandbox processes are still running
sleep 1
REMAINING=$(ps aux | grep -E "(near-sandbox|sandbox)" | grep -v grep | wc -l)
if [ "$REMAINING" -gt 0 ]; then
    echo "⚠ Some sandbox processes may still be running. Trying force kill..."
    pkill -9 -f near-sandbox 2>/dev/null || true
    killall -9 near-sandbox 2>/dev/null || true
fi

echo "✓ Sandbox cleanup completed!"

# Verify cleanup
echo "Verifying cleanup..."
if lsof -ti:3030,4000,9001 >/dev/null 2>&1; then
    echo "⚠ Warning: Some processes may still be listening on sandbox ports"
    lsof -i:3030,4000,9001
else
    echo "✓ All sandbox ports are now free"
fi
