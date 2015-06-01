
###############################################################################
#

{% set default_username = salt['config.get']('this_system_keys:default_username') %}

system_accounts:

    default_user:
        username: {{ default_username }}
        password: default_user_password
        password_hash: ~ # N/A
        enforce_password: True

        primary_group: {{ default_username }}

        posix_user_home_dir: '/home/{{ default_username }}'
        posix_user_home_dir_windows: ~ # N/A

        windows_user_home_dir: ~ # N/A
        windows_user_home_dir_cygwin: ~ # N/A

###############################################################################
# EOF
###############################################################################

