# WARNING: This file is managed by Salt.
#          Modify sources to keep changes persistent.

export EDITOR="vim"

{% if pillar['system_features']['assign_DISPLAY_environment_variable'] %}

# Use dereferenced host:
{% set x_display_server = pillar['system_host_roles']['primary_console_role']['assigned_hosts'][0] %}
# Use role name (which should be part of DNS):
{% set x_display_server = 'primary_console_role' %}

if [ -n "$DISPLAY" ]
then

    # If stdin is not tty, do not print anything.
    if [ -t 1 ]
    then
        # Avoid setting DISPLAY if you use SSH.
        # Use automatic X forwarding for SSH instead.
        echo -n "Reusing: DISPLAY=$DISPLAY " 1>&2
        echo "SSH X port forwarding." 1>&2
    fi
else
    export DISPLAY="{{ x_display_server }}:0.0"
    # If stdin is not tty, do not print anything.
    if [ -t 1 ]
    then
        echo -n "Setting: DISPLAY=$DISPLAY " 1>&2
        echo "If \`{{ x_display_server }}\` is not resolvable, set IP address in \`/etc/hosts\`." 1>&2
    fi
fi

{% endif %}


{% if 'enable_NELWATCHDOGMODE_environment_variable' in pillar['system_features'] %}
{% if pillar['system_features']['enable_NELWATCHDOGMODE_environment_variable'] %}
export NELWATCHDOGMODE=1
{% endif %}
{% endif %}


