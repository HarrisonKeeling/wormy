# Bash Worm
The purpose of this program is to scan for vulnerable raspberry pi's on a specified
ip range, attempt to break into them with the default SSH password, then copy itself
over, begin executing itself in a headless job, and detach from the remote host.

## Why?
This is made to explore the dangers and speed of self-replicating or portable
software attacks in my CS 683 course Computer Security and Privacy.  Writing it
in bash was just an added fun challenge I imposed upon myself, since I'm extremely
new to it!

## How it works
Currently, the main executable is `worm.sh`.  This file manages the scanning of
the network for open ssh ports, then starts up `probe.sh`, an expect shell script, 
to attempt to ssh into it.  If the probe script can successfully ssh into it, 
it spins up `copy.sh` in the background to copy the entire directory over over
`scp` using the password that was used to ssh into the device.  Then, the probe
script continues by starting up `worm.sh` on the remote device, then detaches from
the job to allow it to run once the ssh connection is closed.

## Current Limitations
- The program has been hard coded to only scan a default range, this ideally would
be able to be changed via a command line argument -- I just have not implemented it
yet.
- I'd love to make the `probe.sh` script run parallel for each target ip
- Only raspberry pi's with the username `pi` and password of `raspberry` will
be broken into.  This is a safety design feature or limitation, depending on who you
are.  The probe script has been written to take any username/ip/password combination
which allows this to be changed easily.  However, I'd like to implement the optionality
to iterate over a list of passwords to try -- I have the functionality to keep retying
a password, but it's not very useful if I can't change the password content for a brute
force style attack.
- It's not hidden very well in its current state.
- The worm really doesn't do much...  It is moreso "portable software" at this point.
I plan to fix this by opening a long polling connection to a remote server to allow
remote execution on a device once the worm is installed.  Would love to take the time
to explore putting a vulnerability at the spearhead to be able to do more advanced
attacks
