# This is a lib of macros to compose SSH-like URIs for Git.

# This macro defines variable `git_repo_uri` to be used in states.
{%- macro define_git_repo_uri(git_repo_id) -%}
{%- set git_repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][git_repo_id]['git'] -%}
{%- set git_repo_uri_ssh_path = git_repo_config['origin_uri_ssh_path'] -%}
{%- set source_system_host = git_repo_config['source_system_host'] -%}
{%- set git_repo_uri_ssh_username = pillar['system_hosts'][source_system_host]['primary_user']['username'] -%}
{%- set git_repo_uri_ssh_hostname = pillar['system_hosts'][source_system_host]['hostname'] -%}
{%- set git_repo_uri = git_repo_uri_ssh_username + '@' + git_repo_uri_ssh_hostname + ':' + git_repo_uri_ssh_path -%}
{{- git_repo_uri -}}
{%- endmacro -%}

# This macro defines variable `git_repo_uri_maven` to be used in states
# providing Maven configuration.
{%- macro define_git_repo_uri_maven(git_repo_id) -%}

{%- set git_repo_config = pillar['system_features']['deploy_environment_sources']['source_repositories'][git_repo_id]['git'] -%}
{%- set git_repo_uri_ssh_path = git_repo_config['origin_uri_ssh_path'] -%}
{%- set source_system_host = git_repo_config['source_system_host'] -%}
{%- set git_repo_uri_ssh_username = pillar['system_hosts'][source_system_host]['primary_user']['username'] -%}
{%- set git_repo_uri_ssh_hostname = pillar['system_hosts'][source_system_host]['hostname'] -%}
{%- set git_repo_uri_address = git_repo_uri_ssh_username + '@' + git_repo_uri_ssh_hostname -%}

{# This is an attempt to reformat normal SSH-like uri to some weird format accoring to http://maven.apache.org/scm/git.html #}
{%- if git_repo_uri_ssh_path|first == '/' -%} {# absolute path #}
{%- set git_repo_uri_maven = 'scm:git:ssh://' + git_repo_uri_address + ':22' + git_repo_uri_ssh_path -%}
{%- else -%} {# relative path #}
{%- set git_repo_uri_maven = 'scm:git:ssh://' + git_repo_uri_address + ':22' + '/~/' + git_repo_uri_ssh_path -%}
{%- endif -%}

{{- git_repo_uri_maven -}}

{%- endmacro -%}

