
###############################################################################
# This file is supposed to load pillars from separate "pillars" rository
# which override defaults set in pillars provided in "states" repository.

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

###############################################################################
# Overrides per file.

# NOTE: Overrides per file don not need to be listed UNLESS this file
#       is new and exits in "overrides" only (does not exists in "defaults").
#       If file path matches those in "overrides", it overrides "defaults"
#       without referening it here.

# Example syntax of loading an `*.sls` file with overrides.
{% if False %}

# NOTE: The files are loaded with their full path using dot-notation
#       relative to `profile_root`.

include:

    - {{ profile_root }}.common.system_host_roles.main:
        defaults:
            this_pillar: {{ profile_root }}.common.system_host_roles.main
            profile_root: {{ profile_root }}

    - {{ profile_root }}.common.system_features.external_http_proxy:
        defaults:
            this_pillar: {{ profile_root }}.common.system_features.external_http_proxy
            profile_root: {{ profile_root }}

{% endif %}

# TODO: Add your file overrides here.

###############################################################################
# Overrides per key.

# Example syntax of overriding specific keys in pillars.
# NOTE: The dictionaries are properly merged
#       (overriding only conflicting keys in "defaults" by "overrides").
#       See also: http://stackoverflow.com/a/27074516/441652
{% if False %}

# NOTE: The key is specified using full path to its nested dictionary
#       starting from root key.

system_features:
    source_bootstrap_configuration:
        enable_bootstrap_target_envs:
            # Additional profile to build bootstrap package for.
            production-pillars: ~

system_features:
    tmux_custom_configuration:
        feature_enabled: False

{% endif %}

# TODO: Add your key overrides here.

###############################################################################
# EOF
###############################################################################

