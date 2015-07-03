# Jenkins views configurations.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}



# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 1. Generate include list
include:

{% for view_name in pillar['system_features']['configure_jenkins']['view_configs'].keys() %}

{% set view_config = pillar['system_features']['configure_jenkins']['view_configs'][view_name] %}

{% if view_config['enabled'] %}

# Import function which is supposed to generate list of items to include:
{% set view_config_function_source = view_config['view_config_function_source'] %}
{% from view_config_function_source import view_config_include_item with context %}

# Note that it is OK to have duplicated items in the list.
# Call the function:
{{
    view_config_include_item(
        view_name,
        view_config,
    )
}}

{% endif %} # view_config['enabled']

{% endfor %}

    # At least one single element should be in the include list:
    - common.dummy



# TODO: It's code duplication due to poor Python logic/loop support in Jinja templates:
#       https://groups.google.com/forum/#!topic/salt-users/gUNUEFWds1U
#
# 2. Generage view configuration.
{% for view_name in pillar['system_features']['configure_jenkins']['view_configs'].keys() %}

{% set view_config = pillar['system_features']['configure_jenkins']['view_configs'][view_name] %}

{% if view_config['enabled'] %}

# Just call configured state which is supposed to configure the view:
{% set view_config_function_source = view_config['view_config_function_source'] %}
{% from view_config_function_source import view_config_function with context %}

# Call the function to generate configuration state for the view:
{{
    view_config_function(
        view_name,
        view_config,
    )
}}

{% endif %} # view_config['enabled']



{% endfor %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


