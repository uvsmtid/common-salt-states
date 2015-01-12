# Global yum configuration for the node.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

yum_conf:
    file.managed:
        - name: /etc/yum.conf
        - source: salt://common/yum/yum.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja



{% if pillar['system_features']['offline_yum_repo']['feature_enabled'] %}
{% set offline_yum_repo_ip = pillar['system_features']['offline_yum_repo']['ip'] %}

{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

yum_base:
    pkgrepo.managed:
        - name: base
        - baseurl: http://{{offline_yum_repo_ip}}/mirror/centos/$releasever/os/$basearch/
        - enabled: 1

yum_updates:
    pkgrepo.managed:
        - name: updates
        - baseurl: http://{{offline_yum_repo_ip}}/mirror/centos/$releasever/updates/$basearch/
        - enabled: 1

yum_extras:
    pkgrepo.managed:
        - name: extras
        - enabled: 0

yum_centosplus:
    pkgrepo.managed:
        - name: centosplus
        - enabled: 0

{% else %} #TODO: prepare Fedora offline repo and replace yum_repo_ip

yum_base:
    pkgrepo.managed:
        - name: fedora
        - baseurl: http://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/
        - enabled: 1
yum_updates:
    pkgrepo.managed:
        - name: updates
        - baseurl: http://download.fedoraproject.org/pub/fedora/linux/updates/$releasever/$basearch/
        - enabled: 1

{% endif %}

{% endif %}

{% endif %}
# >>>
###############################################################################

