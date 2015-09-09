# Custom shell prompt.

include:
    - common.shell
{% if grains['os_platform_type'].startswith('win') %}
    - common.cygwin.package
{% endif %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}


# Variable PROMPT_COMMAND is sometimes set by some scripts in `profile.d`
# directory (like `vte.sh`) which are placed there by packages automatically
# (not by human) which makes little sense as prompt is essentially a humah
# requirement.
# Run command and rename all `PROMPT_COMMAND` in all `*.sh` scripts under
# `profile.d` directory to make sure it does not interfere with our
# customization.
rename_PROMPT_COMMAND_in_profile_dir:
    cmd.run:
        - name: "find /etc/profile.d -name '*.sh' -and -not -name 'common.custom.prompt.sh' -exec sed -i 's/\\<PROMPT_COMMAND\\>/PROMPT_COMMAND_RENAMED/g' '{}' ';'"
        # Note that double grep is required:
        # - The first one generates output but does not produce error code.
        # - The second one checks the output again and generates error code.
        - onlyif: "find /etc/profile.d -name '*.sh' -and -not -name 'common.custom.prompt.sh' -exec grep '\\<PROMPT_COMMAND\\>' '{}' ';' | grep '\\<PROMPT_COMMAND\\>'"
        - cwd: '/etc/profile.d'

rename_PROMPT_COMMAND_in_bashrc:
    cmd.run:
        - name: "sed -i 's/\\<PROMPT_COMMAND\\>/PROMPT_COMMAND_RENAMED/g' /etc/bashrc"
        # Note that double grep is required:
        # - The first one generates output but does not produce error code.
        # - The second one checks the output again and generates error code.
        - onlyif: "grep '\\<PROMPT_COMMAND\\>' /etc/bashrc | grep '\\<PROMPT_COMMAND\\>'"

/etc/profile.d/common.custom.prompt.sh:
    file.managed:
        - source: salt://common/shell/prompt/common.custom.prompt.sh
        - mode: 555
        - template: jinja
        - require:
            - sls: common.shell
            - cmd: rename_PROMPT_COMMAND_in_profile_dir
            - cmd: rename_PROMPT_COMMAND_in_bashrc

{% if 'bash_prompt_info_config' in pillar['system_features'] %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_git_aware_bash_prompt'] %}

git_aware_bash_promt_functions_script:
    file.managed:
        - name: '/lib/git_aware_prompt/git_aware_prompt_func.sh'
        - source: 'salt://common/shell/prompt/git_aware_prompt_func.sh'
        - mode: 555
        - makedirs: True

{% endif %} # enable_git_aware_bash_prompt

{% if pillar['system_features']['bash_prompt_info_config']['enable_last_command_non_zero_exit_code'] %}

last_command_non_zero_exit_code_functions_script:
    file.managed:
        - name: '/lib/last_command_exit_code_prompt/last_command_exit_code_prompt_func.sh'
        - source: 'salt://common/shell/prompt/last_command_exit_code_prompt_func.sh'
        - mode: 555
        - makedirs: True

{% endif %} # enable_last_command_non_zero_exit_code

{% endif %} # bash_prompt_info_config

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% set cygwin_content_config = pillar['system_resources']['cygwin_package_64_bit_windows'] %}

{% if cygwin_content_config['enable_installation'] %}

{% set cygwin_root_dir = cygwin_content_config['installation_directory'] %}

'{{ cygwin_root_dir }}\etc\profile.d\common.custom.prompt.sh':
    file.managed:
        - source: salt://common/shell/prompt/common.custom.prompt.sh
        - template: jinja
        - require:
            - sls: common.cygwin.package
            - sls: common.shell

{{ cygwin_root_dir }}\etc\profile.d\common.custom.prompt.sh_dos2unix:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile.d\common.custom.prompt.sh'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\profile.d\common.custom.prompt.sh'

# Suppress setting PS1 in `/etc/profile`.
# There is a (quite silly) logic in Cygwin `/etc/profile` which sets
# PS1 variable after running scripts from `/etc/profile.d` (where it is
# likely to be set as expected customiztion).
#
# Comment out any setting of PS1 in `/etc/profile` by default.
'{{ cygwin_root_dir }}\etc\profile':
    file.replace:
        - pattern: '^([^#]*)PS1='
        - repl: '#\1PS1='
        - show_changes: True
        - require:
            - sls: common.cygwin.package

convert_profile_file_to_unix_line_endings:
    cmd.run:
        # NOTE: This is strange, but you have to apply `dos2unix` command
        #       two times because of the output of `file.replace` above.
        #       Initial file is reported by `file` command as
        #         /etc/profile:          ASCII text, with CRLF, CR line terminators
        #       Then it is reported as
        #         /etc/profile:          ASCII text, with CRLF line terminators
        #       And only after second `dos2unix` it becomes
        #         /etc/profile:          ASCII text
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile && {{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\profile'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\profile'

# Suppress setting PS1 in `/etc/bash.bashrc`.
'{{ cygwin_root_dir }}\etc\bash.bashrc':
    file.replace:
        - pattern: '^([^#]*)PS1='
        - repl: '#\1PS1='
        - show_changes: True
        - require:
            - sls: common.cygwin.package

convert_bashrc_file_to_unix_line_endings:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\bash.bashrc && {{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\etc\bash.bashrc'
        - require:
            - file: '{{ cygwin_root_dir }}\etc\bash.bashrc'


{% endif %}

{% if 'bash_prompt_info_config' in pillar['system_features'] %}

{% if pillar['system_features']['bash_prompt_info_config']['enable_git_aware_bash_prompt'] %}

git_aware_bash_promt_functions_script:
    file.managed:
        - name: '{{ cygwin_root_dir }}\lib\git_aware_prompt\git_aware_prompt_func.sh'
        - source: 'salt://common/shell/prompt/git_aware_prompt_func.sh'
        - mode: 555
        - makedirs: True

convert_git_aware_bash_promt_functions_script_line_endings:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\lib\git_aware_prompt\git_aware_prompt_func.sh && {{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\lib\git_aware_prompt\git_aware_prompt_func.sh'
        - require:
            - file: git_aware_bash_promt_functions_script

{% endif %} # enable_git_aware_bash_prompt

{% endif %} # bash_prompt_info_config

{% if pillar['system_features']['bash_prompt_info_config']['enable_last_command_non_zero_exit_code'] %}

last_command_non_zero_exit_code_functions_script:
    file.managed:
        - name: '{{ cygwin_root_dir }}\lib\last_command_exit_code_prompt\last_command_exit_code_prompt_func.sh'
        - source: 'salt://common/shell/prompt/last_command_exit_code_prompt_func.sh'
        - mode: 555
        - makedirs: True

last_command_non_zero_exit_code_functions_script_line_endings:
    cmd.run:
        - name: '{{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\lib\last_command_exit_code_prompt\last_command_exit_code_prompt_func.sh && {{ cygwin_root_dir }}\bin\dos2unix.exe {{ cygwin_root_dir }}\lib\last_command_exit_code_prompt\last_command_exit_code_prompt_func.sh'
        - require:
            - file: last_command_non_zero_exit_code_functions_script

{% endif %} # enable_last_command_non_zero_exit_code

{% endif %}
# >>>
###############################################################################
