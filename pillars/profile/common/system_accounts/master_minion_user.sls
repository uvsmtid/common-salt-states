
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set default_username = props['default_username'] %}

system_accounts:

    master_minion_user:
        username: {{ default_username }}
        password_secret: default_user_password
        password_hash: ~ # N/A
        enforce_password: False

        primary_group: {{ default_username }}

        # NOTE: Salt master minion cannot be Windows.
        #       Therefore, no Windows home directory is set.

        posix_user_home_dir: '/home/{{ default_username }}'
        posix_user_home_dir_windows: ~ # N/A

        windows_user_home_dir: ~ # N/A
        windows_user_home_dir_cygwin: ~ # N/A

###############################################################################
# EOF
###############################################################################

