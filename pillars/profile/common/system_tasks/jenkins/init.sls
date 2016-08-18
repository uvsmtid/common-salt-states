
###############################################################################
#

# This is relative include mechanics as a workaround to inability to
# include pillar relative to current directory:
#    https://github.com/saltstack/salt/issues/8875#issuecomment-89441029

include:

{% for sub_item in [
        '__-__-init_pipeline-clean_old_build'
        ,
        '__-__-poll_pipeline-propose_build'
        ,
        'P-01-promotion-init_pipeline_passed'
        ,
        'P-02-promotion-update_pipeline_passed'
        ,
        'P-03-promotion-maven_pipeline_passed'
        ,
        'P-04-promotion-deploy_pipeline_passed'
        ,
        'P-05-promotion-package_pipeline_passed'
        ,
        'P-06-promotion-release_pipeline_passed'
        ,
        'P-07-promotion-checkout_pipeline_passed'
        ,
        'P-__-promotion-bootstrap_package_approved'
        ,
        '00-01-poll_pipeline-verify_approval'
        ,
        '00-02-poll_pipeline-reset_previous_build'
        ,
        '00-03-poll_pipeline-update_sources'
        ,
        '00-04-poll_pipeline-propose_build'
        ,
        '01-01-init_pipeline-start_new_build'
        ,
        '01-02-init_pipeline-reset_previous_build'
        ,
        '01-03-init_pipeline-describe_repositories_state'
        ,
        '01-04-init_pipeline-create_build_branches'
        ,
        '02-01-update_pipeline-restart_master_salt_services'
        ,
        '02-02-update_pipeline-configure_jenkins_jobs'
        ,
        '02-03-update_pipeline-run_salt_highstate'
        ,
        '02-04-update_pipeline-reconnect_jenkins_slaves'
        ,
        '__-__-update_pipeline-configure_jenkins_jobs'
        ,
        '__-__-update_pipeline-restart_master_salt_services'
        ,
        '03-01-maven_pipeline-maven_build_all'
        ,
        '03-02-maven_pipeline-verify_maven_data'
        ,
        '03-03-maven_pipeline-maven_job_name_prefix-maven_repo_name'
        ,
        '__-__-maven_pipeline-full_test_report'
        ,
        '04-01-deploy_pipeline-register_generated_resources'
        ,
        '04-02-deploy_pipeline-transfer_dynamic_build_descriptor'
        ,
        '04-03-deploy_pipeline-build_bootstrap_package'
        ,
        '04-04-deploy_pipeline-configure_vagrant'
        ,
        '04-05-deploy_pipeline-destroy_vagrant_hosts'
        ,
        '04-06-deploy_pipeline-remove_salt_minion_keys'
        ,
        '04-07-deploy_pipeline-instantiate_vagrant_hosts'
        ,
        '04-08-deploy_pipeline-run_salt_orchestrate'
        ,
        '04-09-deploy_pipeline-run_salt_highstate'
        ,
        '04-10-deploy_pipeline-reconnect_jenkins_slaves'
        ,
        '__-__-deploy_pipeline-build_bootstrap_package'
        ,
        '__-__-deploy_pipeline-configure_vagrant'
        ,
        '__-__-deploy_pipeline-destroy_vagrant_hosts'
        ,
        '__-__-deploy_pipeline-instantiate_vagrant_hosts'
        ,
        '__-__-deploy_pipeline-reconnect_jenkins_slaves'
        ,
        '__-__-deploy_pipeline-remove_salt_minion_keys'
        ,
        '__-__-deploy_pipeline-run_salt_highstate'
        ,
        '__-__-deploy_pipeline-run_salt_orchestrate'
        ,
        '05-01-package_pipeline-create_new_package'
        ,
        '05-02-package_pipeline-reset_previous_build'
        ,
        '05-03-package_pipeline-describe_repositories_state'
        ,
        '05-04-package_pipeline-create_build_branches'
        ,
        '05-05-package_pipeline-transfer_dynamic_build_descriptor'
        ,
        '05-06-package_pipeline-build_bootstrap_package'
        ,
        '05-07-package_pipeline-store_bootstrap_package'
    ]
%}
    - {{ this_pillar }}.{{ sub_item }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ sub_item }}
            profile_root: {{ profile_root }}

{% endfor %}

###############################################################################
# EOF
###############################################################################

