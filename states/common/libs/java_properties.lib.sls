# Set of macros to work with Java property files.

###############################################################################
# To depend on completion of the states in this macro, use the following
# requisite:
#   file: append_property_{# unique_id #}

{% macro append_property(
        unique_id
        ,
        file_path
        ,
        property_name
        ,
        property_value
        ,
        requisites_list
    )
%}

append_property_{{ unique_id }}:
    file.blockreplace:
        - name: '{{ file_path }}'
        - marker_start: "# AUTOMATICALLY MANAGED by Salt for {{ property_name }} ((("
        - content: |
            {{ property_name }}={{ property_value }}
        - marker_end: "# ))) AUTOMATICALLY MANAGED by Salt for {{ property_name }}"
        - append_if_not_found: True
        - require: {{ requisites_list }}

{% endmacro %}

###############################################################################
# To depend on completion of the states in this macro, use the following
# requisite:
#   file: comment_out_property_{# unique_id #}
{% macro comment_out_property(
        unique_id
        ,
        file_path
        ,
        property_name
        ,
        requisites_list
    )
%}

comment_out_property_{{ unique_id }}:
    file.comment:
        - name: '{{ file_path }}'
        - regex: '^\s*{{ property_name }}'
        - require: {{ requisites_list }}

{% endmacro %}

###############################################################################
# To depend on completion of the states in this macro, use the following
# requisite:
#   cmd: set_property_{# unique_id #}
{% macro set_property(
        unique_id
        ,
        file_path
        ,
        property_name
        ,
        property_value
        ,
        requisites_list
    )
%}

{{ comment_out_property(
        unique_id
        ,
        file_path
        ,
        property_name
        ,
        requisites_list
    )
}}

{{ append_property(
        unique_id
        ,
        file_path
        ,
        property_name
        ,
        property_value
        ,
        [
            { 'file': 'comment_out_property_' + unique_id }
        ]
    )
}}

set_property_{{ unique_id }}:
    cmd.run:
        - name: 'echo property "{{ property_name }}" was successfully set in "{{ file_path }}"'
        - require:
            - file: 'append_property_{{ unique_id }}'

{% endmacro %}

###############################################################################
# EOF
###############################################################################

