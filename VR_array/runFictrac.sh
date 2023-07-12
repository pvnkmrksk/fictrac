#!/bin/bash

dir1="$HOME/src/fictrac/VR_array/VR1"
dir2="$HOME/src/fictrac/VR_array/VR2"
dir3="$HOME/src/fictrac/VR_array/VR3"
dir4="$HOME/src/fictrac/VR_array/VR4"

start_fictrac="sudo ../../bin/fictrac config.txt"

gnome-terminal --tab -- bash -c "cd $dir1; $start_fictrac; exec bash"
gnome-terminal --tab -- bash -c "cd $dir2; $start_fictrac; exec bash"
gnome-terminal --tab -- bash -c "cd $dir3; $start_fictrac; exec bash"
gnome-terminal --tab -- bash -c "cd $dir4; $start_fictrac; exec bash"

