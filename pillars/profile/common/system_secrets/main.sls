
###############################################################################
#
# WARNING: This file is only for example.
#          The `system_secrets` data is trivial key-value pairs
#          to be able to populate/update on the spot.
#
#          However, secret data should rather be encrypted, especially,
#          when committed into Git repository - see `readme.md` in
#          the same directory with this file to use `gpg` renderer.

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set default_username = props['default_username'] %}


# WARNING: The following keys are NOT encrypted
#          (only those in separate files are).
#
#          This can be used to set some secret values (on the spot)
#          without committing them to Git repository.

system_secrets:

    default_user_password: '{{ default_username }}'

###############################################################################
# EOF
###############################################################################

