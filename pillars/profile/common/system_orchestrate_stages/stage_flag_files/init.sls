
###############################################################################
#

include:

# TODO: This list is used in many places and can be externalized
#       and loaded from a a JSON file.
{% for sub_item in [
        'orchestrate_stage_start'
        ,
        'salt_minions_ready'
        ,
        'hosts_files_updated'
        ,
        'required_system_hosts_online'
        ,
        'yum_repositories_configured'
        ,
        'sudo_configured'
        ,
        'ssh_service_ready'
        ,
        'ssh_keys_distributed'
        ,
        'jenkins_master_installed'
        ,
        'jenkins_slaves_connected'
        ,
        'jenkins_jobs_configured'
        ,
        'orchestrate_stage_stop'
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

