#!/bin/bash
set -e

# 1. Start a dummy audio server (so s.boot works without a soundcard)
# -r = realtime disabled, -d dummy = no hardware output
jackd -r -d dummy -r 44100 -p 1024 &
JACK_PID=$!

# 2. Wait a moment for JACK to be ready
sleep 2

# 3. Run the command passed to docker (default: sclang)
# xvfb-run wraps execution to provide a fake display for QT
exec xvfb-run -a "$@"
