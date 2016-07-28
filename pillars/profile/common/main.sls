
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}

# For all minions (system hosts which are under automated configuration
# control) configuration states use this temporary directory to download and
# execute state enforcement:
posix_salt_content_temp_dir: '/{{ project_name }}.salt_content_temp_dir'
windows_salt_content_temp_dir: 'C:\{{ project_name }}.salt_content_temp_dir'
# This value should be in sync with `salt_content_temp_dir` on Windows.
# It is used in cases when a script file deployed by Salt on Windows
# is then run by Cygwin.
windows_salt_content_temp_dir_cygwin: '/cygdrive/c/{{ project_name }}.salt_content_temp_dir'

###############################################################################
# EOF
###############################################################################

