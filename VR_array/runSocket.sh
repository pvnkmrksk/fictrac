#!/bin/bash

# alias rsoc='bash $HOME/src/fictrac/VR_array/runSocket.sh'

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

# Start the Python script in the corresponding VRs
for vr in $vr_list
do
  # Define ZMQ URL port and socket port based on the VR number
  zmq_url_port="987$(printf %01d $vr)"
  sock_port="111$(printf %01d $vr)"

  # Execute the Python script in a new tab
  gnome-terminal --tab -- bash -c "python $republisher_path --zmq-url tcp://*:$zmq_url_port --sock-host $sock_host --sock-port $sock_port; exec bash"
done
