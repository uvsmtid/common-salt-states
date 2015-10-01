# Jenkins jobs configurations.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %} # os_platform_type

# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 1. Generate include list
include:

{% for job_name in pillar['system_features']['configure_jenkins']['job_configs'].keys() %}

{% set job_config = pillar['system_features']['configure_jenkins']['job_configs'][job_name] %}

{% if job_config['enabled'] %}

# NOTE: At the moment (and it is probably right) only single host is selected
#       from only first listed role.
#       Basically, it means that the job can only be assigned to single host.
{% set restricted_to_role = pillar['system_features']['configure_jenkins']['job_configs'][job_name]['restrict_to_system_role'][0] %}
{% if pillar['system_host_roles'][restricted_to_role]['assigned_hosts']|length != 0 %}

# Import function which is supposed to generate list of items to include:
{% set job_config_function_source = job_config['job_config_function_source'] %}
{% from job_config_function_source import job_config_include_item with context %}

# Note that it is OK to have duplicated items in the list.
# Call the function:
{{
    job_config_include_item(
        job_name,
        job_config,
    )
}}

{% endif %} # length

{% endif %} # job_config['enabled']

{% endfor %}

    # At least one single element should be in the include list.
    # And this single element is required one now:
    - common.jenkins.download_jenkins_cli_tool

# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 2. Generage job configuration.
{% for job_name in pillar['system_features']['configure_jenkins']['job_configs'].keys() %}

{% set job_config = pillar['system_features']['configure_jenkins']['job_configs'][job_name] %}

{% if job_config['enabled'] %}

# NOTE: At the moment (and it is probably right) only single host is selected
#       from only first listed role.
#       Basically, it means that the job can only be assigned to single host.
{% set restricted_to_role = pillar['system_features']['configure_jenkins']['job_configs'][job_name]['restrict_to_system_role'][0] %}
{% if pillar['system_host_roles'][restricted_to_role]['assigned_hosts']|length != 0 %}

# Just call configured state which is supposed to configure the job:
{% set job_config_function_source = job_config['job_config_function_source'] %}
{% from job_config_function_source import job_config_function with context %}

# Call the function to generate configuration state for the job:
{{
    job_config_function(
        job_name,
        job_config,
    )
}}

{% endif %} # length

{% endif %} # job_config['enabled']

{% endfor %}

# 3. Disable jobs which are not part of configuration.
{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}
{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

disable_jobs_missing_in_pillars:
    cmd.run:
        - name: 'for EXISTING_JOB_NAME in $( java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ list-jobs All ) ; do if ! ( echo "{{ pillar['system_features']['configure_jenkins']['job_configs'].keys()|join(' ') }}" | grep -F "${EXISTING_JOB_NAME}" ) ; then java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ disable-job "${EXISTING_JOB_NAME}" ; fi ; done'
        - require:
            - cmd: download_jenkins_cli_jar

{% endif %} # os_platform_type
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################

