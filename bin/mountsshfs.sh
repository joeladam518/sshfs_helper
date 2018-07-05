#!/usr/bin/env bash

echo "Success Joel!! You've called mountsshfs.sh :-)"
exit 0

valid_servers=($(grep -w -i "Host" ~/.ssh/config | sed 's/Host//' | tr '\n' ' ' | sed 's/\* //' ))

parentdirpath="$HOME"/mnt
remotedirpath=""
localdirpath=""
valid_server=""
server_uri=""
server_user=""
identityfilepath=""

for valid_server in "${valid_servers[@]}" 
do 
    if [[ "$valid_server" == "$1" ]]; then
        remotedirpath=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*#remotedirpath //p")
        server_user=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*User //p")
        serveruri=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*Hostname //p")
        identityfilepath=$(awk "/Host ${valid_server}/,/^$/" ~/.ssh/config | sed -n "s/.*IdentityFile //p")
        localdirpath="$parentdirpath"/"$1"
    fi
done

if [[ -z $localdirpath ]]; then
    echo ""
    echo "Valid sites include:"
    echo "${valid_servers[@]}" | tr ' ' '\n'
    echo ""
    return
fi

echo $remotedirpath; return

if [ ! -d $localdirpath ]; then 
    mkdir $localdirpath
fi

local sshfs_command="sudo sshfs $user@$serveruri"

if [ ! -z $remotedirpath ]; then
    sshfs_command="$sshfs_command:$remotedirpath $localdirpath"
else
    sshfs_command="$sshfs_command: $localdirpath"
fi

sshfs_command="$sshfs_command -p 22 -C -o allow_other,reconnect,ServerAliveInterval=15"

if [[ ! -z $identityfilepath ]]; then
    sshfs_command="$sshfs_command,IdentityFile=$identityfilepath"
fi

#echo $sshfs_command; return
eval $sshfs_command

#Done!
exit 0;
