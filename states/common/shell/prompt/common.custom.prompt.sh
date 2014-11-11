
# If stdin is not tty, do not do anything
if [ ! -t 1 ]
then
    # Use `return` instead of `exit` because this script is `source`-ed
    return 0
fi

# Just print user type.
if [ $UID == "0" ]
then
    echo "SUPER USER: $USER" >&2
    USER_COLOR="\[\e[31m\]\u\[\e[0m\]"
else
    echo "REGULAR USER: $USER" >&2
fi

{% if 'ssh_style_paths_in_shell_command_prompt' in pillar['system_features'] %}
{% if pillar['system_features']['ssh_style_paths_in_shell_command_prompt'] %}

# User color:
USER_COLOR="\[\e[36m\]\u\[\e[0m\]"
if [ $UID == "0" ]
then
    USER_COLOR="\[\e[31m\]\u\[\e[0m\]"
fi

# Use FQDN to be able to copy&paste for ssh connection from anywhere:
HOST_COLOR="\[\e[32m\]\H\[\e[0m\]"

# Use full path to be able to copy&paste it regardless of the user:
PATH_COLOR="\[\e[33m\]\$(pwd)\[\e[0m\]"

# Show running jobs to be aware of background activity before loging out:
JOBS_COLOR="\[\e[35m\]\$(if [ \$(jobs -r | wc -l) != 0 ] ; then echo 'jobs:'\$(jobs -r | wc -l) ; fi)\[\e[0m\]"

PS1="$USER_COLOR@$HOST_COLOR:$PATH_COLOR $JOBS_COLOR\n "

{% endif %}
{% endif %}

