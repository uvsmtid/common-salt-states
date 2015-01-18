# Yum repository configuration

# TODO: Rewrite to use `EPEL_5_4_noarch_RHEL5` content item.

# NOTE: EPEL should be configured by installing package (which is supposed to
#       exist on `depository_role` file server) because it is a prerequisite to install
#       Salt minion. This config can be used for validation.

###############################################################################
# <<< RHEL5 & 7
# EPEL is created only for RHEL-based OSes (Fedora does not need it).
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

/etc/yum.repos.d/epel.repo:
    file.managed:
        - source: salt://common/yum/epel/epel.repo
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - file: /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL

/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL:
    file.managed:
        # This file can be downloaded from:
        #   http://fedoraproject.org/static/217521F6.txt
        - source: salt://common/yum/epel/EPEL_KEY_{{grains['osmajorrelease']}}
        - user: root
        - group: root
        - mode: 644

{% if 'offline_yum_repo' in pillar['system_features'] and pillar['system_features']['offline_yum_repo']['feature_enabled'] %}
{% set offline_yum_repo_ip = pillar['system_features']['offline_yum_repo']['ip'] %}

yum_epel:
    pkgrepo.managed:
        - name: epel
        - baseurl: http://{{offline_yum_repo_ip}}/mirror/epel/$releasever/$basearch/
        - enabled: 1

yum_epel_debug_info:
    pkgrepo.managed:
        - name: epel-debuginfo
        - enabled: 0

yum_epel_source:
    pkgrepo.managed:
        - name: epel-source
        - enabled: 0

{% endif %}

{% endif %}

# >>> RHEL 5 & 7
#######################################################################

