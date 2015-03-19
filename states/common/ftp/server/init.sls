

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

install_ftp_server:
    pkg.installed:
        - name: vsftpd
        - aggregate: True
    service.running:
        - name: vsftpd
        - enable: True
        - require:
            - pkg: vsftpd
            - file: /etc/vsftpd/vsftpd.conf

/etc/vsftpd/vsftpd.conf:
    file.append:
        # The issue requiring to add config lines does not exists on RHEL5.
        - text: |
{% if grains['os'] in [ 'Fedora' ] %}
            # This is due to the issue described here:
            #   https://bugzilla.redhat.com/show_bug.cgi?id=845980#c12
            seccomp_sandbox=NO
{% endif %}
        - require:
            - pkg: install_ftp_server


{% endif %}
# >>>
###############################################################################


