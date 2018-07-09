#!/usr/bin/env bash

_ssh_helpers_completions()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local valid_servers=$(grep -w -i "Host" ~/.ssh/config | sed 's/Host//' | tr '\n' ' ' | sed 's/\* //' )
    
    COMPREPLY=($(compgen -W "$valid_servers" -- $cur))

    return 0
}

complete -F _ssh_helpers_completions mountsshfs
complete -F _ssh_helpers_completions unmountsshfs
