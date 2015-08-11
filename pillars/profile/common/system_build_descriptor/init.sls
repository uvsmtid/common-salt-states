
###############################################################################
#

# Import dynamic build descriptor.
# The dynamic build descriptor is a set of values which might be generated
# automatically (and, therefore, placed into separate file for convenience).
{% set dynamic_build_descriptor_path = profile_root.replace('.', '/') + '/dynamic_build_descriptor.yaml' %}
{% import_yaml dynamic_build_descriptor_path as dynamic_build_descriptor %}

# The values are loaded under a key.
#
# If values are not under a key, empty file would result in `None` which
# breaks the structure of the entire document (as dictionary has to contain
# key-value pairs, not a `None` value).
#
# Note also that it renders it into JSON and on the same line. This allows
# getting valid syntax for `None` or any other scalar, list and dict.
dynamic_build_descriptor: {{ dynamic_build_descriptor|json }}

###############################################################################
# EOF
###############################################################################

