# Handy dummy state which shows Salt configuration.

{% set config = pillar['master'] %}

dummy_state_show-config:
    cmd.run:
        - name: "echo {{ config }}"

