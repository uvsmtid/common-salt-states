# Cygwin plugin for Jenkins Cygwin-awareness.

# Import generic template for Jenkins plugin installation.
{% from 'common/jenkins/install_plugin.sls' import jenkins_plugin_installation_macros with context %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

include:
    - common.jenkins.master
    - common.jenkins.download_jenkins_cli_tool

{% set registered_content_item_id = 'jenkins_cygpath_plugin' %}

# This SLS id is used by template.
'{{ registered_content_item_id }}_jenkins_plugin_installation_prerequisite':
    cmd.run:
        - name: "echo dummy:{{ registered_content_item_id }}"
        - require:
            - sls: common.jenkins.master
            - sls: common.jenkins.download_jenkins_cli_tool

# Call generic template.
{{ jenkins_plugin_installation_macros(registered_content_item_id) }}


{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


