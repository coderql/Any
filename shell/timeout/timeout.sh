#!/usr/bin/bash

PN=`basename "$0"`			# Program name
VER='1.3'
 
TIMEOUT=5				# Default [seconds]
 
Usage () {
    echo >&2 "$PN - set timeout for a command, $VER
usage: $PN [-t timeout] command [argument ...]
     -t: timeout (in seconds, default is $TIMEOUT)"
    exit 1
}
 
Msg () {
    for MsgLine
    do 
        echo "$PN: $MsgLine" >&2
    done
}
 
Fatal () { Msg "$@"; exit 1; }
 
while [ $# -gt 0 ]
do
    case "$1" in
	-p)	ParentPID=$2; shift;;	# Used internally!
	-t)	Timeout="$2"; shift;;
	--)	shift; break;;
	-h)	Usage;;
	-*)	Usage;;
	*)	break;;			# First file name
    esac
    shift
done
 
: ${Timeout:=$TIMEOUT}			# Set default [seconds]
 
if [ -z "$ParentPID" ]
then
    # This is the first invokation of this script.
    # Start "watchdog" process, and then run the command.
    [ $# -lt 1 ] && Fatal "please specify a command to execute"
    "$0" -p $$ -t $Timeout &		# Start watchdog
    #echo >&2 "DEBUG: process id is $$"
    exec "$@"				# Run command
    exit 2				# NOT REACHED
else
    # We run in "watchdog" mode, $ParentPID contains the PID
    # of the process we should terminate after $Timeout seconds.
    [ $# -ne 0 ] && Fatal "please do not use -p option interactively"
 
    #echo >&2 "DEBUG: $$: parent PID to terminate is $ParentPID"
 
    exec >/dev/null 0<&1 2>&1	# Suppress error messages
    sleep $Timeout
    kill $ParentPID &&			# Give process time to terminate
    	(sleep 2; kill -1 $ParentPID) &&
	(sleep 2; kill -9 $ParentPID)
    exit 0
fi

