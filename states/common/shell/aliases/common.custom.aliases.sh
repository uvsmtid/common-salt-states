
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
    ls --color=auto -ld "$(pwd)/$1"
}

# Function to show full path as `lll` + ssh destination.
llll ()
{
    echo "$(whoami)@$(hostname):$(ls -d "$(pwd)/$1")"
}

# This is more convenient for long running jobs.
alias saltin='salt --async'
alias saltout='salt-run jobs.lookup_jid'

