# This file simply includes all stages which makes them executed.
#
# Each stage has associated stage flag file (they have the same name)
# and prerequsite stage flag files which is provided in profile
# configuration (in pillar).
#
# Details on what states are being set up and on which hosts are coded
# in the respective stage state.

include:

{% for stage_name in pillar['system_orchestrate_stages']['stage_flag_files'].keys() %}
    - common.orchestrate.stage_flag_files.{{ stage_name }}
{% endfor %}

    # Use `dummy` to make YAML list even without any normal elements.
    - common.dummy

