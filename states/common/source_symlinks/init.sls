# Make sure correct source links are set up for Salt master.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %} # OS

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

# This state can either be run on Salt master or Salt minion in
# case of `offline-minion-installer` `bootstrap_mode`.
{% set bootstrap_mode = salt['pillar.get']('bootstrap_mode', '') %}
{% if
       ( grains['id'] in pillar['system_host_roles']['salt_master_role']['assigned_hosts'] )
       or
       ( bootstrap_mode == 'offline-minion-installer' )
%} # salt_master_role

# Ensure links exist and point to the source repository on Salt master.
{% if pillar['system_features']['source_symlinks_configuration']['feature_enabled'] %} # source_symlinks_configuration

'{{ get_salt_content_temp_dir() }}/ensure_source_link.sh':
    file.managed:
        - source: salt://common/source_symlinks/ensure_source_link.sh
        #- template: jinja
        - makedirs: True
        - dir_mode: 755
        - user: root
        - group: root
        - mode: 744

{% for link_config_name in pillar['system_features']['source_symlinks_configuration']['source_symlinks'].keys() %} # link_config_name

{% set link_config = pillar['system_features']['source_symlinks_configuration']['source_symlinks'][link_config_name] %}
{% set repo_name = link_config['repo_name'] %}
{% set repo_type = pillar['system_features']['deploy_environment_sources']['source_repo_types'][repo_name] %}
{% set repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][repo_name][repo_type] %}

# NOTE: For `offline-minion-installer` case `source_system_host` is actually
#       this minion itself.
{% if bootstrap_mode == 'offline-minion-installer' %}
{% set source_system_host = grains['id'] %}
{% else %}
{% set source_system_host = repo_config['source_system_host'] %}
{% endif %}

# In order to set (local) symlink, the source host should match current minion id.
# More over, this state is normally supposed to be executed on Salt master only
# (because there is no point to set up such symlinks on Salt minions unless
# these Salt minions are used without Salt master - standalone).
{% if source_system_host == grains['id'] %} # source_system_host

{% if repo_type == 'git' %} # repo_type

# Note that only `posix_user_home_dir` is used because Salt master where links are created can only be Linux host.
# TODO: Move this code to `git_uri.lib.sls`.
{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][source_system_host]['primary_user'] ] %}
{% set local_path_base = account_conf['posix_user_home_dir'] %}
{% set local_path_rest = repo_config['origin_uri_ssh_path'] %}
{% set local_path = local_path_base + '/' + local_path_rest %}

{% else %} # repo_type

# Fail by referencing undefined variable.
# The feature is not implemented for non-Git repos.
{{ NOT_IMPLEMENTED_FOR_NON_GIT_REPOS }}

{% endif %} # repo_type

# Make sure target exists.
'{{ local_path }}_{{ link_config_name }}':
    file.exists:
        - name: '{{ local_path }}'

ensure_source_link_{{ link_config_name }}_cmd:
    cmd.run:
        - name: '{{ get_salt_content_temp_dir() }}/ensure_source_link.sh "{{ local_path }}" "{{ link_config['abs_link_base_path'] }}" "{{ link_config['rel_target_path'] }}"'
        - require:
            - file: '{{ get_salt_content_temp_dir() }}/ensure_source_link.sh'
            - file: '{{ local_path }}_{{ link_config_name }}'

{% else %} # source_system_host

# Just put message in the output to note that the link was not created.
'note_message_{{ local_path }}_{{ link_config_name }}':
    cmd.run:
        - name: 'echo symlink "{{ link_config_name }}" to "{{ local_path }}" was not created because "{{ repo_config['source_system_host'] }}" is not "{{ grains['id'] }}"'

{% endif %} # source_system_host

{% endfor %} # link_config_name

{% endif %} # source_symlinks_configuration

{% endif %} # salt_master_role

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


