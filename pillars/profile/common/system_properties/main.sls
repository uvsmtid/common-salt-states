
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

system_properties:

    {{ props }}

###############################################################################
# EOF
###############################################################################

