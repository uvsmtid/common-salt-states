
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set dynamic_build_descriptor_path = profile_root.replace('.', '/') + '/dynamic_build_descriptor.yaml' %}
{% import_yaml dynamic_build_descriptor_path as dynamic_build_descriptor %}

# TODO: Add top-level pillars key here.

###############################################################################
# EOF
###############################################################################

