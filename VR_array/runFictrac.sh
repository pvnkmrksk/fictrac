#!/bin/bash

dir1="/home/labadmin/fictrac/VR_array/VR1"
dir2="/home/labadmin/fictrac/VR_array/VR2"
dir3="/home/labadmin/fictrac/VR_array/VR3"
dir4="/home/labadmin/fictrac/VR_array/VR4"

start_fictrac="sudo ../../bin/fictrac config.txt"

gnome-terminal --tab -- bash -c "cd $dir1; $start_fictrac; exec bash"
gnome-terminal --tab -- bash -c "cd $dir2; $start_fictrac; exec bash"
gnome-terminal --tab -- bash -c "cd $dir3; $start_fictrac; exec bash"
gnome-terminal --tab -- bash -c "cd $dir4; $start_fictrac; exec bash"

