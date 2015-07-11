
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

# Expand all properties into pillar as well to access their values
# easily through `pillar` template dict.
# NOTE: The only reason why properties are loaded through `import_yaml`
#       in other places is to parameterize pillar SLS files (which cannot
#       be done as `pillar` template dict is not fully initialized
#       for pillar files themselves due to "chicken and egg" problem).
{{ props }}

###############################################################################
# EOF
###############################################################################

