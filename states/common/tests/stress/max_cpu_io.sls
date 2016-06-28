# Run stress test for N minutes.

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

###############################################################################
# [[[
{% if grains['os_platform_type'].startswith('fc') %}

install_package_stress:
    pkg.installed:
        - name: stress

run_max_stress_cpu_io_forever_cmd:
    cmd.run:
        - name: 'stress --cpu {{ grains['num_cpus'] }} --io {{ grains['num_cpus'] }} --timeout 120'
        - require:
            - pkg: install_package_stress

{% endif %}
# ]]]
###############################################################################

###############################################################################
# [[[
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# ]]]
###############################################################################

