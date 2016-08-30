# Enable Gnome auto login after reboot.

################################################################################
#

{% if grains['os_platform_type'].startswith('fc') %}

deploy_gnome_config_file:
    file.managed:
        - source: 'salt://common/gnome/auto_login/custom.conf.sls'
        - name: '/etc/gdm/custom.conf'
        - makedirs: True
        - template: jinja
        - mode: 644
        - user: root
        - group: root

{% endif %}

################################################################################
# EOF
################################################################################

