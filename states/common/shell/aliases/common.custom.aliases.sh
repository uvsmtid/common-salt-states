
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

    for ITEM in "$@"
    do
        if [ "${ITEM:0:1}" == '/' ]
        then
            ls --color=auto -ld "$ITEM"
        else
            ls --color=auto -ld "$(pwd)/$ITEM"
        fi
    done
}

# Function to show full path as `lll` + ssh destination.
llll ()
{
    for ITEM in "$@"
    do
        if [ "${ITEM:0:1}" == '/' ]
        then
            echo "$(whoami)@$(hostname):$(ls --color=auto -d "$ITEM")"
        else
            echo "$(whoami)@$(hostname):$(ls --color=auto -d "$(pwd)/$ITEM")"
        fi
    done
}

# This is more convenient for long running jobs.
alias saltin='salt --async'
alias saltout='salt-run jobs.lookup_jid'

