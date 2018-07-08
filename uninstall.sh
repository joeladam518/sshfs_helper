#!/usr/bin/env bash

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

# Check if running as root?
# $EUID & $UID == user_id
# root user_id == 0
if [ "$EUID" -ne 0 ]; then 
    msg_c -r "Please run ${0} as root."
    exit
fi

# unlink these scripts 
msg_info "un symlinking the scripts."
cd "${ULBIN}" && rm "./${mmnt_script_name%.*}"
cd "${ULBIN}" && rm "./${umnt_script_name%.*}"
cd "${CWD}"

# Reset the proper permissions
msg_info "Setting the proper permissions."
cd "${CWD}/bin" && chmod 0644 ${mmnt_script_name} ${umnt_script_name}
cd "${CWD}"

# Reload the Environment
msg_info "Reloading the Environment."
cd "${HOME}" && source "${HOME}/.bashrc"

# Testing! Check to make sure the symlinks are not there then run the script with -h
msg_c -g "ls'ing the ${ULBIN} directory."
ls -hlapv --color "${ULBIN}"
# mountsshfs -h
# unmountsshfs -h


msg_info "Done installing."
cd "${CWD}"
exit 0