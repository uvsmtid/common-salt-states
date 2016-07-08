# Test that `os_platform_type` in grains matches those in pillars.

test_os_platform_type_grains_pillars_match:
    cmd.run:
        {% set grains_val = grains['os_platform_type'] %}
        {% set pillars_val = pillar['system_hosts'][ grains['id'] ]['os_platform'] %}
        {% if grains_val == pillars_val %}
        - name: 'echo {{ grains_val }} == {{ pillars_val }} && true'
        {% else %}
        - name: 'echo {{ grains_val }} == {{ pillars_val }} && false'
        {% endif %}

