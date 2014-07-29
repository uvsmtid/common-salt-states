# This state is used, for example, to avoid `include` list be renderred
# empty (becoming None object after YAML compilation).

dummy_state:
    cmd.run:
        - name: "echo dummy"

