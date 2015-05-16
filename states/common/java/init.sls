#

{% set project_name = salt['config.get']('this_system_keys:project_name') %}

include:
    - {{ project_name }}.java

# This state is required for this SLS file to be considered as having any state.
dummy_common_java_state:
    cmd.run:
        - name: "echo dummy"
        - require:
            - sls: {{ project_name }}.java

