# Macro to wait for online Jenkins master (and downlod CLI tool as a bonus).

{% macro wait_for_online_jenkins_master_macro(unique_suffix) %}

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

wait_for_online_jenkins_master_{{ unique_suffix }}:
    cmd.run:
        # Retry download as Jenkins may be restarting which may take some time.
        - name: 'COUNT_LIMIT=100; for ITER in $(seq "${COUNT_LIMIT}") ; do wget http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/jnlpJars/jenkins-cli.jar -O {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar && break ; echo retrying... ; sleep 1; done ; test "${ITER}" != "${COUNT_LIMIT}"'
        - env:
            # Disable proxy settings for `jenkins_master_hostname`.
            - http_proxy: ~
            - https_proxy: ~

{% endmacro %}


