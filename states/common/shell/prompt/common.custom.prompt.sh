
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

if [ -z "$PS1" ]
then
    PS1="$OLD_PS1"
else
    PS1="$PS1\n "
fi

{% endif %}

