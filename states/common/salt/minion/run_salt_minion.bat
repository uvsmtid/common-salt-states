{% set installation_dir = pillar['registered_content_items']['salt_minion_64_bit_windows']['installation_dir'] %}
REM Start Salt minion per user:
{{ installation_dir }}\salt-minion.exe -l debug

