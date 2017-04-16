
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}
{% set master_minion_id = props['master_minion_id'] %}
{% set profile_name = props['profile_name'] %}

# Import `maven_repo_names`.
{% set maven_repo_names_path = profile_root.replace('.', '/') + '/common/system_maven_artifacts/maven_repo_names.yaml' %}
{% import_yaml maven_repo_names_path as maven_repo_names %}
# TODO: Use `maven_repo_names` subkey in `maven_repo_names.yaml`.

system_features:

    deploy_environment_sources:

        # This is passed to override descriptor configuration on control
        # scripts command line. It could probably be placed directly in
        # Git configuration below (as it is in descriptor), but composing
        # this data in templates is awkward while this makes it is ready to
        # use (just like another similar override config `source_repo_types`)
        # via rendering into JSON.
        git_repo_local_paths:
            # Local path per Git repo:
            # - if absolute, it is single for all checkouts;
            # - if relative, it is single per job (control scripts).

            # Maven repositories.

            {% for maven_repo_name in maven_repo_names %}

            '{{ maven_repo_name }}': '/environment.sources/{{ maven_repo_name }}.git'

            {% endfor %}

###############################################################################
# EOF
###############################################################################

