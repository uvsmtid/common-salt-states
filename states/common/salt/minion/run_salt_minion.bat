{% set installation_dir = pillar['system_resources']['salt_minion_64_bit_windows']['installation_dir'] %}
REM Start Salt minion per user:
{{ installation_dir }}\salt-minion.exe -l debug

