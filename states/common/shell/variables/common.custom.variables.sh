# WARNING: This file is managed by Salt.
#          Modify sources to keep changes persistent.

###############################################################################

export EDITOR="vim"

###############################################################################

{% if grains['os_platform_type'].startswith('rhel5') %}
# Add `/sbin` and `/usr/sbin` to `PATH` for commands
# like `ip`, `service`, `tcpdump`, etc.
export PATH="${PATH}:/sbin:/usr/sbin"
{% endif %}

###############################################################################

# Set variable to indicate which pillar profile is used.
{% set profile_name = pillar['profile_name'] %}
export SALT_PROFILE_NAME="{{ profile_name }}"

###############################################################################

{% set proxy_config = pillar['system_features']['external_http_proxy'] %}
{% if proxy_config['feature_enabled'] %}

# Proxy settings:
# TODO: Use `secret_id` from `system_secrets` for `password_value`.
export http_proxy='{{ proxy_config['proxy_url_schema'] }}{{ proxy_config['proxy_username'] }}:{{ proxy_config['proxy_password'] }}@{{ proxy_config['proxy_url_hostname'] }}:{{ proxy_config['proxy_url_port'] }}/'
export https_proxy="${http_proxy}"

{% endif %}

###############################################################################

{% if pillar['system_features']['assign_DISPLAY_environment_variable'] %}

# Use role's host (which should be part of DNS or any host resolution method).
# If current minion is among assigned hosts for `primary_console_role`,
# use only `:0.0`.
{% if grains['id'] in pillar['system_host_roles']['primary_console_role']['assigned_hosts'] %}
{% set x_display_server = '' %}
{% else %}
{% set x_display_server = pillar['system_host_roles']['primary_console_role']['hostname'] %}
{% endif %}

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

        # Display hint only if `x_display_server` contains any hostname.
        if [ -n '{{ x_display_server }}' ]
        then
            echo "If \`{{ x_display_server }}\` is not resolvable, set IP address in \`/etc/hosts\`." 1>&2
        else
            echo "Using local graphical environment." 1>&2
        fi
    fi
fi

{% endif %}

###############################################################################
# Add timestamps to bash history.

export HISTTIMEFORMAT="%y-%m-%dT%T "

###############################################################################
# EOF
###############################################################################

