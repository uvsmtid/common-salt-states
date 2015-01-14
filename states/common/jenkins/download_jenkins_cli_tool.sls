# Jenkins cli tool.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

include:
    - common.wget

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

'{{ pillar['posix_config_temp_dir'] }}/jenkins':
    file.directory:
        - makedirs: True

# Download jenkins-cli.jar:
download_jenkins_cli_jar:
    cmd.run:
        # TODO: Port number may also need to be parameterized.
        - name: 'wget http://{{ jenkins_master_hostname }}:8080/jnlpJars/jenkins-cli.jar -O {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar'
        - require:
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins'
            - sls: common.wget

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


