# Git plugins and configuration Jenkins.

# Import generic template for Jenkins plugin installation.
{% from 'common/jenkins/install_plugin.sls' import jenkins_plugin_installation_macros with context %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %} # OS

include:
    - common.jenkins.master
    - common.jenkins.download_jenkins_cli_tool

# Git plugin and its dependencies.
{% for registered_content_item_id in [
        'jenkins_scm-api_plugin',
        'jenkins_git-client_plugin',
        'jenkins_git_plugin',
    ]
%}

{% set unique_suffix = 'git' %}

# This SLS id is used by template.
'{{ registered_content_item_id }}_jenkins_plugin_installation_prerequisite_{{ unique_suffix }}':
    cmd.run:
        - name: "echo dummy:{{ registered_content_item_id }}"
        - require:
            - sls: common.jenkins.master
            - sls: common.jenkins.download_jenkins_cli_tool

# Call generic template.
{{ jenkins_plugin_installation_macros(registered_content_item_id, unique_suffix) }}

{% endfor %}

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


