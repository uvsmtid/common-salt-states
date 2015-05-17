# Salt master configuration.

{% if grains['id'] in pillar['system_host_roles']['controller-role']['assigned_hosts'] %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}


salt_master:
    pkg.installed:
        - name: salt-master
        - aggregate: True
    service.running:
        - name: salt-master
        - enable: True
        - require:
            - pkg: salt_master
# No mananaging of Salt configuration (which may restart Salt serivce).
# See `common.salt.master.update_config` state to
# update config file without restart.

{% endif %}
# >>>
###############################################################################

{% endif %}

