# Maven configuration for Jenkins.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

include:
    - common.jenkins.master

maven_jenkins_configuration_file:
    file.managed:
        - name: '{{ pillar['system_features']['configure_jenkins']['jenkins_root_dir'] }}/hudson.tasks.Maven.xml'
        - source: 'salt://common/jenkins/maven/hudson.tasks.Maven.xml'
        - mode: 644
        - template: jinja
        - require:
            - pkg: jenkins_rpm_package

extend:
    jenkins_service_enable:
        cmd:
            - require:
                - file: maven_jenkins_configuration_file 

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


