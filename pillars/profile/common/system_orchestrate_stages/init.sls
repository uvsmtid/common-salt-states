
###############################################################################
#

include:

# TODO: This list is used in many places and can be externalized
#       and loaded from a a JSON file.
{% for sub_item in [
        'stage_flag_files'
    ]
%}
    - {{ this_pillar }}.{{ sub_item }}:
        defaults:
            this_pillar: {{ this_pillar }}.{{ sub_item }}
            profile_root: {{ profile_root }}

{% endfor %}

###############################################################################
#

system_orchestrate_stages:

    # This path is relative to primary user's home:
    deployment_directory_path: 'salt_orchestration_stage_flag_files'

    # NOTE: Unfortunately, there is no way to enforce listing of
    #       dict keys in the order they are defined.
    #       So, this list is in addition to the keys of
    #       `stage_flag_files` dict defined below just to know the order
    #       in which they have to be executed.
    #
    # TODO: This list is used in many places and can be externalized
    #       and loaded from a a JSON file.
    state_flag_files_order:
        # 01
        - orchestrate_stage_start
        # 02
        - salt_minions_ready
        # 03
        - hosts_files_updated
        # 04
        - required_system_hosts_online
        # 05
        - yum_repositories_configured
        # 06
        - sudo_configured
        # 07
        - ssh_service_ready
        # 08
        - ssh_keys_distributed
        # 09
        - jenkins_master_installed
        # 10
        - jenkins_slaves_connected
        # 11
        - jenkins_jobs_configured
        # 12
        - orchestrate_stage_stop

    #--------------------------------------------------------------------------
    # Stage Flag Files
    #
    # Each key in the following dict represends name of the flag file.
    #
    # - Option `enable_auto_creation` allows creating corresponding file
    #   automatically after successfully executing all orchestration states
    #   required by this stage flag file.
    #
    # - Option `enable_prerequisite_enforcement` makes this stage flag file
    #   actually depend on list of other files specified in `prerequisites`
    #   list. In other word, it enforces `prerequisites`.
    #
    # NOTE: The definition of each flag file is split into
    #       separate pillar files.
    stage_flag_files: {}

###############################################################################
# EOF
###############################################################################

