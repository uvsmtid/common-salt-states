
# Test existance of `vim` command.
which vim 1>/dev/null 2>/dev/null
RET_VAL="$?"
if [ "$RET_VAL" == "0" ]
then
    alias vi="vim"
fi

alias ll="ls -l"

# Function to show full path of specified sub-path (or current directory).
lll ()
{
    if [ "${1:0:1}" == '/' ]
    then
        ls --color=auto -ld "$1"
    else
        ls --color=auto -ld "$(pwd)/$1"
    fi
}

# Function to show full path as `lll` + ssh destination.
llll ()
{
    if [ "${1:0:1}" == '/' ]
    then
        echo "$(whoami)@$(hostname):$(ls --color=auto -d "$1")"
    else
        echo "$(whoami)@$(hostname):$(ls --color=auto -d "$(pwd)/$1")"
    fi
}

# This is more convenient for long running jobs.
alias saltin='salt --async'
alias saltout='salt-run jobs.lookup_jid'

