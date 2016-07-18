# Yum repository configuration

# TODO: Rewrite to use `EPEL_5_4_noarch_RHEL5` content item.

# NOTE: EPEL should be configured by installing package (which is supposed to
#       exist on `depository_role` file server) because it is a prerequisite to install
#       Salt minion. This config can be used for validation.

###############################################################################
# <<< RHEL5 & 7
# EPEL is created only for RHEL-based OSes (Fedora does not need it).
{% if grains['os_platform_type'].startswith('rhel5') %}

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

{% endif %}

# >>> RHEL 5 & 7
#######################################################################

