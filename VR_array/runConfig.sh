#!/bin/bash

# check if an argument is provided
if [ -z "$1" ]
then
  echo "Please provide a VR number as an argument (1-4)"
  exit 1
fi

# check if the argument is a valid number (1-4)
if [ "$1" -lt 1 ] || [ "$1" -gt 4 ]
then
  echo "Invalid VR number. Please provide a number between 1 and 4."
  exit 1
fi

# use the argument to define the dir and start_fictrac
dir="$HOME/src/fictrac/VR_array/VR$1"
start_fictrac="../../bin/configGui config.txt"

# start the fictrac in the corresponding dir
gnome-terminal --tab -- bash -c "cd $dir; $start_fictrac; exec bash"

