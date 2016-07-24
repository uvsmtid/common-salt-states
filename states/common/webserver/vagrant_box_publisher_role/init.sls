# Configuration of `vagrant_box_publisher_role` on a webserver.

# TODO: This and default templates are almost identical.
#       Try using a common template instead.

{% if grains['id'] in pillar['system_host_roles']['vagrant_box_publisher_role']['assigned_hosts'] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% set vagrant_box_publisher_role_content_symlink = pillar['system_features']['vagrant_box_publisher_configuration']['vagrant_box_publisher_role_content_symlink'] %}
{% set vagrant_box_publisher_role_content_dir = pillar['system_features']['vagrant_box_publisher_configuration']['vagrant_box_publisher_role_content_dir'] %}

include:
    - common.webserver
#{#
    - {{ project_name }}.setup.passwd
    - {{ project_name }}.webserver.disable_root_test_page
    - {{ project_name }}.webserver.enable_root_list
#}#

extend:
    webserver:
        service:
            - watch:
                - file: vagrant_box_publisher_role_content_dir
                - file: vagrant_box_publisher_role_content_symlink
                - file: /etc/httpd/conf.d/vagrant_box_publisher_role.conf
            - require:
                - file: '{{ vagrant_box_publisher_role_content_dir }}/vagrant_box_publisher_role.txt'
                - file: '/var/log/httpd/hosts/{{ pillar['system_host_roles']['vagrant_box_publisher_role']['hostname'] }}'

# Directory for webserver content:
vagrant_box_publisher_role_content_dir:
    file.directory:
        - name: '{{ vagrant_box_publisher_role_content_dir }}'
        - user: apache
        - group: apache
        - file_mode: 660
        - dir_mode: 770
        - makedirs: True

# Set symlink from webserver content location to actual content location.
vagrant_box_publisher_role_content_symlink:
    file.symlink:
        - name: '{{ vagrant_box_publisher_role_content_symlink }}'
        - makedirs: True
        - target: '{{ vagrant_box_publisher_role_content_dir }}'
        - require:
            - file: vagrant_box_publisher_role_content_dir

# Configuration for Apache virtual server:
/etc/httpd/conf.d/vagrant_box_publisher_role.conf:
    file.managed:
        - source: salt://common/webserver/vagrant_box_publisher_role/vagrant_box_publisher_role.conf
        - template: jinja
        - user: apache
        - group: apache
        - mode: 660

# Hint file pointing to web server name.
'{{ vagrant_box_publisher_role_content_dir }}/vagrant_box_publisher_role.txt':
    file.managed:
        - contents: "/etc/httpd/conf.d/vagrant_box_publisher_role.conf"
        - user: apache
        - group: apache
        - mode: 660
        - dir_mode: 770
        - makedirs: True
        - require:
            - file: '/var/www/html/{{ pillar['system_host_roles']['vagrant_box_publisher_role']['hostname'] }}'
            - file: vagrant_box_publisher_role_content_symlink

# Base directory for Apache virtual server:
'/var/www/html/{{ pillar['system_host_roles']['vagrant_box_publisher_role']['hostname'] }}':
    file.directory:
        - user: apache
        - group: apache
        - file_mode: 660
        - dir_mode: 770
        - makedirs: True
# DISABLED: It may take long time if there are many files and directories.
#           Instead, each state which adds new content should make sure
#           permissions separately.
#
#           See cmd-based `fix_content_permissions_vagrant_box_publisher_role` instead.
{% if False %}
        - recurse:
            - user
            - group
            - mode
{% endif %}

# NOTE: This is a workaround to very slow performance of `file.directory` with
#       `recurse` option.
fix_content_permissions_vagrant_box_publisher_role:
    cmd.run:
        - name: 'chown -R apache:apache "{{ vagrant_box_publisher_role_content_dir }}" && chmod -R u+rX "{{ vagrant_box_publisher_role_content_dir }}" && chmod -R g+rX "{{ vagrant_box_publisher_role_content_dir }}"'

# Logs for Apache virtual server:
'/var/log/httpd/hosts/{{ pillar['system_host_roles']['vagrant_box_publisher_role']['hostname'] }}':
    file.directory:
        - user: apache
        - group: apache
        - file_mode: 660
        - dir_mode: 770
        - makedirs: True
        - recurse:
            - user
            - group
            - mode

{% endif %}
# >>>
###############################################################################

{% endif %}


