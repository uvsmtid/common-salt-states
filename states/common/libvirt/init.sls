# Basic libvirt configuration
# See:
#   http://docs.saltstack.com/topics/tutorials/cloud_controller.html

{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

libvirtd:
    pkg.installed:
        - name: libvirt-daemon

libvirtd_service:
    service.running:
        - name: libvirtd
        - require:
            - pkg: libvirtd
        - watch:
            - file: /etc/sysconfig/libvirtd
            - file: /etc/libvirt/libvirtd.conf
            - file: /etc/libvirt/qemu.conf


/etc/sysconfig/libvirtd:
    file.managed:
        - source: salt://common/libvirt/libvirtd.sysconfig
        - require:
            - pkg: libvirtd

/etc/libvirt/libvirtd.conf:
    file.managed:
        - source: salt://common/libvirt/libvirtd.conf
        - require:
            - pkg: libvirtd


/etc/libvirt/qemu.conf:
    file.managed:
        - source: salt://common/libvirt/qemu.conf
        - require:
            - pkg: libvirtd


{% endif %}
# >>>
###############################################################################

{% endif %}

