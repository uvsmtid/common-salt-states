# Python module `simplejson` is required for Python 2.4 (RHEL5).

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS' ] %}

json_package_for_python:
    pkg.installed:
        - name: python-simplejson
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

# Latest python on Fedora is shipped with `json` module.

json_package_for_python_dummy:
    cmd.run:
        - name: "echo json_package_for_python_dummy"

{% endif %}
# >>>
###############################################################################


###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# Latest python on Windows is shipped with `json` module.

json_package_for_python_dummy:
    cmd.run:
        - name: "echo json_package_for_python_dummy"

{% endif %}
# >>>
###############################################################################


