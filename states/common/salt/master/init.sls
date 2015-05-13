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
# No mananaging of Salt configuration.
        # Use `require` instead of `watch` to avoid restarting the service
#        - require:
#            - file: /etc/salt/master

#/etc/salt/master:
#    file.managed:
#        - source: salt://common/salt/master/master.conf
#        - user: root
#        - group: root
#        - mode: 644


# TODO: Add master config validation:
#       - sources link mapping
#       - custom config keys

{% endif %}
# >>>
###############################################################################

{% endif %}

