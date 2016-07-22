#

{% macro configure_deploy_step_function(
        source_env_pillar
        ,
        target_env_pillar
        ,
        selected_host_name
        ,
        deploy_step
        ,
        deploy_step_config
        ,
        project_name
        ,
        profile_name
        ,
        requisite_config_file_id
        ,
        requisite_config_file_path
        ,
        target_contents_dir
        ,
        bootstrap_dir
    )
%}

# Configuration which provides location of generated hosts file.
set_config_{{ requisite_config_file_id }}_{{ deploy_step }}:
    file.blockreplace:
        - name: '{{ requisite_config_file_path }}'
        - marker_start: '# Salt auto-config START: {{ requisite_config_file_id }}_{{ deploy_step }}'
        - marker_end:   '# Salt auto-config END:   {{ requisite_config_file_id }}_{{ deploy_step }}'
        - append_if_not_found: True
        - backup: False
        - content: |
            {{ deploy_step }} = {
                'step_enabled': {{ deploy_step_config['step_enabled'] }},
                'required_entries_hosts_file': 'resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/hosts_file',
            }
        - show_changes: True
        - require:
            - file: req_file_{{ requisite_config_file_id }}

{% from 'common/libs/host_config_queries.sls' import get_role_ip_address_from_pillar with context %}

# Generated hosts file.
# NOTE: The host file contains only `salt` hostname.
#       If required, all other hostname are supposed to be configured after
#       boostrap process by proper Salt state.
config_file_{{ requisite_config_file_id }}_{{ deploy_step }}_hosts_file:
    file.managed:
        - name: '{{ target_contents_dir }}/resources/conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}/hosts_file'
        - makedirs: True
        - contents: |
            {{ get_role_ip_address_from_pillar('salt_master_role', target_env_pillar) }} salt
        {% set account_conf = source_env_pillar['system_accounts'][ source_env_pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - group: '{{ account_conf['username'] }}'
        - user: '{{ account_conf['username'] }}'

{% endmacro %}

