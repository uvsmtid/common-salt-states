
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

# Expand all properties into root of profile to
# access them through `pillar` template dict.
# NOTE: The only reason why properties are loaded through `import_yaml`
#       in other places is to parameterize pillar SLS files (which cannot
#       be done otherwise as `pillar` template dict is not fully initialized
#       for pillar files themselves due to "chicken and egg" problem).
#       See: https://github.com/saltstack/salt/issues/6955#issuecomment-118001643

# NOTE: Use `json` to make sure None does not become just a string `None`.
{{ props|json }}

###############################################################################
# EOF
###############################################################################

