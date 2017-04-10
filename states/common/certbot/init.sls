# Install certbot tool for automatic SSL certificate installation and update.
# Certbot deploys Let's Encrypt certificates.

###############################################################################
# [[[
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

certbot_package:
    pkg.installed:
        - name: certbot

{% set domain_name = pillar['system_features']['hostname_resolution_config']['domain_name'] %}
{% set admin_email = pillar['system_features']['hostname_resolution_config']['admin_email'] %}
test_certificate_automation:
    cmd.run:
        - name: "certbot certonly -n --email {{ admin_email }} --test-cert --dry-run --webroot --webroot-path /var/www/html/{{ domain_name }} --domain {{ domain_name }}"
        - require:
            - pkg: certbot_package

# These are important notes to follow
# (they are displayed when running command interactively):
#
#   IMPORTANT NOTES:
#    - Your account credentials have been saved in your Certbot
#      configuration directory at /etc/letsencrypt. You should make a
#      secure backup of this folder now. This configuration directory will
#      also contain certificates and private keys obtained by Certbot so
#      making regular backups of this folder is ideal.

{% endif %}
# ]]]
###############################################################################

###############################################################################
# [[[
{% if grains['os_platform_type'].startswith('win') %}

# Not applicable. Nothing to do.

{% endif %}
# ]]]
###############################################################################


