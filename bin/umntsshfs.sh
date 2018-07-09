#!/usr/bin/env bash

## First, check if the user is running this script as root. 
if [ $(id -u) -eq 0 ]; then 
    echo "You should never run \"${0##*/}\" as root. Please try again." 1>&2
    exit 1
fi

## Get the Valid Server name to use for this script
valid_servers=($(grep -w -i "Host" ~/.ssh/config | sed 's/Host//' | tr '\n' ' ' | sed 's/\* //' ))

## Set the rest of the Variables for this script
CWD=$(pwd)
verbose=0
testing_mode=0
server_to_unmount=""
parentdirpath="${HOME}/mnt"
localdirpath=""
valid_server=""

## Script Functions
msg_c() { # Output messages in color! :-)
    local OPTIND=1; local o; local newline="1"; local CHOSEN_COLOR; local RESET=$(tput sgr0);
    while getopts ":ndrgbcmya" o; do
        case "${o}" in 
            n) newline="0" ;; # no new line
            d) CHOSEN_COLOR=$(tput bold) ;;    # bold
            r) CHOSEN_COLOR=$(tput setaf 1) ;; # color red
            g) CHOSEN_COLOR=$(tput setaf 2) ;; # color green
            b) CHOSEN_COLOR=$(tput setaf 4) ;; # color blue
            c) CHOSEN_COLOR=$(tput setaf 6) ;; # color cyan
            m) CHOSEN_COLOR=$(tput setaf 5) ;; # color magenta
            y) CHOSEN_COLOR=$(tput setaf 3) ;; # color yellow
            a) CHOSEN_COLOR=$(tput setaf 7) ;; # color gray
            \? ) echo "msg_c() invalid option: -${OPTARG}"; return ;;
        esac
    done
    shift "$((OPTIND-1))"   # Discard the options and sentinel --
    if [ ! -z $CHOSEN_COLOR ] && [ $newline == "1" ]; then
        echo -e "${CHOSEN_COLOR}${1}${RESET}"
    elif [ ! -z $CHOSEN_COLOR ] && [ $newline == "0" ]; then  
        echo -ne "${CHOSEN_COLOR}${1}${RESET}"
    elif [ -z $CHOSEN_COLOR ] && [ $newline == "0" ]; then  
        echo -n "${1}"
    else
        echo "${1}"
    fi
}
show_help() {
cat << EOF
Usage: ${0##*/} [-htv] [SERVER_NAME]...
This script helps make it easier to use the sshfs program. Uses
your ssh config file to generate the valid servers to unmount.

    -h      Display this help and exit.
    -t      Testing mode. Will not run the sshfs command. Just echo it   
    -v      Verbose mode. Can be used multiple times for increased verbosity.
EOF
}
show_valid_servers() {
    msg_c -d "The valid servers are:"
    echo "${valid_servers[@]}" | tr ' ' '\n'
}

## Parse the arguments and options for this script 
OPTIND=1;
while getopts ":htv" opt; do
    case ${opt} in
        h)  show_help
            exit 0
            ;;
        t)  testing_mode=1
            ;;
        v)  verbose=$((verbose+1))
            ;;
        \?) msg_c -r "${0##*/} invalid option: -${OPTARG}" 1>&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"   # Discard the options and sentinel --
server_to_unmount=${1}

if [ $verbose -gt 2 ]; then
    msg_c -c "server to unmount: ${server_to_unmount}"
fi

# Make sure we have a server to mount
if [ -z $server_to_unmount ]; then
    msg_c -r "No server name provided." 1>&2
    show_valid_servers
    exit 1
fi

for valid_server in "${valid_servers[@]}"; do 
    if [[ "$valid_server" == "$1" ]]; then 
        localdirpath="${parentdirpath}/${server_to_unmount}"
    fi
done

if [ -z $localdirpath ]; then
    msg_c -r "Not a valid site to unmount. Try of these: "
    mount | grep $parentdirpath
    exit 1
fi

if [ $testing_mode == 1 ]; then
    echo ""
    msg_c -m "The sshfs mount command: "
    echo "fusermount -u $localdirpath"
    echo ""
    exit 0
fi

previous_num_of_mounted_dirs=$(mount | grep $parentdirpath | wc -l)

#fusermount -u $localdirpath # The specific sshfs linux way
umount $localdirpath # The general way (makes me nervous)

current_num_of_mounted_dirs=$(mount | grep $parentdirpath | wc -l)

## Finish Script (clean up & exit)

if [ $verbose -gt 0 ]; then
    msg_c -a "previous_num_of_mounted_dirs = ${previous_num_of_mounted_dirs}"
    msg_c -a " current_num_of_mounted_dirs = ${current_num_of_mounted_dirs}"
fi

if [ $current_num_of_mounted_dirs -lt $previous_num_of_mounted_dirs ]; then
    msg_c -g "Successfully unmounted server \"${server_to_unmount}\""
else
    msg_c -r "Failed to unmount server \"${server_to_unmount}\""
fi

exit 0
