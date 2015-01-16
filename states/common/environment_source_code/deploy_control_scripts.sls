# Deploy control scripts.
# The state uses `scp` to copy locally available copy of control scripts to
# all minions.


# TODO: Use Salt job on the target minion to pull control scripts from
#       Salt itself which is already aviailable there (see pillar config
#       `ensure_source_links`).
#       This state makes sense if there was a need to deploy scripts on
#       non-Salt-controlled host. However, these `scp`-ing is done to
#       controlled minions to (making sound it more pointless) later
#       execute Salt job (!) on them calling the control scripts to deploy
#       the rest of sources. Basically, it could all be done in single
#       Salt job.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora', ] %}

{% if pillar['system_features']['deploy_environment_sources']['feature_enabled'] %}

# Assume SSH keys are already distributed.
# It is long-running state which is executed by orchestrate runner.
#include:
#    - common.ssh.distribute_public_keys

{% set control_scripts_repo_name = pillar['system_features']['deploy_environment_sources']['control_scripts_repo_name'] %}
{% set control_scripts_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][control_scripts_repo_name] %}
{% set control_scripts_repo_sources_path = pillar['system_features']['deploy_environment_sources']['source_repositories'][control_scripts_repo_name][control_scripts_repo_type]['salt_master_local_path'] %}
{% set control_scripts_dir_path = pillar['system_features']['deploy_environment_sources']['control_scripts_dir_path'] %}

{% set control_scripts_dir_basename = pillar['system_features']['deploy_environment_sources']['control_scripts_dir_basename'] %}

# Loop through all defined hosts and execute `scp` to them.
# Password is provided.
{% for host_config in pillar['system_hosts'].values() %}

{% if host_config['consider_online_for_remote_connections'] %}

{% if host_config['hostname'] not in pillar['system_features']['deploy_environment_sources']['exclude_hosts'] %}

{% set remote_host_type = host_config['os_type'] %}

{% if remote_host_type == 'windows' %}
{% set remote_path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][remote_host_type]['path_cygwin'] %}
{% elif remote_host_type == 'linux' %}
{% set remote_path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][remote_host_type]['path'] %}
{% endif %}

# Remove destination directory before copying.
# If `path/to/dest/dir` is not removed, copying by `cp -r dir path/to/dest/dir`
# will create a directory `path/to/dest/dir/dir`.
'remove_destination_directory_on_remote_host_{{ host_config['hostname'] }}_cmd':
    cmd.run:
        - name: 'ssh "{{ host_config['primary_user']['username'] }}"@"{{ host_config['hostname'] }}" "rm -rf {{ remote_path_to_sources }}/{{ control_scripts_dir_basename }}"'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}

# `scp`-copy sources on remote host.
'deploy_control_scripts_on_remote_host_{{ host_config['hostname'] }}_cmd':
    cmd.run:
        - name: 'scp -r "{{ control_scripts_repo_sources_path }}/{{ control_scripts_dir_path }}" "{{ host_config['primary_user']['username'] }}"@"{{ host_config['hostname'] }}":"{{ remote_path_to_sources }}/{{ control_scripts_dir_basename }}"'
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - require:
            - cmd: 'remove_destination_directory_on_remote_host_{{ host_config['hostname'] }}_cmd'
        # Assume SSH keys are already distributed to make this state faster.
        #- require:
        #    - sls: common.ssh.distribute_public_keys

{% endif %}

{% endif %}

{% endfor %}


{% endif %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################

