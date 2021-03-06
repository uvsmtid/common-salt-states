#

{% set enable_mod_ssl = pillar['system_features']['webserver_configuration']['enable_mod_ssl'] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

webserver:
    pkg.installed:
        - name: httpd
        - aggregate: True
    service.running:
        - name: httpd
        - enable: True
        - watch:
            - file: /etc/httpd/conf.d/default.conf
        - require:
            - pkg: webserver
            - file: /var/www/html/default/content/default.txt
            - file: /var/log/httpd/hosts/default
            {% if enable_mod_ssl %}
            - pkg: mod_ssl_package
            {% endif %}

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

{% if enable_mod_ssl %}
mod_ssl_package:
    pkg.installed:
        - name: mod_ssl
{% endif %}

{% endif %}
# >>>
###############################################################################


