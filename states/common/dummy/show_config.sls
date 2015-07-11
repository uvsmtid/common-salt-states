# Handy dummy state which prints content of config.

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set this_system_keys = props['this_system_keys'] %}

dummy_state_show_config:
    cmd.run:
        - name: "echo {{ this_system_keys }}"

