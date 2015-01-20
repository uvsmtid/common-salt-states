#

{% set project     = salt['config.get']('this_system_keys:project') %}

include:
    - {{ project }}.java

# This state is required for this SLS file to be considered as having any state.
dummy_common_java_state:
    cmd.run:
        - name: "echo dummy"
        - require:
            - sls: {{ project }}.java

