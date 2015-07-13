# Jenkins cli tool.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

include:
    - common.wget

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

'{{ pillar['posix_config_temp_dir'] }}/jenkins':
    file.directory:
        - makedirs: True

# Download jenkins-cli.jar:
download_jenkins_cli_jar:
    cmd.run:
        # TODO: Port number may also need to be parameterized.
        - name: 'wget http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/jnlpJars/jenkins-cli.jar -O {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar'
        - env:
            # Disable proxy settings for `jenkins_master_hostname`.
            - http_proxy: ~
            - https_proxy: ~
        - require:
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins'
            - sls: common.wget

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


