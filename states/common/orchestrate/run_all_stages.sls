# This file simply includes all stages which makes them executed.
#
# Each stage has associated stage flag file (they have the same name)
# and prerequsite stage flag files which is provided in profile
# configuration (in pillar).
#
# Details on what states are being set up and on which hosts are coded
# in the respective stage state.

include:

# NOTE: Because the order of keys in dict is not guaranteed, we use
#       explicitly specified order of keys in
#       a separate `state_flag_files_order`.
{% for stage_name in pillar['system_orchestrate_stages']['state_flag_files_order'] %}
    - common.orchestrate.stages.{{ stage_name }}
{% endfor %}

    # Use `dummy` to make YAML list even without any normal elements.
    - common.dummy

