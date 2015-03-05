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
                "salt_minion_config_file": "resources/examples/uvsmtid/centos-5.5-minimal/minion.conf",
                "rpm_sources": {
                    "salt-master": {
                        "source_type": "zip",
                        "file_path": "resources/examples/uvsmtid/centos-5.5-minimal/salt-minion-2014.7.1-1.el5.x86_64.rpms.zip",
                    },
                    "python26-distribute": {
                        "source_type": "zip",
                        "file_path": "resources/examples/uvsmtid/centos-5.5-minimal/python26-distribute-0.6.10-4.el5.x86_64.rpms.zip",
                    },
                },
            }
        - show_changes: True
        - require:
            - file: {{ requisite_config_file_id }}

{% endmacro %}

