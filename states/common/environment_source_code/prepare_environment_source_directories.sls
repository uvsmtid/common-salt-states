# Prepare directories on minions for deployment of environment source code.

{% if pillar['system_features']['deploy_environment_sources']['feature_enabled'] %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora', ] %}

{% set path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location']['linux']['path'] %}

'{{ path_to_sources }}':
    file.directory:
        - user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - makedirs: True

{% endif %}

# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% set path_to_sources = pillar['system_features']['deploy_environment_sources']['environment_sources_location']['windows']['path'] %}
{% set path_to_sources_cygwin = pillar['system_features']['deploy_environment_sources']['environment_sources_location']['windows']['path_cygwin'] %}
{% set link_to_sources_cygwin = pillar['system_features']['deploy_environment_sources']['environment_sources_location']['windows']['link_cygwin'] %}

'{{ path_to_sources }}':
    file.directory:
        # Windows does not support `user` field.
        #- user: {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}
        - makedirs: True

'add_symlink_to_{{ path_to_sources }}_cmd':
    cmd.run:
        - name: 'ln -s -f "{{ path_to_sources_cygwin }}" "{{ link_to_sources_cygwin }}"'
        - require:
            - file: '{{ path_to_sources }}'

{% endif %}
# >>>
###############################################################################

{% endif %}

