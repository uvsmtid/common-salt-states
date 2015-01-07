# Yum repository configuration

# TODO: Rewrite to use `EPEL_5_4_noarch_RHEL5` content item.

# NOTE: EPEL should be configured by installing package (which is supposed to
#       exist on `depository_role` file server) because it is a prerequisite to install
#       Salt minion. This config can be used for validation.

###############################################################################
# <<< RHEL5
# EPEL is created only for RHEL-based OSes (Fedora does not need it).
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

# set defaul epel version = 7
{% set epel_version = '7' %}
{% if grains['osrelease'] == '5.5' %}
    {% set epel_version = '5' %}
{% endif %}

# set default epel key name = RPM-PGP-KEY-EPEL-7
{% set epel_key_name = 'EPEL_KEY_7' %}
{% if grains['osrelease'] == '5.5' %}
    {% set epel_key_name = '217521F6.txt' %}
{% endif %}

/etc/yum.repos.d/epel.repo:
    file.managed:
        - source: salt://common/yum/epel/{{epel_version}}/epel.repo
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
        - source: salt://common/yum/epel/{{epel_version}}/{{epel_key_name}}
        - user: root
        - group: root
        - mode: 644



{% endif %}

{% endif %}

# >>> RHEL 5 & 7
#######################################################################

