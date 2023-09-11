#!/bin/bash

USER_HOME=$(eval echo ~$(logname))



#alias rfic='sudo bash $HOME/src/fictrac/VR_array/runFictrac.sh'
# Prompt for sudo password once at the beginning to update the sudo timestamp
#sudo -v

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

#start_fictrac="sudo ../../bin/fictrac config.txt"
start_fictrac="$USER_HOME/src/fictrac/bin/fictrac config.txt"

# Start the fictrac in the corresponding dirs
for vr in $vr_list
do
  dir="$USER_HOME/src/fictrac/VR_array/VR$vr"
  echo "Opening fictrac in directory $dir"
  gnome-terminal --tab -- bash -c "cd $dir; $start_fictrac; exec bash"
done

