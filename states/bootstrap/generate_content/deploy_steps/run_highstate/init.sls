#

###############################################################################
#

{% macro configure_selected_host_step_function(
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
            }
        - show_changes: True
        - require:
            - file: req_file_{{ requisite_config_file_id }}

{% endmacro %}

###############################################################################
#

{% macro prepare_resources_step_function(
        source_env_pillar
        ,
        target_env_pillar
        ,
        deploy_step
        ,
        deploy_step_config
        ,
        project_name
        ,
        profile_name
        ,
        target_contents_dir
        ,
        bootstrap_dir
    )
%}

# There is no resource preparation for `run_highstate` step.

{% endmacro %}

###############################################################################
# EOF
###############################################################################

