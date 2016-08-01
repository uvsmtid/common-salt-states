# Some useful macros.

###############################################################################
# get_salt_content_temp_dir

{%- macro get_salt_content_temp_dir_from_pillar(
        pillar_data
    )
-%}

{%- if grains['kernel'] == 'Linux' -%}
{{- get_posix_salt_content_temp_dir_from_pillar( pillar_data ) -}}
{%- endif -%}
{%- if grains['kernel'] == 'Windows' -%}
{{- get_windows_salt_content_temp_dir_from_pillar( pillar_data ) -}}
{%- endif -%}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_salt_content_temp_dir(
    )
-%}

{{- get_salt_content_temp_dir_from_pillar( pillar ) -}}

{%- endmacro -%}

###############################################################################
# get_posix_salt_content_temp_dir
#

{%- macro get_posix_salt_content_temp_dir_from_pillar(
        pillar_data
    )
-%}

{{- pillar_data['posix_salt_content_temp_dir'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_posix_salt_content_temp_dir(
    )
-%}

{{- get_posix_salt_content_temp_dir_from_pillar( pillar ) -}}

{%- endmacro -%}

###############################################################################
# get_windows_salt_content_temp_dir
#

{%- macro get_windows_salt_content_temp_dir_from_pillar(
        pillar_data
    )
-%}

{{- pillar_data['windows_salt_content_temp_dir'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_windows_salt_content_temp_dir(
    )
-%}

{{- get_windows_salt_content_temp_dir_from_pillar( pillar ) -}}

{%- endmacro -%}

###############################################################################
# get_windows_salt_content_temp_dir_cygwin
#
# Cygwin version is explicit because there is no way to detect whether
# value returned by the macro is used by Cygwin scripts or not.

{%- macro get_windows_salt_content_temp_dir_cygwin_from_pillar(
        pillar_data
    )
-%}

{{- pillar_data['windows_salt_content_temp_dir_cygwin'] -}}

{%- endmacro -%}

#------------------------------------------------------------------------------

{%- macro get_windows_salt_content_temp_dir_cygwin(
    )
-%}

{{- get_windows_salt_content_temp_dir_cygwin_from_pillar( pillar ) -}}

{%- endmacro -%}

###############################################################################
# EOF
###############################################################################

