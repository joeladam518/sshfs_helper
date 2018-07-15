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
computer_type=""
server_to_mount=""

parentdirpath="${HOME}/mnt"
remotedirpath=""
localdirpath=""

valid_server=""
server_uri=""
server_user=""
identityfilepath=""

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
your ssh config file to generate the valid servers to mount.

    -h      Display this help and exit.
    -t      Testing mode. Will not run the sshfs command. Just echo it   
    -v      Verbose mode. Can be used multiple times for increased verbosity.

EOF
}
show_valid_servers() {
    msg_c -d "The valid servers are:"
    echo "${valid_servers[@]}" | tr ' ' '\n'
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
server_to_mount=${1}

if [ $verbose -gt 0 ]; then
    msg_c -nb "server to mount: "
    msg_c -a  "${server_to_mount}"
fi

# Make sure we have a server to mount
if [ -z $server_to_mount ]; then
    echo ""
    msg_c -r "No server name provided." 1>&2
    show_valid_servers
    echo ""
    exit 1
fi

## Start Script

# Lets see if we can what computer this bash script is running on.
computer_type=$(determine_computer_type)

if [ $verbose -gt 1 ]; then
    msg_c -nb "You computer type is: " 
    msg_c -a  "${computer_type}"
fi

if [ "${computer_type}" == "UNKNOWN" ]; then
    msg_c -r "I couldn't figure out your computer type... Exiting... ☹️" 1>&2
    exit 1
fi 

for valid_server in "${valid_servers[@]}"; do 
    if [ "$valid_server" == "$1" ]; then
        remotedirpath=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*#remotedirpath //p")
        server_user=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*User //p")
        serveruri=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*Hostname //p")
        identityfilepath=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*IdentityFile //p")
        localdirpath="${parentdirpath}/${server_to_mount}"
    fi
done

if [ $verbose -gt 2 ]; then
    echo ""
    msg_c -nb "parent directory path: "; msg_c -a "${parentdirpath}";
    msg_c -nb "remote directory path: "; msg_c -a "${remotedirpath}";
    msg_c -nb " local directory path: "; msg_c -a "${localdirpath}";
    msg_c -nb "      server username: "; msg_c -a "${server_user}";
    msg_c -nb "           server uri: "; msg_c -a "${serveruri}";
    msg_c -nb "   identity file path: "; msg_c -a "${identityfilepath}";
    echo ""
fi

if [ -z $localdirpath ]; then
    echo ""
    msg_c -r "The server \"${server_to_mount}\" is not a server you can mount." 1>&2
    show_valid_servers
    echo ""
    exit 1
fi

if [ ! -d $localdirpath ]; then 
    mkdir $localdirpath
fi

## Make the sshfs command
sshfs_command="sshfs ${server_user}@${serveruri}:${remotedirpath} ${localdirpath}"

sshfs_command="${sshfs_command} -p 22 -C -o allow_other,auto_cache,reconnect"

if [ "${computer_type}" = "Mac" ]; then
    sshfs_command="${sshfs_command},noappledouble,defer_permissions,volname=${server_to_mount}"
else
    sshfs_command="${sshfs_command},ServerAliveInterval=15"
fi

# Do you have an identity file path?
if [ ! -z $identityfilepath ]; then
    sshfs_command="${sshfs_command},IdentityFile=${identityfilepath}"
fi

# Display the command to be used for debugging and exit
if [ $testing_mode == 1 ]; then
    echo ""
    msg_c -c "The sshfs mount command: "
    echo "${sshfs_command}"
    echo ""
    exit 0
fi

previous_num_of_mounted_dirs=$(mount | grep $parentdirpath | wc -l)

# Mount the sshfs file system
eval ${sshfs_command}

current_num_of_mounted_dirs=$(mount | grep $parentdirpath | wc -l)

## Finish Script (clean up & exit)

if [ $verbose -gt 2 ]; then
    msg_c -nb "previous_num_of_mounted_dirs = "; msg_c -a "${previous_num_of_mounted_dirs}";
    msg_c -nb "current_num_of_mounted_dirs  = "; msg_c -a "${current_num_of_mounted_dirs}";
fi

if [ $current_num_of_mounted_dirs -gt $previous_num_of_mounted_dirs ]; then
    msg_c -g "Successfully mounted server \"${server_to_mount}\""
else
    echo ""
    msg_c -r "Failed to mount server \"${server_to_mount}\""
    echo ""
fi

exit 0
