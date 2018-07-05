#!/usr/bin/env bash

echo "Success Joel!! You've called unmountsshfs.sh :-)"
exit 0

local parentdirpath="$HOME"/mnt
local localdirpath=""
local valid_servers=($(grep -w -i "Host" ~/.ssh/config | sed 's/Host//'| tr '\n' ' ' | sed 's/\* //' ))
local a_valid_server

for a_valid_server in "${valid_servers[@]}" 
do 
    if [[ "$a_valid_server" == "$1" ]]; then 
        localdirpath="$parentdirpath"/"$1"
    fi
done

if [[ -z $localdirpath ]]; then
    echo ""
    echo "Not a valid site to unmount. Try of these: "
    mount | grep $parentdirpath
    echo ""
    return
fi

sudo fusermount -u $localdirpath

#Done!
exit 0;
