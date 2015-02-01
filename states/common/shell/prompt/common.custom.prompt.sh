
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

OLD_PS1="$PS1"

PS1=""

{% if 'bash_prompt_info_config' in pillar['system_features'] %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_ssh_style_paths'] %}

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

PS1="$USER_COLOR@$HOST_COLOR:$PATH_COLOR"

{% endif %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_git_aware_bash_prompt'] %}

source '/lib/git_aware_prompt/git_aware_prompt_func.sh'

GIT_BRANCH_COLOR="\[\e[32m\]\$(if [ -n \"\$git_branch\" ] ; then echo ' '\$git_branch ; fi)\[\e[0m\]"
GIT_DIRTY_COLOR="\[\e[31m\]\$(if [ -n \"\$git_dirty\" ] ; then echo \"\$git_dirty\" ; fi)\[\e[0m\]"

PS1="$PS1$GIT_BRANCH_COLOR"
PS1="$PS1$GIT_DIRTY_COLOR"

{% endif %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_background_jobs_count'] %}

# Show running jobs to be aware of background activity before loging out:
JOBS_COLOR="\[\e[35m\]\$(if [ \$(jobs -r | wc -l) != 0 ] ; then echo ' jobs:'\$(jobs -r | wc -l) ; fi)\[\e[0m\]"

PS1="$PS1$JOBS_COLOR"

{% endif %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_prompt_creation_timestamp'] %}

PS1="$PS1 \[\e[34m\]\$(date '+%Y-%m-%d')\[\e[0m\] \[\e[94m\]\$(date '+%H:%M:%S')\[\e[0m\]"

{% endif %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_last_command_execution_time'] %}

# Functions to track execution time of commands.
# See origin: http://stackoverflow.com/a/1862762/441652
function timer_start {
    execution_start_time=${execution_start_time:-$SECONDS}
}

function timer_stop {
    execution_duration_time=$(($SECONDS - $execution_start_time))
    unset execution_start_time
}

# Start timer for each command.
trap 'timer_start' DEBUG

# Stop timer for each prompt evaluation.
# NOTE: Command `timer_stop` must be the last. If not, othere commands
#       used for the command prompt will leave timer on.
PROMPT_COMMAND="$PROMPT_COMMAND timer_stop"

EXECUTION_TIME_COLOR="\[\e[96m\]\$(if [ \${execution_duration_time:-0} -gt 2 ] ; then echo ' last:'\${execution_duration_time}s ; fi)\[\e[0m\]"

# NOTE: Some scripts in `/etc/profile.d` directory may overwrite value of
#       `PROMPT_COMMAND` after it was already set.
#       The following variable will show a colorful `E` if `timer_stop`
#       is not present in the variable's value.
MISSING_COMMAND_IN_PROMPT_COLOR="\[\e[41m\]\$(if [[ \"\${PROMPT_COMMAND}\" =~ \"timer_stop\" ]] ; then echo ; else echo E ; fi)\[\e[0m\]"

PS1="${PS1}${EXECUTION_TIME_COLOR}${MISSING_COMMAND_IN_PROMPT_COLOR}"

{% endif %}

if [ -z "$PS1" ]
then
    PS1="$OLD_PS1"
else
    PS1="$PS1\n "
fi

{% endif %}

