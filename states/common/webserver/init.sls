#

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}


webserver:
    pkg.installed:
        - name: httpd
    service.running:
        - name: httpd
        - enable: True
        - watch:
            - file: /etc/httpd/conf.d/default.conf
        - require:
            - pkg: webserver
            - file: /var/www/html/default/content/default.txt
            - file: /var/log/httpd/hosts/default

/etc/httpd/conf.d/default.conf:
    file.managed:
        - source: salt://common/webserver/default.conf
        - template: jinja
        - user: apache
        - group: apache
        - mode: 600

# Hint file pointing to web server name.
/var/www/html/default/content/default.txt:
    file.managed:
        - contents: "/etc/httpd/conf.d/default.conf"
        - user: apache
        - group: apache
        - mode: 600
        - dir_mode: 700
        - makedirs: True
        - require:
            - file: /var/www/html/default

/var/www/html/default:
    file.directory:
        - user: apache
        - group: apache
        - file_mode: 600
        - dir_mode: 700
        - makedirs: True
        - recurse:
            - user
            - group
            - mode

/var/log/httpd/hosts/default:
    file.directory:
        - user: apache
        - group: apache
        - file_mode: 600
        - dir_mode: 700
        - makedirs: True
        - recurse:
            - user
            - group
            - mode


{% endif %}
# >>>
###############################################################################


