#!/usr/bin/env python3

import socket
import select
import zmq
import json
import math
import click

# Define a function to process one line of data from FicTrac
def process_line(line, socket_zmq):
    # Tokenise
    toks = line.split(", ")

    # Check that we have sensible tokens
    if ((len(toks) < 24) | (toks[0] != "FT")):
        print('Bad read')
        return

    # Extract FicTrac variables
    # (see https://github.com/rjdmoore/fictrac/blob/master/doc/data_header.txt for descriptions)
    x = float(toks[15])
    y = float(toks[16])
    yaw = float(toks[17])

    # Do something ...
    data_zmq = {
        "x": x,
        "y": y,
        "z": 0.0,
        "yaw": math.degrees(yaw),
        "pitch": 0.0,
        "roll": 0.0
    }
    socket_zmq.send_string(json.dumps(data_zmq))

# Define the main command using click decorators
@click.command()
@click.option('--zmq-url', type=str, default='tcp://*:9871',
              help='The URL to bind the ZMQ socket to.')
@click.option('--sock-host', type=str, default='127.0.0.1',
              help='The host IP address to bind the UDP socket to.')
@click.option('--sock-port', type=int, default=1111,
              help='The host port to bind the UDP socket to.')
@click.option('--timeout', type=int, default=1,
              help='The timeout in seconds for receiving data from FicTrac.')
def main(zmq_url, sock_host, sock_port, timeout):
    """A script to receive data from FicTrac and send it to ZMQ."""
    
    # Create a ZMQ context and socket
    context = zmq.Context()
    socket_zmq = context.socket(zmq.PUB)
    socket_zmq.bind(zmq_url)

    # Create a UDP socket and bind it to the host and port
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        sock.bind((sock_host, sock_port))
        sock.setblocking(0)

        # Keep receiving data until FicTrac closes
        data = ""

        while True:
            # Check to see whether there is data waiting
            ready = select.select([sock], [], [], timeout)

            # Only try to receive data if there is data waiting
            if ready[0]:
                # Receive one data frame
                new_data = sock.recv(1024)

                # Uh oh?
                if not new_data:
                    break

                # Decode received data
                data += new_data.decode('UTF-8')

                # Find the first frame of data
                endline = data.find("\n")
                line = data[:endline]       # copy first frame
                data = data[endline+1:]     # delete first frame

                # Process the line of data
                process_line(line, socket_zmq)

            else:
                # Didn't find any data - try again
                print('retrying...')

# Run the main command if this is the main script
if __name__ == '__main__':
    main()