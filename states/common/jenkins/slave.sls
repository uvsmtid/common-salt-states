# Jenkins slave

include:
# Regardless of the OS version, SSH should be functional.
# On Windows OpenSSH is provided on Cygwin.
    - common.ssh
# Jenkins on RHEL5 requires non-pre-installed Java (and the following state
# installs correct version from EPEL):
#   https://wiki.jenkins-ci.org/display/JENKINS/Installing+Jenkins+on+Red+Hat+distributions
    - common.java

jenkins_slave_dummy:
    cmd.run:
        - name: "echo jenkins_slave_dummy"
        - require:
            - sls: common.ssh
            - sls: common.java

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

{% endif %}
# >>>
###############################################################################


