# Python module `simplejson` is required for Python 2.4 (RHEL5).

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

json_package_for_python:
    pkg.installed:
        - name: python-simplejson
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') %}

# Latest python on RHEL7 is shipped with `json` module.

json_package_for_python_dummy:
    cmd.run:
        - name: "echo json_package_for_python_dummy"

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') %}

# Latest python on Fedora is shipped with `json` module.

json_package_for_python_dummy:
    cmd.run:
        - name: "echo json_package_for_python_dummy"

{% endif %}
# >>>
###############################################################################


###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# Latest python on Windows is shipped with `json` module.

json_package_for_python_dummy:
    cmd.run:
        - name: "echo json_package_for_python_dummy"

{% endif %}
# >>>
###############################################################################


