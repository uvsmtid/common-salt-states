# Cygwin plugin for Jenkins Cygwin-awareness.

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
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

include:
    - common.jenkins.master
    - common.jenkins.download_jenkins_cli_tool

{% set registered_content_item_id = 'jenkins_cygpath_plugin' %}

{% set unique_suffix = 'cygwin' %}

# This SLS id is used by template.
'{{ registered_content_item_id }}_jenkins_plugin_installation_prerequisite_{{ unique_suffix }}':
    cmd.run:
        - name: "echo dummy:{{ registered_content_item_id }}"
        - require:
            - sls: common.jenkins.master
            - sls: common.jenkins.download_jenkins_cli_tool

# Call generic template.
{{ jenkins_plugin_installation_macros(registered_content_item_id, unique_suffix) }}


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


