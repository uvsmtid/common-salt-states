###############################################################################

# For all minions (system hosts which are under automated configuration
# control) configuration states use this temporary directory to download and
# execute state enforcement:
posix_config_temp_dir: '/common.salt.config_temp_dir'
windows_config_temp_dir: 'C:\common.salt.config_temp_dir'
# This value should be in sync with `config_temp_dir` on Windows. It is used
# in cases when a script file deployed by Salt on Windows is then run by
# Cygwin.
windows_config_temp_dir_cygwin: '/cygdrive/c/common.salt.config_temp_dir'

###############################################################################
# EOF
###############################################################################

