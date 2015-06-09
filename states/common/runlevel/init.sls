# Configure runlevel.

# Get required runlevel per minion.
# -
{% if 'default_runlevel_per_role' in pillar['system_features'] %}

{% for role_name in pillar['system_features']['default_runlevel_per_role']['system_host_roles'].keys() %}

{% if grains['id'] in pillar['system_host_roles'][role_name]['assigned_hosts'] %}
{% set runlevel_value = pillar['system_features']['default_runlevel_per_role']['system_host_roles'][role_name] %}
{% else %}
{% set runlevel_value = pillar['system_features']['default_runlevel_per_role']['default_value'] %}
{% endif %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

# RHEL5 systems use System V init.


# Get default runlevel number:
# -
{% if runlevel_value == 'text' %}
{% set defautl_runlevel_number = '3' %}
{% endif %}
# -
{% if runlevel_value == 'graphical' %}
{% set defautl_runlevel_number = '5' %}
{% endif %}


#------------------------------------------------------------------------------
# NOTE: If `runlevel_value` is any string, it is considered `True`.
# Update /etc/inittab:
{% if runlevel_value %}
inittab_set_default_runlevel_per_role_{{ role_name }}:
    file.replace:
        - name: /etc/inittab
        - pattern: '^(\s*id):[^:]*:(.*)$'
        - repl: '\1:{{ defautl_runlevel_number }}:\2'
{% endif %}
#------------------------------------------------------------------------------


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

# Modern Linux systems use systemd as init.


# Get default systemd target:
# -
{% if runlevel_value == 'text' %}
{% set defautl_systemd_target = 'multi-user.target' %}
{% endif %}
# -
{% if runlevel_value == 'graphical' %}
{% set defautl_systemd_target = 'graphical.target' %}
{% endif %}

#------------------------------------------------------------------------------
# NOTE: If `runlevel_value` is any string, it is considered `True`.
{% if runlevel_value %}
set_systemd_default_target_{{ role_name }}:
    cmd.run:
        - name: "systemctl set-default {{ defautl_systemd_target }}"
{% endif %}
#------------------------------------------------------------------------------


{% endif %}
# >>>
###############################################################################

{% endfor %} # role_name

{% endif %} # default_runlevel_per_role

