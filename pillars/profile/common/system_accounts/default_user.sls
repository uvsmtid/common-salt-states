
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set default_username = props['default_username'] %}

system_accounts:

    default_user:
        username: {{ default_username }}
        password_secret: default_user_password
        password_hash: ~ # N/A
        enforce_password: True

        primary_group: {{ default_username }}

        posix_user_home_dir: '/home/{{ default_username }}'
        posix_user_home_dir_windows: 'C:\cygwin64\home\{{ default_username }}'

        windows_user_home_dir: 'C:\Users\{{ default_username }}'
        windows_user_home_dir_cygwin: '/cygdrive/c/Users/{{ default_username }}'

###############################################################################
# EOF
###############################################################################

