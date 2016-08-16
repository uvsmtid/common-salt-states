# Deploy sources.
# The state uses control scripts deployed on the minions to deploy sources
# for system.

include:
    - common.json_for_python

###############################################################################
# <<<
# Any OS:
{% if grains['os_platform_type'] %}

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

{% from 'common/libs/utils.lib.sls' import get_windows_salt_content_temp_dir_cygwin with context %}

{% if pillar['system_features']['deploy_environment_sources']['feature_enabled'] %}

{% set selected_host = pillar['system_hosts'][grains['id']] %}

{% set control_scripts_dir_basename = pillar['system_features']['deploy_environment_sources']['control_scripts_dir_basename'] %}
{% set os_type = pillar['system_platforms'][selected_host['os_platform']]['os_type'] %}
{% if grains['kernel'] == 'Linux' %}
{% set path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][os_type]['path'] %}
{% elif grains['kernel'] == 'Windows' %}
{% set path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][os_type]['path'] %}
{% set path_to_sources_cygwin = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][os_type]['path_cygwin'] %}
{% endif %}

'{{ path_to_sources }}_existing_path':
    file.exists:
        - name: '{{ path_to_sources }}'

# Descriptor configuration:
{% if grains['kernel'] == 'Linux' %}
'{{ path_to_sources }}/{{ control_scripts_dir_basename }}/conf/descriptor.conf':
{% elif grains['kernel'] == 'Windows' %}
'{{ path_to_sources }}\{{ control_scripts_dir_basename }}\conf\descriptor.conf':
{% endif %}
    file.managed:
        - source: salt://common/environment_source_code/environment.source.deployment.descriptor.conf
        - template: jinja
{% if grains['kernel'] == 'Linux' %}
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
{% endif %}
        - makedirs: True
        - require:
            - file: '{{ path_to_sources }}_existing_path'

# Job configuration:
{% if grains['kernel'] == 'Linux' %}
'{{ path_to_sources }}/{{ control_scripts_dir_basename }}/conf/jobs/environment_sources.conf':
{% elif grains['kernel'] == 'Windows' %}
'{{ path_to_sources }}\{{ control_scripts_dir_basename }}\conf\jobs\environment_sources.conf':
{% endif %}
    file.managed:
        - source: salt://common/environment_source_code/deployment.job.environment.sources.conf
        - template: jinja
{% if grains['kernel'] == 'Linux' %}
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
{% endif %}
        - makedirs: True
        - require:
            - file: '{{ path_to_sources }}_existing_path'

# SSH config for Git (which is invoked inside `init.py`) to be passwordless.
passwordless_ssh_config_file:
    file.managed:
{% if grains['kernel'] == 'Linux' %}
        - name: '{{ get_salt_content_temp_dir() }}/passwordless_ssh_config.sh'
        - mode: 555
{% elif grains['kernel'] == 'Windows' %}
        - name: '{{ get_salt_content_temp_dir() }}\passwordless_ssh_config.sh'
{% endif %}
        - contents:
            ssh -x -o "StrictHostKeyChecking no" -o "PreferredAuthentications publickey" "$1" "$2"

# Only for Windows: convert line_endings.
{% if grains['kernel'] == 'Windows' %}
convert_passwordless_ssh_config_file_to_unix_line_endings:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ get_salt_content_temp_dir() }}\passwordless_ssh_config.sh'
        - require:
            - file: passwordless_ssh_config_file
{% endif %}

# Run the job to checkout sources:
'deploy_environment_sources_on_remote_host_cmd':
    cmd.run:
{% if grains['kernel'] == 'Linux' %}
        # On Windows it is executed by Cygwin python using posix paths.
        - name: '         /usr/bin/python {{ control_scripts_dir_basename }}/init.py --skip_branch_control -j environment_sources -l debug -c file://{{ path_to_sources        }}/control/conf/'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}
        - cwd: '{{ path_to_sources }}'
        - env:
            - GIT_SSH: '{{ get_salt_content_temp_dir()    }}/passwordless_ssh_config.sh'
{% elif grains['kernel'] == 'Windows' %}
        # On Windows it is executed by Cygwin python using posix paths.
        - name: 'bash -c "/usr/bin/python {{ control_scripts_dir_basename }}/init.py --skip_branch_control -j environment_sources -l debug -c file://{{ path_to_sources_cygwin }}/control/conf/"'
        - cwd: '{{ path_to_sources }}'
        - env:
            - GIT_SSH: '{{ get_windows_salt_content_temp_dir_cygwin() }}/passwordless_ssh_config.sh'
{% endif %}
        - require:
            - sls: common.json_for_python
{% if grains['kernel'] == 'Windows' %}
            - cmd: convert_passwordless_ssh_config_file_to_unix_line_endings
{% endif %}

{% endif %}

{% endif %}
# >>>
###############################################################################


