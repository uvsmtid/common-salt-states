#

{% from 'common/orchestrate/lib.sls' import stage_flag_file_sls with context %}

{{ stage_flag_file_sls('common', 'orchestrate_stage_stop') }}

