# Maven installation.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

install_maven_package:
    pkg.installed:
        - name: maven
        - aggregate: True

maven_configuration_file:
    file.managed:
        - name: '{{ pillar['system_hosts'][grains['id']]['primary_user']['posix_user_home_dir'] }}/.m2/settings.xml'
        - source: 'salt://common/maven/settings.xml.sls'
        - template: jinja
        - makedirs: True
        - user: '{{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}'
        - group: '{{ pillar['system_hosts'][grains['id']]['primary_user']['primary_group'] }}'
        - mode: 644

maven_environment_variables_script:
    file.managed:
        - name: '/etc/profile.d/common.maven.variables.sh'
        - source: 'salt://common/maven/common.maven.variables.sh'
        - mode: 555
        - template: jinja

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


