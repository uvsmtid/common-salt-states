# Handy dummy state which prints content of config.

# Define properties (they are loaded as values to the root of pillars):
{% set props = pillar %}

{% set this_system_keys = props['this_system_keys'] %}

dummy_state_show_config:
    cmd.run:
        - name: "echo {{ this_system_keys }}"

