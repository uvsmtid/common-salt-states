# Custom tmux configuration

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

tmux:
    pkg.installed:
        - name: tmux
        - aggregate: True

{% if pillar['system_features']['tmux_custom_configuration']['feature_enabled'] %}

/etc/tmux.conf:
    file.managed:
        - source: salt://common/tmux/tmux.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - require:
            - pkg: tmux

{% if pillar['system_features']['tmux_custom_configuration']['enable_tmux_ressurect'] %}

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_URI with context %}
{% from resources_macro_lib import get_registered_content_item_hash with context %}

opt_dir_for_tmux-resurrec_exists:
    file.directory:
        - name: /opt
        - makedirs: True


# Option `tar_options` causes problems on old Salt versions
# (it is treated as list of chars instead of string).
{% if grains['saltversion'] not in [ '2014.7.1' ] %}

deploy_tmux_resurrect_plugin:
    archive.extracted:
        - name: /opt/tmux-resurrect
        - if_missing: /opt/tmux-resurrect
        {% set resource_id = 'tmux_resurrect_plugin' %}
        - source: {{ get_registered_content_item_URI(resource_id) }}
        - source_hash: {{ get_registered_content_item_hash(resource_id) }}
        - archive_format: tar
        # NOTE: Skip first-level directory (which embeds version number).
        # NOTE: `tar_options` has been depricated in favour of `options`.
        - options: --strip-components=1
        # NOTE: Somehow, Salt believes that archive does not have
        #       top-level directory. However, it clearly has.
        - enforce_toplevel: False
        - require:
            - file: opt_dir_for_tmux-resurrec_exists

{% endif %} # saltversion

{% endif %} # enable_tmux_ressurect

{% endif %} # feature_enabled

{% endif %}
# >>>
###############################################################################

