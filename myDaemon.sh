#!/usr/bin/env bash

# Created By: Joel D. Ultimate
# Date: 2021-11-02

DAEMONNAME="MY-DAEMON"

# $$ is the process ID (PID) of the script itself
MYPID=$$
# gets the directory path of the script
PIDDIR="$(dirname "${BASH_SOURCE[0]}")"
PIDFILE="${PIDDIR}/${DAEMONNAME}.pid"

LOGDIR="$(dirname "${BASH_SOURCE[0]}")"

# To use a dated log file
# LOGFILE=${LOGDIR}/${DAEMONNAME}-$(date +"%Y-%m-%dT:%H:%M:%SZ).log
# To use a regular log file
LOGFILE="${LOGDIR}/${DAEMONNAME}.log"

#Technical name for date style on line 17 is ISO 8601
# Log max size in KB
LOGMAXSIZE=1024 # 1 mb

RUNINTERVAL=60 #In seconds

doCommands() {
	# Commands needed for Daemon
	echo "Running commands..."
	log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": an important message or log detail..."
}

########################################################################################

# Below is the template functionality of the daemon.

#######################################################################################

setupDaemon() {
	#Make sure that the directories work
	if [[ ! -d "${PIDDIR}" ]]; then
		mkdir "${PIDDIR}"
	fi

	if [[ ! -d "${LOGDIR}" ]]; then
		mkdir "${LOGDIR}"
	fi

	if [[ ! -f "${LOGFILE}" ]]; then
		touch "${LOGFILE}"
	else

	# Check to see if we need to rotate the logs
	SIZE=$(( $(stat --printf="%s" "${LOGFILE}") / 1024 ))

		if [[ $size -gt ${LOGMAXSIZE} ]]; then
			mv ${LOGFILE} "${LOGFILE}.$(date +%Y-%m-%dT%H:%M:%S).old"
			touch "${LOGFILE}"
		fi
	fi
}

startDaemon() {
	# Start the daemon
	setupDaemon # Make sure directories are there

	if ! checkDaemon; then
		echo 1>&2 " *Error: ${DAEMONNAME} is already running."
		log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": %USER already running ${DAEMONNAME} PID: "$(cat ${PIDFILE})
		exit 1
	fi

	echo " * Starting ${DAEMONNAME} with PID: ${MYPID}."
	echo "${MYPID}" > "${PIDFILE}"

	log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": $USER Starting up ${DAEMONNAME} PID: ${MYPID}"
	# Start the loop
	loop
}
# Study syntax
stopDaemon() {
	# Stop the Daemon.
	if checkDaemon; then
		echo 1>&2 " * Error: ${DAEMONNAME} is not running"
		exit 1
	fi

	echo " * Stopping ${DAEMONNAME}"

	if [[ ! -z $(cat "${PIDFILE}") ]]; then
		kill -9 $(cat "${PIDFILE}") &> /dev/null
		log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": ${DAEMONNAME} Stopped."
	else
		echo 1>&2 "Cannot find PID of running Daemon!"
	fi
}

statusDaemon() {
	#Query and return whether the daemon is running
	if ! checkDaemon; then
		echo " * ${DAEMONNAME} is running."
		log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": ${DAEMONNAME} $USER checked status - Running with PID:${MYPID}"

	else
		echo " * ${DAEMONNAME} is not running."
		log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": ${DAEMONNAME} $USER checked status - Not running."
	fi
	exit 0
}

restartDaemon() {
	#Restart the Daemon
	if checkDaemon; then
		# Cannot restart it if it isn't running
		echo "${DAEMONNAME} isn't running."
		log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": ${DAEMONNAME} restarted"
		exit 1
	fi
	stopDemon
	startDaemon
}

checkDaemon() {
	# Check to see if the Daemon is still running
	# This is different compared to status function
	# so we can't use it in other functions
	if [[ -z "${OLDPID}" ]]; then
		return 0
	elif ps -ef | grep "${OLDPID}" | grep -v &>  /dev/null ; then
		if [[ -f "${PIDFILE}" && $(cat "${PIDFILE}") -eq ${OLDPID} ]]; then
		# Daemon is running.
		return 1
	else
		# Daemon isn't running
		return 0
	fi
	elif ps -ef | grep "${DAEMONNAME}" | grep -v grep | grep -v "${MYPID}" | grep -v "0:00.00" | grep bash &> /dev/null ; then
		# Daemon is running but without the correct PID, restart it
		log '*** '$(date +"%Y-%m-%dT%H:%M:%SZ")": ${DAEMONNAME} is running with invalid PID: restarting..."
		restartDaemon
		return 1
	else
		# Daemon not running.
		return 0
	fi
	return 1
}

loop() {
	while true; do

		doCommands
		sleep 60
	done
}

log() {
	# Generic log function.
	echo "$1" >> "${LOGFILE}"
}

#######################################################################################################

# Parse the command.

#######################################################################################################

if [[ -f "${PIDFILE}" ]]; then
	OLDPID=$(cat "${PIDFILE}")
fi

checkDaemon

case "$1" in
	start)
		startDaemon
		;;
	stop)
		stopDaemon
		;;
	status)
		statusDaemon
		;;
	restart)
		restartDaemon
		;;
	*)
	echo 1>&2" * Error: usage $0 {start | stop | restart | status }"
	exit 1
esac

# Close the program as intended
exit 0
