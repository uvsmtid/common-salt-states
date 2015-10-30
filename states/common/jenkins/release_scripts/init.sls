# Instantiate release scripts.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% set host_config = pillar['system_hosts'][ grains['id'] ] %}
{% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}
{% set jenkins_dir_path = account_conf['posix_user_home_dir'] + '/jenkins' %}

{% for script_name in [
        'pre_merge_repoort.sh'
    ]
%}
jenkins_release_scripts-{{ script_name }}:
    file.managed:
        - source: 'salt://common/jenkins/release_scripts/{{ script_name }}.sls'
        - template: jinja
        - name: '{{ jenkins_dir_path }}/common/jenkins/release_scripts/{{ script_name }}'
        - makedirs: True
        - mode: 755
{% endfor %}

# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


