
###############################################################################
#

# Load Fedora versions list.
{% set fedora_versions_list_path = profile_root.replace('.', '/') + '/common/system_platforms/fedora_versions_list.yaml' %}
{% import_yaml fedora_versions_list_path as fedora_versions_list %}

system_platforms:

    # NOTE: Fedora realeases are fast-rolling.
    #       Use the same platform definition file (while it makes sense).
    {% for fedora_version in fedora_versions_list %}
    {{ fedora_version }}:

        os_type: linux

        # Default GRUB version on latest Fedora-s is 2.
        grub_version: 'grub-2'

    {% endfor %}

###############################################################################
# EOF
###############################################################################

