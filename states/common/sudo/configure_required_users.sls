# Configure sudo for specific users.

include:
    - common.sudo

{% if pillar['system_features']['configure_sudo_for_specified_users']['feature_enabled'] %}


# 1. Primary user for this minion.
#
# TODO: This is prone to code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U

{% if pillar['system_features']['configure_sudo_for_specified_users']['include_primary_users']['enabled'] %}

{% set case_name = 'primary_user' %}

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
{% set sudo_username = account_conf['username'] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

/etc/sudoers_{{ case_name }}_{{ sudo_username }}:
    file.blockreplace:
        - name: /etc/sudoers
        #{# DISABLED: `file.exists` does not support this (yet)
        - user: root
        - group: root
        - mode: 400
        #}#
        - marker_start: "# <<< AUTOMATICALLY MANAGED by Salt for {{ sudo_username }} "
        - content: |
            {% if pillar['system_features']['configure_sudo_for_specified_users']['include_primary_users']['disable_password'] %}
            {{ sudo_username }} ALL=(ALL) NOPASSWD:ALL
            {% else %}
            {{ sudo_username }} ALL=(ALL) ALL
            {% endif %}

            {% if pillar['system_features']['configure_sudo_for_specified_users']['include_primary_users']['disable_tty_requirement'] %}
            Defaults:{{ sudo_username }} !requiretty
            {% endif %}
        - marker_end: "# >>> AUTOMATICALLY MANAGED by Salt for {{ sudo_username }}"
        - append_if_not_found: True
        - require:
            - sls: common.sudo

{% endif %}
# >>>
###############################################################################

{% endif %} # `include_primary_users`
# End of 1.


{% endif %}

