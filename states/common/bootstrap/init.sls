#

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% set vagrant_dir = pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] + '/' + pillar['system_features']['vagrant_configuration']['vagrant_file_dir'] %}

{% for selected_host_name in pillar['system_hosts'].keys() %} # selected_host_name

{% set selected_host = pillar['system_hosts'][selected_host_name] %}
{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}

# Bootstrap script.
bootstrap_script_for_host_{{ selected_host_name }}:
    file.managed:
        - name: '{{ vagrant_dir }}/bootstrap/bootstrap.sh'
        - source: 'salt://common/bootstrap/bootstrap.sh'
        - makedirs: True
        # NOTE: This is not a template, the script can be used without Salt.
        #- template: jinja
        - mode: 755
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

# Salt minion configuration.
minion_config_for_host_{{ selected_host_name }}:
    file.managed:
        - name: '{{ vagrant_dir }}/bootstrap/host_configs/{{ selected_host_name }}/minion.conf'
        - source: 'salt://common/salt/minion/minion.conf'
        - makedirs: True
        - template: jinja
        - context:
            selected_host_name: '{{ selected_host_name }}'
            selected_pillar: {{ pillar|json }}
        - mode: 755
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'

{% endfor %} # selected_host_name

{% endif %}
# >>>
###############################################################################

