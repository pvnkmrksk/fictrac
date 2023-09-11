#!/bin/bash


# Enabling Mouse Support in tmux

#     Open or create the .tmux.conf file in your home directory:

#     bash

# nano ~/.tmux.conf

# Add the following line to enable mouse support:

# csharp

#     set -g mouse on

#     Save and close the file.

#     Restart your tmux or open a new session to see the changes.


# https://chat.openai.com/share/5e1082a5-effb-4090-9a4e-523efa2c7055



# Maximum VR number
max_vr=4

# Check if an argument is provided
if [ -z "$1" ]
then
  # If no argument is provided, run all VRs
  vr_list=$(seq 1 $max_vr)
else
  # If the argument is a valid number (1-max_vr), use it as the VR number
  if [ "$1" -ge 1 ] && [ "$1" -le $max_vr ]
  then
    vr_list=$1
  else
    echo "Invalid VR number. Please provide a number between 1 and $max_vr, or no number to run all VRs."
    exit 1
  fi
fi

# Define socket host
sock_host="127.0.0.1"

# Define socket publish python file path
republisher_path="$HOME/src/fictrac/VR_array/socket_zmq_republisher.py"

# Create a unique window ID based on the current timestamp
window_name="VR_$(date +%s)"

# Check if the session exists. If not, create one.
tmux has-session -t VRSession 2>/dev/null || tmux new-session -d -s VRSession

# Create a new window in the session using the unique window ID
tmux new-window -t VRSession -n $window_name

# Start the Python script in the corresponding VRs
for vr in $vr_list
do
  # If not the first pane, split the pane vertically
  if [ "$vr" -gt 1 ]
  then
    tmux split-window -v -t VRSession:$window_name
    tmux select-layout -t VRSession:$window_name tiled
  fi

  # Define ZMQ URL port and socket port based on the VR number
  zmq_url_port="987$(printf %01d $vr)"
  sock_port="111$(printf %01d $vr)"

  # Execute the Python script in the pane
  tmux send-keys -t VRSession:$window_name "python $republisher_path --zmq-url tcp://*:$zmq_url_port --sock-host $sock_host --sock-port $sock_port" C-m
done

# Attach to the tmux session after creating all windows and panes
tmux attach -t VRSession:$window_name
