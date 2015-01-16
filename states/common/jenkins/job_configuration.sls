# Jenkins jobs configurations.

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
    - common.jenkins.download_jenkins_cli_tool

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

{% for job_name in pillar['system_features']['configure_jenkins']['job_configs'].keys() %}

{% set job_config = pillar['system_features']['configure_jenkins']['job_configs'][job_name] %}

{% if job_config['enabled'] %}

# NOTE: At the moment (and it is probably right) only single host is selected
#       from only first listed role.
#       Basically, it means that the job can only be assigned to single host.
{% set restricted_to_role = pillar['system_features']['configure_jenkins']['job_configs'][job_name]['restrict_to_system_role'][0] %}
{% if pillar['system_host_roles'][restricted_to_role]['assigned_hosts']|length != 0 %}
{% set assigned_slave_host = pillar['system_host_roles'][restricted_to_role]['assigned_hosts'][0] %}
{% set assigned_slave_host_config = pillar['system_hosts'][assigned_slave_host] %}

{% set URI_prefix = pillar['system_features']['deploy_central_control_directory']['URI_prefix'] %}

# Put job configuration:
'{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml':
    file.managed:
        - source: salt://common/jenkins/jenkins.job.config.template.xml
        - template: jinja
        - context:
            # The value of `job_config` is not a string, it is data.
            job_config: {{ job_config|json }}

            job_name: "{{ job_name }}"
            os_type: "{{ assigned_slave_host_config['os_type'] }}"
            job_description: ""
            job_assigned_host: "{{ assigned_slave_host }}"
            control_url: '{{ URI_prefix }}/{{ pillar['system_features']['deploy_central_control_directory']['control_dir_url_path'] }}'

# Make sure job configuration does not exist:
add_{{ job_name }}_job_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ create-job {{ job_name }}"
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ get-job {{ job_name }}"
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml'

# Update job configuration.
# The update won't happen (it will be the same) if job has just been created.
update_{{ job_name }}_job_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:8080/ update-job {{ job_name }}"
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml'
            - cmd: add_{{ job_name }}_job_configuration_to_jenkins

{% endif %} # length

{% endif %} # job_config['enabled']

{% endfor %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


