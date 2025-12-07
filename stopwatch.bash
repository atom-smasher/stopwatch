#!/bin/bash

#######################################
## atom smasher's stopwatch - run a stopwatch in a terminal
## https://github.com/atom-smasher/
## v0.1      13 apr 2021
## v1.1-bash 08 dec 2025
## Distributed under the GNU General Public License
## http://www.gnu.org/copyleft/gpl.html

## setup
enable printf
start=$EPOCHSECONDS
clear_line="$(tput el)"

## function for trap
last_line () {
    echo -e "${clear_line}\t${time}"
    trap : EXIT
    exit 0
}

## set the trap
trap 'last_line' EXIT INT TERM KILL

## the counter loop
while :
do
    elapsed=$(( ${EPOCHSECONDS} - ${start} ))
    counter=$(TZ=0 printf '%(%T)T' ${elapsed})
    time=$(( ${elapsed} / 3600 / 24 ))":${counter} "
    time="${time#0:}"   ## trim 0 days
    time="${time#00:}"  ## trim 00 hours
    time="${time#00:}"  ## trim 00 minutes
    ## `read -t 1` serves the purpose of `sleep 1`, without a fork.
    ## at first glance, a `sleep 1` in a timer loop may seem like it's inviting a timing error, but
    ## it's really just updating the display. it's not controlling the timing.
    read -t 1 -s -p "$(echo -ne "${clear_line}\t${time}\r")"
done
