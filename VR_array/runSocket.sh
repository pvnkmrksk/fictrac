#!/bin/bash

# This script launches socket republishers for VRs in separate tabs.
# If provided with a number, it will run only the specified VR. Otherwise, it will run all VRs up to the maximum number.
# Each VR republisher is run in its separate gnome-terminal tab.

# Define constants
MAX_VR=4
SOCK_HOST="127.0.0.1"
REPUBLISHER_PATH="$HOME/src/fictrac/VR_array/socket_zmq_republisher.py"

# Check for provided arguments
if [ -z "$1" ]; then
  # No argument: run all VRs
  VR_LIST=$(seq 1 $MAX_VR)
elif [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1 ] && [ "$1" -le $MAX_VR ]; then
  # Valid VR number provided: run only the specified VR
  VR_LIST=$1
else
  # Invalid argument
  echo "Invalid VR number. Please provide a number between 1 and $MAX_VR, or no number to run all VRs."
  exit 1
fi

# Loop through the list of VRs and launch each in a separate tab
for vr in $VR_LIST; do
  ZMQ_URL_PORT="987$(printf %01d $vr)"
  SOCK_PORT="111$(printf %01d $vr)"

  # Logging the action
  echo "Launching republisher for VR$vr on zmq-url tcp://*:$ZMQ_URL_PORT and socket $SOCK_HOST:$SOCK_PORT"

  # Execute the Python script in a new gnome-terminal tab
  gnome-terminal --tab -- bash -c "python $REPUBLISHER_PATH --zmq-url tcp://*:$ZMQ_URL_PORT --sock-host $SOCK_HOST --sock-port $SOCK_PORT; exec bash"
done

