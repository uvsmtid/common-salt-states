# Handy dummy state which prints content of config.

{% set this_system_keys = salt['config.get']('this_system_keys') %}

dummy_state_show_config:
    cmd.run:
        - name: "echo {{ this_system_keys }}"

