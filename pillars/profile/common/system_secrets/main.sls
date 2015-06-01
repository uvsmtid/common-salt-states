
###############################################################################
#
# WARNING: This file is only for example.
#          Contents of `system_secrets` is not supposed to be checked in.
#          The structure of `system_secrets` data is specifically made
#          trivial key-value pairs to be able to populate this file
#          on the spot.

{% set default_username = salt['config.get']('this_system_keys:default_username') %}

system_secrets:

    default_user_password: '{{ default_username }}'

###############################################################################
# EOF
###############################################################################

