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



{% if pillar['system_features']['yum_repos_configuration']['feature_enabled'] %} # feature_enabled

{% for yum_repo_name in pillar['system_features']['yum_repos_configuration']['yum_repositories'].keys() %} # yum_repo_name

{% set yum_repo_conf = pillar['system_features']['yum_repos_configuration']['yum_repositories'][yum_repo_name] %}

{% if yum_repo_conf['installation_type'] == 'conf_template' %} # installation_type

{% set host_config = pillar['system_hosts'][grains['id']] %}

{% if host_config['os_platform'] in yum_repo_conf['os_platform_configs'] %} # os_platform

{% set yum_repo_os_platform_config = yum_repo_conf['os_platform_configs'][host_config['os_platform']] %}

# TODO: Use template file with `file.managed` to configure YUM.
#       The same configuration is supposed to be done for bootstrap
#       and it's better to reuse the same templates.
'{{ yum_repo_name }}_{{ host_config['os_platform'] }}':
    pkgrepo.managed:
        - name: '{{ yum_repo_name }}'
        - baseurl: '{{ yum_repo_os_platform_config['yum_repo_baseurl'] }}'
        - key_url: '{{ yum_repo_os_platform_config['yum_repo_key_url'] }}'
        - enabled: 1

{% endif %} # os_platform

{% endif %} # installation_type

{% endfor %} # yum_repo_name

{% endif %} # feature_enabled

{% endif %} # os_platform_type
# >>>
###############################################################################

