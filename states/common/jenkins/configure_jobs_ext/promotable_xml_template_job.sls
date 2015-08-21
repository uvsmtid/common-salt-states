# Configure Jenkins job based on XML configuration template.

# See also:
#  states/common/jenkins/configure_jobs_ext/simple_xml_template_job.sls

{% macro job_config_include_item(job_name, job_config) %}

{% if job_config['enabled'] %}

# Keyword `include` should be provided in the calling Salt template.
#include:
    - common.jenkins.download_jenkins_cli_tool

{% endif %}

{% endmacro %}

{% set jenkins_http_port = pillar['system_features']['configure_jenkins']['jenkins_http_port'] %}

{% macro job_config_function(job_name, job_config) %}

{% if job_config['enabled'] %}

{% set jenkins_master_hostname = pillar['system_hosts'][pillar['system_host_roles']['jenkins_master_role']['assigned_hosts'][0]]['hostname'] %}

# NOTE: At the moment (and it is probably right) only single host is selected
#       from only first listed role.
#       Basically, it means that the job can only be assigned to single host.
{% set restricted_to_role = pillar['system_features']['configure_jenkins']['job_configs'][job_name]['restrict_to_system_role'][0] %}
{% if pillar['system_host_roles'][restricted_to_role]['assigned_hosts']|length != 0 %}
{% set assigned_slave_host = pillar['system_host_roles'][restricted_to_role]['assigned_hosts'][0] %}
{% set assigned_slave_host_config = pillar['system_hosts'][assigned_slave_host] %}
{% set os_type = pillar['system_platforms'][assigned_slave_host_config['os_platform']]['os_type'] %}
{% set host_config = pillar['system_hosts'][ grains['id'] ] %}
{% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}

{% set URI_prefix = pillar['system_features']['deploy_central_control_directory']['URI_prefix'] %}

# Put job configuration:
'{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml':
    file.managed:
        - source: 'salt://{{ job_config['job_config_data']['xml_config_template'] }}'
        - template: jinja
        - context:
            # The value of `job_config` is not a string, it is data.
            job_config: {{ job_config|json }}

            job_name: "{{ job_name }}"
            os_type: "{{ os_type }}"
            jenkins_dir_path: '{{ account_conf['posix_user_home_dir'] }}/jenkins'
            job_description: ""
            job_assigned_host: "{{ assigned_slave_host }}"
            control_url: '{{ URI_prefix }}/{{ pillar['system_features']['deploy_central_control_directory']['control_dir_url_path'] }}'

        {% if 'use_promotions' in job_config %} # use_promotions
        - require:
            # Because promotions are simply Jenkins jobs,
            # before configuring parent job, we need to prepare
            # configuration files for each promotion job first.
            {% for promotion_id in job_config['use_promotions'] %}
                - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ promotion_id }}.xml'
            {% endfor %}
        {% endif %} # use_promotions

{% if 'is_promotion' not in job_config or not job_config['is_promotion'] %} # is_promotion

# Make sure job configuration does not exist:
add_{{ job_name }}_job_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ create-job {{ job_name }}"
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ get-job {{ job_name }}"
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml'

# Update job configuration.
# The update won't happen (it will be the same) if job has just been created.
update_{{ job_name }}_job_configuration_to_jenkins:
    cmd.run:
        - name: "cat {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml | java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ update-job {{ job_name }}"
{% if not pillar['system_features']['configure_jenkins']['rewrite_jenkins_configuration_for_jobs'] %}
        - unless: "java -jar {{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins-cli.jar -s http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/ get-job {{ job_name }}"
{% endif %}
        - require:
            - cmd: download_jenkins_cli_jar
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ job_name }}.xml'
            - cmd: add_{{ job_name }}_job_configuration_to_jenkins

{% endif %} # is_promotion

{% if 'use_promotions' in job_config %} # use_promotions
{% for promotion_id in job_config['use_promotions'] %} # use_promotions

# Detach parent job from promotion.
# Example:
#   curl -v -X POST 'http://localhost:8088/job/build_pipeline.init_dynamic_build_descriptor/promotion/process/manual-promotion/doDelete'
detach_{{ promotion_id }}_on_{{ job_name }}:
    cmd.run:
        - name: "curl -v -X POST http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/job/{{ job_name }}/promotion/process/{{ promotion_id }}/doDelete"
        - env:
            # Disable proxy settings for `jenkins_master_hostname`.
            - http_proxy: ~
            - https_proxy: ~
        - require:
            - file: '{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ promotion_id }}.xml'
            - cmd: update_{{ job_name }}_job_configuration_to_jenkins

# Attach promotion to parent job using updated configuration.
# Example:
#   curl -v -X POST --data-binary '@/observer.config_temp_dir/jenkins/jenkins.job.config.build_pipeline.promotion.manual-promotion.xml' -H 'Content-Type: application/xml' 'http://localhost:8088/job/build_pipeline.init_dynamic_build_descriptor/promotion/createProcess?name=manual-promotion'
attach_{{ promotion_id }}_on_{{ job_name }}:
    cmd.run:
        - name: "curl -v -X POST --data-binary '@{{ pillar['posix_config_temp_dir'] }}/jenkins/jenkins.job.config.{{ promotion_id }}.xml' -H 'Content-Type: application/xml' 'http://{{ jenkins_master_hostname }}:{{ jenkins_http_port }}/job/{{ job_name }}/promotion/createProcess?name={{ promotion_id }}'"
        - env:
            # Disable proxy settings for `jenkins_master_hostname`.
            - http_proxy: ~
            - https_proxy: ~
        - require:
            - cmd: detach_{{ promotion_id }}_on_{{ job_name }}

{% endfor %} # use_promotions
{% endif %} # use_promotions

{% endif %} # length

{% endif %} # job_config['enabled']

{% endmacro %}


