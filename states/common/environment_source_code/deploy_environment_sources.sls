# Deploy sources.
# The state uses control scripts deployed on the minions to deploy sources
# for system.

include:
    - common.json_for_python

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora', 'Windows' ] %}

{% if pillar['system_features']['deploy_environment_sources']['feature_enabled'] %}

{% set selected_host = pillar['system_hosts'][grains['id']] %}

{% if grains['kernel'] == 'Linux' %}
{% set path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][selected_host['os_type']]['path'] %}
{% elif grains['kernel'] == 'Windows' %}
{% set path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][selected_host['os_type']]['path'] %}
{% set path_to_sources_cygwin = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][selected_host['os_type']]['path_cygwin'] %}
{% endif %}

'{{ path_to_sources }}_existing_path':
    file.exists:
        - name: '{{ path_to_sources }}'

# Descriptor configuration:
{% if grains['kernel'] == 'Linux' %}
'{{ path_to_sources }}/control/conf/descriptor.conf':
{% elif grains['kernel'] == 'Windows' %}
'{{ path_to_sources }}\control\conf\descriptor.conf':
{% endif %}
    file.managed:
        - source: salt://common/environment_source_code/environment.source.deployment.descriptor.conf
        - template: jinja
{% if grains['kernel'] == 'Linux' %}
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
{% endif %}
        - makedirs: True
        - require:
            - file: '{{ path_to_sources }}_existing_path'

# Job configuration:
{% if grains['kernel'] == 'Linux' %}
'{{ path_to_sources }}/control/conf/jobs/environment_sources.conf':
{% elif grains['kernel'] == 'Windows' %}
'{{ path_to_sources }}\control\conf\jobs\environment_sources.conf':
{% endif %}
    file.managed:
        - source: salt://common/environment_source_code/environment.source.deployment.job.conf
        - template: jinja
{% if grains['kernel'] == 'Linux' %}
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - group: {{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}
{% endif %}
        - makedirs: True
        - require:
            - file: '{{ path_to_sources }}_existing_path'

# Run the job to checkout sources:
'deploy_environment_sources_on_remote_host_cmd':
    cmd.run:
{% if grains['kernel'] == 'Linux' %}
        # On Windows it is executed by Cygwin python using posix paths.
        - name: '         /usr/bin/python control/init.py --skip_branch_control -j environment_sources -l debug -c file://{{ path_to_sources        }}/control/conf/'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - cwd: '{{ path_to_sources }}'
{% elif grains['kernel'] == 'Windows' %}
        # On Windows it is executed by Cygwin python using posix paths.
        - name: 'bash -c "/usr/bin/python control/init.py --skip_branch_control -j environment_sources -l debug -c file://{{ path_to_sources_cygwin }}/control/conf/"'
        - cwd: '{{ path_to_sources }}'
{% endif %}
        - require:
            - sls: common.json_for_python

{% endif %}

{% endif %}
# >>>
###############################################################################


