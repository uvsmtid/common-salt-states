# Basic libvirt configuration
# See:
#   http://docs.saltstack.com/topics/tutorials/cloud_controller.html

# To avoid unnecessary installation,
# require this host to be assigned to `hypervisor-role`.
{% if grains['id'] in pillar['system_host_roles']['hypervisor-role']['assigned_hosts'] %}

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

libvirt_packages_installation:
    pkg.installed:
        - pkgs:
            - libvirt-daemon
            - vagrant-libvirt
        - aggregate: True

/etc/sysconfig/libvirtd:
    file.managed:
        - source: salt://common/libvirt/libvirtd.sysconfig
        - require:
            - pkg: libvirt_packages_installation

/etc/libvirt/libvirtd.conf:
    file.managed:
        - source: salt://common/libvirt/libvirtd.conf
        - require:
            - pkg: libvirt_packages_installation


/etc/libvirt/qemu.conf:
    file.managed:
        - source: salt://common/libvirt/qemu.conf
        - require:
            - pkg: libvirt_packages_installation

# Create `libvirt` group.
# And add primary user to `libvirt` group.
# See:
#   *   http://linuxserver.io/?p=403
#   *   http://wiki.libvirt.org/page/Failed_to_connect_to_the_hypervisor#Permission_denied

create_libvirt_group:
    group.present:
        - name: libvirt
        - addusers:
          - {{ pillar['system_hosts'][grains['id']]['primary_user']['username'] }}

libvirtd_service:
    service.running:
        - name: libvirtd
        - require:
            - pkg: libvirt_packages_installation
        - watch:
            - file: /etc/sysconfig/libvirtd
            - file: /etc/libvirt/libvirtd.conf
            - file: /etc/libvirt/qemu.conf

{% endif %}
# >>>
###############################################################################

{% endif %} # hypervisor-role

