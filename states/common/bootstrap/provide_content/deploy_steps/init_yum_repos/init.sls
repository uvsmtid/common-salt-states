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
        project_name
        ,
        profile_name
        ,
        requisite_config_file_id
        ,
        requisite_config_file_path
        ,
        bootstrap_dir
    )
%}

{{ requisite_config_file_id }}_{{ deploy_step }}:
    file.blockreplace:
        - name: '{{ requisite_config_file_path }}'
        - marker_start: '# Salt auto-config START: {{ requisite_config_file_id }}_{{ deploy_step }}'
        - marker_end:   '# Salt auto-config END:   {{ requisite_config_file_id }}_{{ deploy_step }}'
        - append_if_not_found: True
        - backup: False
        - content: |
            {{ deploy_step }} = {
                "yum_repo_configs": {
                    "base": {
                        "installation_type": "file",
                        # TODO
                    },
                    "epel": {
                        "installation_type": "rpm",
                        "rpm_key_file": "resources/examples/uvsmtid/centos-5.5-minimal/RPM-GPG-KEY-EPEL-5.217521F6.key.txt",
                        # TODO
                    },
                    "pgdg": {
                        "installation_type": "rpm",
                        # TODO
                    },
                },
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% endmacro %}

