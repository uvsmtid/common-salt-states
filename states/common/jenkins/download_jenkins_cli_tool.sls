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

{% from 'common/jenkins/wait_for_online_master.sls' import wait_for_online_jenkins_master_macro with context %}

{% from 'common/libs/utils.lib.sls' import get_posix_salt_content_temp_dir with context %}

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

'{{ get_posix_salt_content_temp_dir() }}/jenkins':
    file.directory:
        - makedirs: True
        - sls: common.wget

# Download jenkins-cli.jar.
{{ wait_for_online_jenkins_master_macro('download_jenkins_cli_jar') }}

download_jenkins_cli_jar:
    cmd.run:
        - name: 'echo dummy successfully downloaded jenkins CLI utility'
        - require:
            # State id "exported" by `wait_for_online_jenkins_master_macro`:
            - cmd: wait_for_online_jenkins_master_download_jenkins_cli_jar

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


