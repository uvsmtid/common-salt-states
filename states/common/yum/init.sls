# Global yum configuration for the node.

###############################################################################
# <<<
{% if not grains['os_platform_type'].startswith('win') %}

yum_conf:
    file.managed:
        - name: /etc/yum.conf
        - source: salt://common/yum/yum.conf
        - context:
            selected_pillar: {{ pillar }}
        - user: root
        - group: root
        - mode: 644
        - template: jinja

# Backup (move) directory with previously configured repos.
backup_yum_repos_dir:
    cmd.run:
        - name: 'rm -rf /etc/yum.repos.d.salt_backup && mv /etc/yum.repos.d /etc/yum.repos.d.salt_backup'
        - onlyif: 'ls /etc/yum.repos.d'

platform_yum_repos_list:
    file.managed:
        - name: /etc/yum.repos.d/platform_repos_list.repo
        - source: salt://common/yum/platform_repos_list.repo
        - makedirs: True
        - context:
            selected_pillar: {{ pillar }}
            host_config: {{ selected_pillar['system_hosts'][grains['id']] }}
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - cmd: backup_yum_repos_dir

{% endif %} # os_platform_type
# >>>
###############################################################################

