
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

