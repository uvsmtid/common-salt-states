# Configuration of `local_yum_mirrors_role` on a webserver.

# TODO: This and default templates are almost identical.
#       Try using a common template instead.

{% if grains['id'] in pillar['system_host_roles']['local_yum_mirrors_role']['assigned_hosts'] %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% set local_yum_mirrors_role_content_parent_dir = pillar['system_features']['yum_repos_configuration']['local_yum_mirrors_role_content_parent_dir'] %}

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
                - file: /etc/httpd/conf.d/local_yum_mirrors_role.conf
            - require:
                - file: '{{ local_yum_mirrors_role_content_parent_dir }}/local_yum_mirrors_role.txt'
                - file: '/var/log/httpd/hosts/{{ pillar['system_host_roles']['local_yum_mirrors_role']['hostname'] }}'

# Configuration for Apache virtual server:
/etc/httpd/conf.d/local_yum_mirrors_role.conf:
    file.managed:
        - source: salt://common/webserver/local_yum_mirrors_role/local_yum_mirrors_role.conf
        - template: jinja
        - user: apache
        - group: apache
        - mode: 660

# Hint file pointing to web server name.
'{{ local_yum_mirrors_role_content_parent_dir }}/local_yum_mirrors_role.txt':
    file.managed:
        - contents: "/etc/httpd/conf.d/local_yum_mirrors_role.conf"
        - user: apache
        - group: apache
        - mode: 660
        - dir_mode: 770
        - makedirs: True
        - require:
            - file: '/var/www/html/{{ pillar['system_host_roles']['local_yum_mirrors_role']['hostname'] }}'

# Base directory for Apache virtual server:
'/var/www/html/{{ pillar['system_host_roles']['local_yum_mirrors_role']['hostname'] }}':
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
#           See cmd-based `fix_content_permissions` instead.
{% if False %}
        - recurse:
            - user
            - group
            - mode
{% endif %}

# NOTE: This is a workaround to very slow performance of `file.directory` with
#       `recurse` option.
fix_content_permissions:
    cmd.run:
        # NOTE: Trailing `/` after `local_yum_mirrors_role_content_parent_dir`
        #       is required as this directory may be a symlink.
        - name: |
            chown -R apache:apache "{{ local_yum_mirrors_role_content_parent_dir }}/" && \
            chmod -R u+rX "{{ local_yum_mirrors_role_content_parent_dir }}/" && \
            chmod -R g+rX "{{ local_yum_mirrors_role_content_parent_dir }}/" && \
            true

# Logs for Apache virtual server:
'/var/log/httpd/hosts/{{ pillar['system_host_roles']['local_yum_mirrors_role']['hostname'] }}':
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


