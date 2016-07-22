# Make sure correct resource links are set up for Salt master.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %} # OS

# This state can either be run on Salt master or Salt minion in
# case of `offline-minion-installer` `bootstrap_mode`.
{% set bootstrap_mode = salt['pillar.get']('bootstrap_mode', '') %}
{% if
       ( grains['id'] in pillar['system_host_roles']['salt_master_role']['assigned_hosts'] )
       or
       ( bootstrap_mode == 'offline-minion-installer' )
%} # salt_master_role

{% set config_temp_dir = pillar['posix_config_temp_dir'] %}

'resources_{{ config_temp_dir }}/ensure_resource_link.sh':
    file.managed:
        - name: '{{ config_temp_dir }}/ensure_resource_link.sh'
        # NOTE: We reuse the same script but renaming it on download.
        - source: salt://common/source_symlinks/ensure_source_link.sh
        #- template: jinja
        - makedirs: True
        - dir_mode: 755
        - user: root
        - group: root
        - mode: 744

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_URI_scheme_abs_links_base_dir_path with context %}
{% from resources_macro_lib import get_resource_repository_target_path with context %}
{% from resources_macro_lib import get_resource_repository_link_path  with context %}

{% for resource_respository_id in pillar['system_features']['resource_repositories_configuration']['resource_respositories'].keys() %} # resource_respository_id
{% set resource_respository_config = pillar['system_features']['resource_repositories_configuration']['resource_respositories'][resource_respository_id] %}

# Do not set symlink for any other than `salt://` URI scheme.
{% if resource_respository_config['URI_prefix_scheme'] == 'salt://' %} # URI_prefix_scheme

# Pre-create directory for resource symlinks.
# This directory is supposed to be configured in `file_roots`
# of Salt configuration.
'{{ resource_respository_id }}_base_dir_salt_config':
    file.directory:
        - name: '{{ get_URI_scheme_abs_links_base_dir_path('salt://') }}'
        - makedirs: True
        - force: False
        - allow_symlink: True

ensure_resource_repository_link_{{ resource_respository_id }}_cmd:
    cmd.run:
        - name: '{{ config_temp_dir }}/ensure_resource_link.sh "{{ get_resource_repository_target_path(resource_respository_id) }}" "{{ get_resource_repository_link_path(resource_respository_id) }}" ""'
        - require:
            - file: 'resources_{{ config_temp_dir }}/ensure_resource_link.sh'
            - file: '{{ resource_respository_id }}_base_dir_salt_config'

{% endif %} # URI_prefix_scheme

{% endfor %} # resource_respository_id

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


