#!/bin/sh

echo
echo "+------------------------------+"
echo "|    FicTrac install script    |"
echo "+------------------------------+"
echo

# Get Ubuntu version	
ver="$(lsb_release -sr)"
echo "Found Ubuntu version $ver "

if [ "$ver" = "22.04" ] || [ "$ver" = "20.04" ] || [ "$ver" = "24.04" ]; then
	echo
	echo "+-- Installing dependencies ---+"
	echo
	sudo apt-get update
	sudo apt-get install -y gcc g++ cmake libavcodec-dev libnlopt-dev libboost-dev libopencv-dev tmux bash python3 python3-pip python3-zmq dbus-x11 v4l-utils guvcview
	

	echo
	echo "+-- Creating build directory --+"
	echo
	# Get the absolute path to the script directory
	SCRIPT_PATH="$(readlink -f "$0")"
	FICTRAC_DIR="$(dirname "$SCRIPT_PATH")"
	cd "$FICTRAC_DIR"	# make sure we are in fictrac dir
	if [ -d ./build ]; then
		echo "Removing existing build dir"
		rm -r ./build
	fi
	mkdir build
	if [ -d ./build ]; then
		echo "Created build dir"
		cd ./build
	else
		echo "Error: Failed to create build directory!"
		exit 1
	fi
	
	echo
	echo "+-- Generating build files ----+"
	echo
	cmake ..
	
	echo
	echo "+-- Building FicTrac ----------+"
	echo
	cmake --build . --config Release --parallel $(nproc) --clean-first
	
	cd ..
	if [ -f ./bin/fictrac ]; then
		echo
		echo "FicTrac built successfully!"
		echo
		
		echo
		echo "+-- Setting up aliases --------+"
		echo
		
		# Get absolute path of FICTRAC_DIR (already have it from above)
		FICTRAC_ABS_PATH="$FICTRAC_DIR"
		
		# Add each alias individually with absolute path
		ALIAS1="alias rcon='bash ${FICTRAC_ABS_PATH}/VR_array/runConfig.sh'"
		ALIAS2="alias rsoc='bash ${FICTRAC_ABS_PATH}/VR_array/runSocket.sh'"
		ALIAS3="alias rfic='sudo bash ${FICTRAC_ABS_PATH}/VR_array/runFictrac.sh'"
		
		# Check and add each alias
		if ! grep -q "$ALIAS1" ~/.bashrc; then
			echo "$ALIAS1" >> ~/.bashrc
			echo "Added alias to ~/.bashrc: $ALIAS1"
		else
			echo "Alias already exists in ~/.bashrc: $ALIAS1"
		fi
		
		if ! grep -q "$ALIAS2" ~/.bashrc; then
			echo "$ALIAS2" >> ~/.bashrc
			echo "Added alias to ~/.bashrc: $ALIAS2"
		else
			echo "Alias already exists in ~/.bashrc: $ALIAS2"
		fi
		
		if ! grep -q "$ALIAS3" ~/.bashrc; then
			echo "$ALIAS3" >> ~/.bashrc
			echo "Added alias to ~/.bashrc: $ALIAS3"
		else
			echo "Alias already exists in ~/.bashrc: $ALIAS3"
		fi

		# Add aliases to zsh config if it exists
		if [ -f ~/.zshrc ]; then
			if ! grep -q "$ALIAS1" ~/.zshrc; then
				echo "$ALIAS1" >> ~/.zshrc
				echo "Added alias to ~/.zshrc: $ALIAS1"
			fi
			
			if ! grep -q "$ALIAS2" ~/.zshrc; then
				echo "$ALIAS2" >> ~/.zshrc
				echo "Added alias to ~/.zshrc: $ALIAS2"
			fi
			
			if ! grep -q "$ALIAS3" ~/.zshrc; then
				echo "$ALIAS3" >> ~/.zshrc
				echo "Added alias to ~/.zshrc: $ALIAS3"
			fi
		fi
		
		echo
		echo "Run 'rcon' to start the config GUI" 
		echo "Run 'rsoc' to start the socket server"
		echo "Run 'rfic' to start the fictrac"
		echo
		
		# Source the configuration files to activate aliases
		echo "Activating aliases in current session..."
		if [ -f ~/.bashrc ]; then
			source ~/.bashrc
		fi
		if [ -f ~/.zshrc ]; then
			source ~/.zshrc
		fi
		echo "Aliases activated!"
		echo
	else
		echo
		echo "Error: FicTrac executable not found after build!"
		echo
		exit 1
	fi
else
	echo "Error: Unsupported Ubuntu version: $ver"
	exit 1
fi
