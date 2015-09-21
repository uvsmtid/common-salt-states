# Various plugins for build pipeline.

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
        'jenkins_parameterized-trigger_plugin',
        'jenkins_jquery_plugin',
        'jenkins_build-pipeline-plugin_plugin',
        'jenkins_maven-plugin_plugin',
        'jenkins_promoted-builds_plugin',
        'jenkins_copyartifact_plugin',
        'jenkins_join_plugin',
        'jenkins_rebuild_plugin',
        'jenkins_envinject_plugin',
        'jenkins_build-blocker-plugin_plugin',
    ]
%}

{% set unique_suffix = 'pipeline' %}

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


