#!/usr/bin/env bash

## First, check if the user is running this script as root. 
if [ $(id -u) -ne 0 ]; then 
    echo "This install script needs root privileges to do it's job." 1>&2
    exit 1
fi

## Variables
CWD=$(pwd)
ULBIN="/usr/local/bin" # users local bin
mmnt_script_name="mntsshfs.sh"
umnt_script_name="umntsshfs.sh"

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
determine_computer_type() {
    local machine
    local unameOut="$(uname -s)"

    case "${unameOut}" in
        Linux*)     machine="Linux"   ;;
        Darwin*)    machine="Mac"     ;;
        CYGWIN*)    machine="Cygwin"  ;;
        *)          machine="UNKNOWN" ;;
    esac

    echo ${machine}
}

## Start Script

# Lets see if we can what computer this bash script is running on.
computer_type=$(determine_computer_type)
msg_c -nc "You computer type is: " 
msg_c -a  "${computer_type}"

if [ "${computer_type}" == "UNKNOWN" ]; then
    msg_c -r "I couldn't figure out your computer type... Exiting... ☹️" 1>&2
    exit 1
fi

# TODO: Check and see if the mount/unmount are where they are supposed to be. 
#       If they are not, output error message and die.

# Unlink these scripts 
msg_c -g "un-symlinking the scripts"
cd "${ULBIN}" && rm "./${mmnt_script_name%.*}"
cd "${ULBIN}" && rm "./${umnt_script_name%.*}"
cd "${CWD}"

# Reset the proper permissions
msg_c -g "Resetting the permissions"
cd "${CWD}/bin" && chmod 0644 ${mmnt_script_name} ${umnt_script_name}
cd "${CWD}"

# TODO: Ask to reset the fuse config (at: /etc/fuse.conf) to stop allowing non root users 
#       to be allowed to use the "allow_other" option.

# Remove the sshfs helper auto completion script from the "/etc/bash_completion.d" directory
if [ "${computer_type}" == "Mac" ]; then
    if [ -f /usr/local/etc/bash_completion.d/sshfs_helpers ]; then
        msg_c -g "Removing sshfs_helpers from the /usr/local/etc/bash_completion.d directory"
        cd "${CWD}" && rm /usr/local/etc/bash_completion.d/sshfs_helpers
    fi
else
    if [ -f /etc/bash_completion.d/sshfs_helpers ]; then
        msg_c -g "Removing sshfs_helpers from the /etc/bash_completion.d directory"
        cd "${CWD}" && rm /etc/bash_completion.d/sshfs_helpers
    fi
fi

# Reload the Environment
msg_c -g "Reloading the Environment"
if [ "${computer_type}" == "Mac" ]; then
    cd "${HOME}" && source "${HOME}/.bash_profile"
else
    cd "${HOME}" && source "${HOME}/.bashrc"    
fi

# Testing! Check to make sure the symlinks are not there then run the script with -h
msg_c -g "ls'ing the ${ULBIN} directory"
if [ "${computer_type}" == "Mac" ]; then
    ls -hlapv "${ULBIN}"
else
    ls -hlapv --color "${ULBIN}"    
fi

## Finish Script (clean up & exit)

msg_c -g "Done uninstalling"
cd "${CWD}"
exit 0
