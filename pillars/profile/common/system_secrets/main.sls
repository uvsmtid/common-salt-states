
###############################################################################
#
# WARNING: This file is only for example.
#          Contents of `system_secrets` is not supposed to be checked in.
#          The structure of `system_secrets` data is specifically made
#          trivial key-value pairs to be able to populate this file
#          on the spot.

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set default_username = props['default_username'] %}

system_secrets:

    default_user_password: '{{ default_username }}'

###############################################################################
# EOF
###############################################################################

