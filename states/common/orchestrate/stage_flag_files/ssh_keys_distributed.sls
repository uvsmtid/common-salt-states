#

{% from 'common/orchestrate/stage_flag_files/lib.sls' import stage_flag_file_sls with context %}

{{ stage_flag_file_sls('common', 'ssh_keys_distributed') }}

