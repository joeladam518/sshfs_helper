#!/usr/bin/env bash

## First, check if the user is running this script as root. 
if [ $(id -u) -ne 0 ]; then 
    echo "This install script needs root privileges to do it's job." 1>&2
    exit 1
fi

## Variables
CWD=$(pwd)
ULBIN="/usr/local/bin" # user's local bin
mmnt_script_name="mountsshfs.sh"
umnt_script_name="unmountsshfs.sh"

## Functions
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
    shift $((OPTIND - 1))
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

## Start Script

# Do you have a ~/mnt directory? if not, lets make one.
if [ -d "${HOME}/mnt" ]; then
    msg_c -g "Good, good, good you have a \"${HOME}/mnt/\" directory.😊"
    msg_c -g "FYI, this is where I will put all of your sshfs mounts."
else
    msg_c -y "Oh no! You don't have a \"${HOME}/mnt/\" directory!😮"
    msg_c -y "I will create one for you. This is where I will put all of your sshfs mounts.😊"
    cd "${HOME}" && mkdir "${HOME}/mnt"
    cd "${CWD}"
fi 

# TODO: Check to see if sshfs is installed. If it isn't, output error message and die.

# Set the proper permissions
msg_c -g "Setting the proper permissions."
cd "${CWD}/bin" && chmod 0744 ${mmnt_script_name} ${umnt_script_name}
cd "${CWD}"

# TODO: Ask to Edit the fuse config (at: /etc/fuse.conf) to allow non root users to use 
#       the "allow_other" option.

# Symlink these scripts 
msg_c -g "Symlinking the scripts."
cd "${ULBIN}" && ln -sf "${CWD}/bin/${mmnt_script_name}" "${mmnt_script_name%.*}"
cd "${ULBIN}" && ln -sf "${CWD}/bin/${umnt_script_name}" "${umnt_script_name%.*}"
cd "${CWD}"

# Reload the Environment
msg_c -g "Reloading the Environment."
cd "${HOME}" && source "${HOME}/.bashrc"

# Testing! Check to make sure the symlinks are there then run the script with -h
msg_c -g "ls'ing the ${ULBIN} directory."
ls -hlapv --color "${ULBIN}"
# mountsshfs -h
# unmountsshfs -h

## Finish Script (clean up & exit)

msg_c -g "Done installing."
cd "${CWD}"
exit 0
