#!/bin/bash
set -e

# Start D-Bus daemon (required for some Qt applications)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
    export DBUS_SESSION_BUS_ADDRESS
fi

# Start a dummy audio server (so s.boot works without a soundcard)
# -r = realtime disabled, -d dummy = no hardware output
jackd -r -d dummy -r 44100 -p 1024 &
JACK_PID=$!

# Wait for JACK to be ready
sleep 2

# Run the command passed to docker (default: scide)
exec "$@"
