# Maven installation.

###############################################################################
# <<<
# NOTE: RHEL5 does not include `maven` package.
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

install_maven_package:
    pkg.installed:
        - name: maven
        - aggregate: True

{% set account_conf = pillar['system_accounts'][ pillar['system_hosts'][ grains['id'] ]['primary_user'] ] %}
maven_configuration_file:
    file.managed:
        - name: '{{ account_conf['posix_user_home_dir'] }}/.m2/settings.xml'
        - source: 'salt://common/maven/settings.xml.sls'
        - template: jinja
        - makedirs: True
        - user: '{{ account_conf['username'] }}'
        - group: '{{ account_conf['primary_group'] }}'
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
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


