# A file with macros to define states related to stage flag files.

###############################################################################
# This macro generates list of prerequisites for specific stage flag file
# suitable to add under `require` key in any Salt state.
# For example, if you want your state like `service.running` depend on stage
# flag file `some_flag_file`, add this to its `require` key:
#   dummy:
#       service.running:
#           # ...
#           - require:
#                stage_flag_file_prerequisites(`some_flag_file`)

{% macro stage_flag_file_prerequisites(stage_flag_id) %}

{% set config = pillar['system_orchestrate_stages']['stage_flag_files'][stage_flag_id] %}

{% if config['enable_prerequisite_enforcement'] %}
{% for prereq in config['prerequisites'] %}
            - file: 'stage_flag_{{ prereq }}'
{% endfor %}
{% endif %}
            # Use `dummy` to make YAML list even with no prerequisites.
            - sls: common.dummy

{% endmacro %}

###############################################################################
# The same as above for flag file itself:

{% macro stage_flag_file_prerequisites_self(stage_flag_id) %}
            - file: 'stage_flag_{{ stage_flag_id }}'
{% endmacro %}

###############################################################################
# The same as `stage_flag_file_prerequisites` but generates list of states
# suitable to add for `include` key.

{% macro stage_flag_file_prerequisites_include(project_name, stage_flag_id) %}

{% set config = pillar['system_orchestrate_stages']['stage_flag_files'][stage_flag_id] %}

{% if config['enable_prerequisite_enforcement'] %}
{% for prereq in config['prerequisites'] %}
    - {{ project_name }}.orchestrate.stage_flag_files.{{ prereq }}
{% endfor %}
{% endif %}
    # Use `dummy` to make YAML list even with no prerequisites.
    - common.dummy

{% endmacro %}

###############################################################################
# The same as above for flag file itself:

{% macro stage_flag_file_prerequisites_include_self(project_name, stage_flag_id) %}
    - {{ project_name }}.orchestrate.stage_flag_files.{{ stage_flag_id }}
{% endmacro %}

###############################################################################
# This macro generates content for SLS file of stage flag file.
# It is supposed to be used for state which manages stage flag file only
# (not the state which implements the stage itself).
# For example, if you want to have a new stage flag file
# called `orchestrate_stage_dummy`, you need to write
# a `orchestrate_stage_dummy.sls` SLS file which performs
# all the logic to check existance of this stage file and its dependencies.
# Place this macro inside the SLS instead.

{% macro stage_flag_file_sls(project_name, stage_flag_id) %}

{% set control_host = pillar['system_hosts'][pillar['system_host_roles']['salt_master_role']['assigned_hosts'][0]] %}
{% set account_conf = pillar['system_accounts'][ control_host['primary_user'] ] %}
{% set dir_name = account_conf['posix_user_home_dir'] + '/' + pillar['system_orchestrate_stages']['deployment_directory_path'] %}
{% set config = pillar['system_orchestrate_stages']['stage_flag_files'][stage_flag_id] %}

# Include prerequisites of stage flag file:
include:

    # NOTE: We do not include stage states into flag file state.
    #       If included, they will trigger stage states execution.
    #       Flag file is the indicator that state execution
    #       has already been completed in the state which actually
    #       implements steps for the stage.
    #       This indicator flag file is not created by the flag file state.
    #       Instead, it is created by the state which implements the state.
    {% if False %}
    # Include itself to trigger execution and meet stage flag requirements:
    - {{ project_name }}.orchestrate.stages.{{ stage_flag_id }}
    {% endif %}

    # Include all pre-requisites:
    {{ stage_flag_file_prerequisites_include(project_name, stage_flag_id) }}

# State name is a file name prefixed with `stage_flag_`:
'stage_flag_{{ stage_flag_id }}':
    # NOTE: This state only verifies the existence of file name.
    #       It does not create the file, if it does not exist.
    file.exists:
        - name: '{{ dir_name }}/{{ stage_flag_id }}'
        - require:

            # NOTE: We do not trigger state execution to for flag file.
            #       Flag file is the indicator that state execution
            #       has already been completed in the state which actually
            #       implements steps for the stage.
            {% if False %}
            # Trigger stage execution:
            - sls: {{ project_name }}.orchestrate.stages.{{ stage_flag_id }}
            {% endif %}

            # Depend on all pre-requisite stage flag files:
            {{ stage_flag_file_prerequisites(stage_flag_id) }}

{% endmacro %}

###############################################################################
# This macro is supposed to be used in the orchestration stage which actully
# implements what stage flag file indicates. The macro adds state to create
# stage flag file automatically or manually.
# For example, if `orchestrate_stage_dummy` state sets up something and
# you want to create stage flag file `orchestrate_stage_dummy` automatically,
# use this macro.

{% macro stage_flag_file_create(unique_prefix, stage_flag_id, orchestrate_dep_list) %}

{% set control_host = pillar['system_hosts'][pillar['system_host_roles']['salt_master_role']['assigned_hosts'][0]] %}
{% set account_conf = pillar['system_accounts'][ control_host['primary_user'] ] %}
{% set dir_name = account_conf['posix_user_home_dir'] + '/' + pillar['system_orchestrate_stages']['deployment_directory_path'] %}
{% set config = pillar['system_orchestrate_stages']['stage_flag_files'][stage_flag_id] %}

{% if config['enable_auto_creation'] %}

'{{ unique_prefix }}_stage_flag_file_create_{{ stage_flag_id }}':
    file.managed:
        - name: '{{ dir_name }}/{{ stage_flag_id }}'
        - user: {{ account_conf['username'] }}
        # `~` is null in YAML:
        - source: ~
        - require:
{% else %}
'{{ unique_prefix }}_stage_flag_file_exists_{{ stage_flag_id }}':
    # All we need is to successfuly complete the stage with some note
    # in the output which tells that manual user intervention is required.
    cmd.run:
        - name: "echo NOTE: auto-creation for this file is disabled and has to be done manually: {{ dir_name }}/{{ stage_flag_id }}"
        - require:
{% endif %}
            # The stage flag file should exists AFTER the last required
            # state for this particular stage.
            {% for dep_id in orchestrate_dep_list %}
            - salt: {{ dep_id }}
            {% endfor %}
            {{ stage_flag_file_prerequisites(stage_flag_id) }}

{% endmacro %}

###############################################################################
# EOF
###############################################################################

