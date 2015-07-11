# Handy dummy state which prints content of `system_parameters`.

dummy_state_show_system_parameters:
    cmd.run:
        # Note that pillar `system_parameters` renders variables from
        # external `*.jinja` files (not defined directly in pillar).
        - name: "echo {{ pillar['system_properties'] }}"

