#!/bin/bash

# Define ZMQ URL ports
zmq_url_port1="9871"
zmq_url_port2="9872"
zmq_url_port3="9873"
zmq_url_port4="9874"

# Define socket ports
sock_port1="1111"
sock_port2="1112"
sock_port3="1113"
sock_port4="1114"

# Define socket host
sock_host="127.0.0.1"

# Define socket publish python file path
republisher_path="$HOME/src/fictrac/VR_array/socket_zmq_republisher.py"

# Execute the Python script in new tabs
gnome-terminal --tab -- bash -c "python $republisher_path --zmq-url tcp://*:$zmq_url_port1 --sock-host $sock_host --sock-port $sock_port1; exec bash"
gnome-terminal --tab -- bash -c "python $republisher_path --zmq-url tcp://*:$zmq_url_port2 --sock-host $sock_host --sock-port $sock_port2; exec bash"
gnome-terminal --tab -- bash -c "python $republisher_path --zmq-url tcp://*:$zmq_url_port3 --sock-host $sock_host --sock-port $sock_port3; exec bash"
gnome-terminal --tab -- bash -c "python $republisher_path --zmq-url tcp://*:$zmq_url_port4 --sock-host $sock_host --sock-port $sock_port4; exec bash"

