# This state distributes private ssh keys to every primary user.
# This (in particular, private key) subsequently will allow this user
# to connect to other remote hosts using public key auth.

{% if pillar['system_features']['initialize_ssh_connections']['feature_enabled'] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

include:
    - common.ssh

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

include:
    - common.cygwin.package
    - common.ssh

{% endif %}
# >>>
###############################################################################

# Every minion is eligible for private key deployment at least for primary
# user, so there is no condition why this minion won't get at least one
# copy of the key.
#
# Now select all possible users where keys should be deployed and apply the
# same method to deploy them.

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}
{% set public_key_res_id = pillar['system_features']['initialize_ssh_connections']['ssh_public_key_res_id'] %}
{% set private_key_res_id = pillar['system_features']['initialize_ssh_connections']['ssh_private_key_res_id'] %}

# 1. Primary user for this minion.
#
# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U

{% set case_name = 'primary_user' %}

{% set selected_role_name = 'none' %}
{% set primary_user = pillar['system_hosts'][grains['id']]['primary_user'] %}
{% for account_conf in [ pillar['system_accounts'][ primary_user ] ] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}
'{{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}/.ssh/id_rsa':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.ssh/id_rsa'
        - source: {{ get_registered_content_item_URI(private_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(private_key_res_id) }}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 600
        - makedirs: True
        - require:
            - sls: common.ssh
            - file: {{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions

'{{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}/.ssh/id_rsa.pub':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.ssh/id_rsa.pub'
        - source: {{ get_registered_content_item_URI(public_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(public_key_res_id) }}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 644
        - makedirs: True
        - require:
            - sls: common.ssh
            - file: {{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions

{{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions:
    file.directory:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.ssh'
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 700

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

'{{ case_name }}_{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa'
        - source: {{ get_registered_content_item_URI(private_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(private_key_res_id) }}
        - makedirs: True
        - require:
            - sls: common.cygwin.package

'{{ case_name }}_{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa.pub':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa.pub'
        - source: {{ get_registered_content_item_URI(public_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(public_key_res_id) }}
        - makedirs: True
        - require:
            - sls: common.cygwin.package

{{ case_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "chown {{ account_conf['username'] }} ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ; chmod 600 ~/.ssh/id_rsa; chmod 644 ~/.ssh/id_rsa.pub "'
        - require:
            - file: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa'
            - file: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa.pub'

{% endif %}
# >>>
###############################################################################

{% endfor %} # Outter loop of 1.

# 2. All users defined in `hosts_by_host_role`
#    if this minion assigned the required role.
#
# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U

{% set case_name = 'hosts_by_host_role' %}

{% for selected_role_name in pillar['system_features']['initialize_ssh_connections']['extra_private_key_deployment_destinations']['hosts_by_host_role'].keys() %}
{% if grains['id'] in pillar['system_host_roles'][selected_role_name]['assigned_hosts'] %}

{% for account_conf in pillar['system_features']['initialize_ssh_connections']['extra_private_key_deployment_destinations']['hosts_by_host_role'][selected_role_name].values() %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}
'{{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}/.ssh/id_rsa':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.ssh/id_rsa'
        - source: {{ get_registered_content_item_URI(private_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(private_key_res_id) }}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 600
        - makedirs: True
        - require:
            - sls: common.ssh
            - file: {{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions

'{{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}/.ssh/id_rsa.pub':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.ssh/id_rsa.pub'
        - source: {{ get_registered_content_item_URI(public_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(public_key_res_id) }}
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 644
        - makedirs: True
        - require:
            - sls: common.ssh
            - file: {{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions

{{ case_name }}_{{ selected_role_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions:
    file.directory:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.ssh'
        - user: {{ account_conf['username'] }}
        - group: {{ account_conf['primary_group'] }}
        - mode: 700

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

'{{ case_name }}_{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa'
        - source: {{ get_registered_content_item_URI(private_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(private_key_res_id) }}
        - makedirs: True
        - require:
            - sls: common.cygwin.package

'{{ case_name }}_{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa.pub':
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa.pub'
        - source: {{ get_registered_content_item_URI(public_key_res_id) }}
        - source_hash: {{ get_registered_content_item_hash(public_key_res_id) }}
        - makedirs: True
        - require:
            - sls: common.cygwin.package

{{ case_name }}_{{ account_conf['username'] }}_ensure_key_files_permissions:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\bash.exe -l -c "chown {{ account_conf['username'] }} ~/.ssh/id_rsa ~/.ssh/id_rsa.pub ; chmod 600 ~/.ssh/id_rsa; chmod 644 ~/.ssh/id_rsa.pub "'
        - require:
            - file: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa'
            - file: '{{ account_conf['posix_user_home_dir_windows'] }}\.ssh\id_rsa.pub'

{% endif %}
# >>>
###############################################################################

{% endfor %} # Innter loop of 2.

{% endif %}

{% endfor %} # Outer loop of 2.

{% endif %} # Feature

