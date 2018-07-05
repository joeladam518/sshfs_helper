#!/usr/bin/env bash

## Colors

BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PINK=$(tput setaf 5)
CYAN=$(tput setaf 6)
GRAY=$(tput setaf 7)
RESET=$(tput sgr0)

## Functions

msg_bold() {
    if [ ! -z $1 ] && [ ! -z $2 ]; then
        if [ $2 == "-n" ]; then
            echo -ne "${BOLD}${1}${RESET}"
        elif [ $1 == "-n" ]; then
            echo -ne "${BOLD}${2}${RESET}"
        else
            echo -e "${BOLD}${1} ${2}${RESET}"
        fi
    elif [ ! -z $1 ] && [ -z $2 ]; then
        echo -e "${BOLD}${1}${RESET}"
    elif [ -z $1 ] && [ ! -z $2 ]; then
        echo -e "${BOLD}${2}${RESET}"
    fi

    return
}
msg_info() {
    if [[ ! -z $1 && ! -z $2 ]]; then
        if [ $2 == "-n" ]; then
            echo -ne "${GREEN}${1}${RESET}"
        elif [ $1 == "-n" ]; then
            echo -ne "${GREEN}${2}${RESET}"
        else
            echo -e "${GREEN}${1} ${2}${RESET}"
        fi
    elif [[ ! -z $1 &&-z $2 ]]; then
        echo -e "${GREEN}${1}${RESET}"
    elif [[ -z $1 && ! -z $2 ]]; then
        echo -e "${GREEN}${2}${RESET}"
    fi

    return
}
msg_warning() {
    if [ ! -z $1 ] && [ ! -z $2 ]; then
        if [ $2 == "-n" ]; then
            echo -ne "${YELLOW}${1}${RESET}"
        elif [ $1 == "-n" ]; then
            echo -ne "${YELLOW}${2}${RESET}"
        else
            echo -e "${YELLOW}${1} ${2}${RESET}"
        fi
    elif [ ! -z $1 ] && [ -z $2 ]; then
        echo -e "${YELLOW}${1}${RESET}"
    elif [ -z $1 ] && [ ! -z $2 ]; then
        echo -e "${YELLOW}${2}${RESET}"
    fi

    return
}
msg_error() {
    if [ ! -z $1 ] && [ ! -z $2 ]; then
        if [ $2 == "-n" ]; then
            echo -ne "${RED}${1}${RESET}"
        elif [ $1 == "-n" ]; then
            echo -ne "${RED}${2}${RESET}"
        else
            echo -e "${RED}${1} ${2}${RESET}"
        fi
    elif [ ! -z $1 ] && [ -z $2 ]; then
        echo -e "${RED}${1}${RESET}"
    elif [ -z $1 ] && [ ! -z $2 ]; then
        echo -e "${RED}${2}${RESET}"
    fi

    return
}

## Variables
CWD=$(pwd)
ULBIN="/usr/local/bin" # user's local bin
mmnt_script_name="mountsshfs.sh"
umnt_script_name="unmountsshfs.sh"

# ## Check if running as root?
# $EUID $UID == user id
# root user id == 0
# if [ "$EUID" -ne 0 ]
#   then echo "Please run as root"
#   exit
# fi

# link these scripts to the .local/bin directory 
msg_info "un symlinking the scripts."
cd "${ULBIN}" && rm "./${mmnt_script_name%.*}"
cd "${ULBIN}" && rm "./${umnt_script_name%.*}"
cd "${CWD}"

# Set the proper permissions
msg_info "Setting the proper permissions."
cd "${CWD}/bin" && chmod 0644 ${mmnt_script_name} ${umnt_script_name}
cd "${CWD}"

# Reload the Environment
msg_info "Reloading the Environment."
cd "${HOME}" && source "${HOME}/.bashrc"

# Run the scripts (testing)
# Please make sure the scripts don't do anything if your testing this install scripts
#mountsshfs
#unmountsshfs
msg_info "ls the ${ULBIN} directory."
ls -laph "${ULBIN}"

msg_info "Done installing."
cd "${CWD}"
exit 0