# Deploy control scripts.
# The state uses `scp` to copy locally available copy of control scripts to
# all minions.

{% from 'common/libs/host_config_queries.sls' import is_network_checks_allowed with context %}

# TODO: Use Salt job on the target minion to pull control scripts from
#       Salt itself which is already aviailable there (see pillar config
#       `source_symlinks_configuration`).
#       This state makes sense if there was a need to deploy scripts on
#       non-Salt-controlled host. However, these `scp`-ing is done to
#       controlled minions to (making sound it more pointless) later
#       execute Salt job (!) on them calling the control scripts to deploy
#       the rest of sources. Basically, it could all be done in single
#       Salt job.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') %} # OS

{% if pillar['system_features']['deploy_environment_sources']['feature_enabled'] %} # deploy_environment_sources

# Assume SSH keys are already distributed.
# It is long-running state which is executed by orchestrate runner.
#include:
#    - common.ssh.distribute_public_keys

{% set control_scripts_repo_name = pillar['system_features']['deploy_environment_sources']['control_scripts_repo_name'] %}
{% set control_scripts_repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][control_scripts_repo_name] %}

{% set control_scripts_repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][control_scripts_repo_name][control_scripts_repo_type] %}
{% set source_system_host = control_scripts_repo_config['source_system_host'] %}

{% set control_scripts_dir_path = pillar['system_features']['deploy_environment_sources']['control_scripts_dir_path'] %}

{% if control_scripts_repo_type == 'git' %} # git

# Note that the `local_path` is used only as a source which means current minion.
# And current minion is supposed to be Linux.
# This is why only `posix_user_home_dir` is used.
# TODO: Move this code to `git_uri.lib.sls`.
{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][source_system_host]['primary_user'] ] %}
{% set local_path_base = account_conf['posix_user_home_dir'] %}
{% set local_path_rest = control_scripts_repo_config['origin_uri_ssh_path'] %}
{% set local_path = local_path_base + '/' + local_path_rest %}

{% endif %} # git

{% set control_scripts_dir_basename = pillar['system_features']['deploy_environment_sources']['control_scripts_dir_basename'] %}

# Loop through all defined hosts and execute `scp` to them.
{% for host_id in pillar['system_hosts'].keys() %} # host_id

{% set host_config = pillar['system_hosts'][host_id] %}

{% if is_network_checks_allowed(host_id) == 'True' %} # consider_online_for_remote_connections

{% if host_config['hostname'] not in pillar['system_features']['deploy_environment_sources']['exclude_hosts'] %} # exclude_hosts

{% set remote_host_type = pillar['system_platforms'][host_config['os_platform']]['os_type'] %}

{% if remote_host_type == 'windows' %}
{% set remote_path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][remote_host_type]['path_cygwin'] %}
{% elif remote_host_type == 'linux' %}
{% set remote_path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location'][remote_host_type]['path'] %}
{% endif %}

# Make sure directory under `environment_sources_location` exists.
# TODO: This will not work bacause `remote_path_to_sources` points to
#       non-existing directory in the root directory on this hosts.
#       So, it will always fail in this case when this directory is not there
#       because of user's permissions.
make_environment_sources_location_dir_{{ host_config['hostname'] }}_cmd:
    cmd.run:
        {% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}
        - name: 'ssh "{{ account_conf['username'] }}"@"{{ host_config['hostname'] }}" "mkdir -p {{ remote_path_to_sources }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}

# Remove destination directory before copying.
# If `path/to/dest/dir` is not removed, copying by `cp -r dir path/to/dest/dir`
# will create a directory `path/to/dest/dir/dir`.
'remove_destination_directory_on_remote_host_{{ host_config['hostname'] }}_cmd':
    cmd.run:
        {% set account_conf = pillar['system_accounts'][ host_config['primary_user'] ] %}
        - name: 'ssh "{{ account_conf['username'] }}"@"{{ host_config['hostname'] }}" "rm -rf {{ remote_path_to_sources }}/{{ control_scripts_dir_basename }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}

# `scp`-copy sources on remote host.
'deploy_control_scripts_on_remote_host_{{ host_config['hostname'] }}_cmd':
    cmd.run:
        - name: 'scp -r "{{ local_path }}/{{ control_scripts_dir_path }}" "{{ host_config['primary_user']['username'] }}"@"{{ host_config['hostname'] }}":"{{ remote_path_to_sources }}/{{ control_scripts_dir_basename }}"'
        {% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
        - user: {{ account_conf['username'] }}
        - require:
            - cmd: 'remove_destination_directory_on_remote_host_{{ host_config['hostname'] }}_cmd'
        # Assume SSH keys are already distributed to make this state faster.
        #- require:
        #    - sls: common.ssh.distribute_public_keys

{% endif %} # exclude_hosts

{% endif %} # consider_online_for_remote_connections

{% endfor %} # host_id


{% endif %} # deploy_environment_sources

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################

