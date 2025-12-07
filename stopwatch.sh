#!/bin/sh

#######################################
## atom smasher's stopwatch - run a stopwatch in a terminal
## https://github.com/atom-smasher/
## v0.1     13 apr 2021
## v1.1-sh  08 dec 2025
## Distributed under the GNU General Public License
## http://www.gnu.org/copyleft/gpl.html

## setup
start=$( date -u +%s )
elapsed=0
clear_line="$(tput el)"
stty_orig=$(stty -g)

## function for trap
last_line () {
    echo "${clear_line}\t${time}"
    trap : EXIT
    stty "${stty_orig}"
    exit 0
}

## set the trap
trap 'last_line' EXIT INT TERM KILL

## the counter loop
stty -echo
while :
do
    ## this is an exercse in being extra-stingy with forks within the loop
    ## every 60 seconds, recalibrate the time with `date`
    ## the other 59/60 seconds (59/60 loop iterations, technically) just add one second to the counter
    [ "$(( ${elapsed} % 60 ))" -eq 0 ] && {
	## an init state, and calibration every 60 seconds
	elapsed=$(( $( date -u +%s) - ${start} ))
    } || {
	## avoiding a fork to `date` every second
	elapsed=$(( 1 + ${elapsed} ))
    }
    counter=$( date -ud@${elapsed} '+%H:%M:%S' )
    time=$(( ${elapsed} / 3600 / 24 ))":${counter} "
    time="${time#0:}"   ## trim 0 days
    time="${time#00:}"  ## trim 00 hours
    time="${time#00:}"  ## trim 00 minutes
    echo -n "${clear_line}\t${time}\r"
    ## at first glance, a `sleep 1` in a timer loop may seem like it's inviting a timing error, but
    ## it's really just updating the display. it's not controlling the timing.
    sleep 1
done
stty echo

exit
