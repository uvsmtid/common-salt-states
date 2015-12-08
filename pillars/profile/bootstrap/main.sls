
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set bootstrap_target_envs = props['load_bootstrap_target_envs'].keys() %}
{% set bootstrap_target_envs = bootstrap_target_envs + [ props['profile_name'] ] %}

# NOTE: This key was supposed to be under
#         system_features:source_bootstrap_configuration`
#       However, it was realized that `pillar` option on command line
#       completely overrides the sub-tree of dictionaries.
#       Therefore, the key had to be moved into root of the pillars.
#       
# NOTE: By default all bootstrap target environments are enabled.
#       However, there is only one bootstrap target pillars repository.
#       Therefore, the same bootstrap package is generated as many
#       times as there are enabled environments.
#       In order to optimize, bootstrap generation should be run
#       with option to override this pillar:
#         salt-call state.sls bootstrap.generate_content \
#           pillar="{ enable_bootstrap_target_envs: [ REQUIRED_TARGET ] }"
enable_bootstrap_target_envs: {{ bootstrap_target_envs|json }}

###############################################################################
# EOF
###############################################################################

