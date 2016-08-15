
###############################################################################

{% set resources_macro_lib = 'common/resource_symlinks/resources_macro_lib.sls' %}
{% from resources_macro_lib import get_registered_content_item_rel_path_windows with context %}
{% from resources_macro_lib import get_registered_content_item_rel_path with context %}

{% set cygwin_resource_id = 'bootstrap_cygwin_package_64_bit_windows' %}

# DISABLED: Both LibYAML and PyYAML are pre-installed with Cygwin.
{% if False %}
{% set LibYAML_resource_id = 'cygwin_bootstrap_LibYAML' %}
{% set PyYAML_resource_id = 'cygwin_bootstrap_PyYAML' %}
{% endif %}

Set-PSDebug -Strict -Trace 2
$ErrorActionPreference = "Stop"

$bootstrap_action = "$($args[0])"
$bootstrap_use_case = "$($args[1])"
$host_config_file_path_windows = "$($args[2])"

# Get path to script directory.
$bootstrap_base_dir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Change to directory of the script.
Get-Location
Set-Location -Path "$bootstrap_base_dir"
Get-Location

$host_config_file_path_windows
#if(![System.IO.File]::Exists($host_config_file_path_windows)){
if(-Not (Test-Path $host_config_file_path_windows) ){
    $host_config_file_path_windows
    "does NOT exists"
    exit 1
} else {
    $host_config_file_path_windows
    "exists"
}

# NOTE: Spaces between function name and parentheses are not allowed.
$selected_host_name = "$( [io.path]::GetFileNameWithoutExtension( $( Split-Path $host_config_file_path_windows -Leaf ) ) )"

$profile_name = "$( Split-Path $( Split-Path $host_config_file_path_windows -Parent ) -Leaf )"
$project_name = "$( Split-Path $( Split-Path $( Split-Path $host_config_file_path_windows -Parent ) -Parent ) -Leaf )"

# Unpack Cygwin package.
$cygwin_package_name = "resources\depository\$project_name\$profile_name\{{ get_registered_content_item_rel_path_windows(cygwin_resource_id)|replace("\\", "\\") }}"
Add-Type -A System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory("$bootstrap_base_dir\$cygwin_package_name", "$bootstrap_base_dir")

# Run Cygwin installation script.
$cygwin_offline_dirname = "cygwin-offline.git"
cmd /c start /i /b /wait "$cygwin_offline_dirname\install.cmd"

# Set inheritence to avoid permission hell.
# See http://stackoverflow.com/a/22453562/441652
icacls C:\cygwin64 /q /c /t /reset

# Insert line to set `CYGWIN TODO` environment variable.
# See: http://stackoverflow.com/a/23125468/441652
# The content of the `Cygwin.bat` file runs `bash` after `chdir` command -
# we set `CYGWIN` variable right after `chdir` before `bash`.
{% set CYGWIN_env_var_value = " ".join(cygwin_settings['CYGWIN_env_var_items_list']) %}
$lines = Get-Content "{{ cygwin_installation_directory }}\Cygwin.bat"
$pos = [array]::indexof($lines, $lines -match "chdir") # Could use a regex here.
$newLines = $lines[0..$pos], "set CYGWIN={{ CYGWIN_env_var_value }}", $lines[($pos + 1)..($lines.Length - 1)]
$newLines | Set-Content "{{ cygwin_installation_directory }}\Cygwin.bat"
# Also, set it in the global environment variables.
setx -m CYGWIN "{{ CYGWIN_env_var_value }}"

# Set PATH to add Cygwin .
# NOTE: This required only until the end of this setup script
#       because it is automatically by `cygwin-offline` installer
#       for all future shell sessions.
$env:Path += ";C:\cygwin64\bin\"

# Initialize Cygwin shell.
# TODO: Move this step into `cygwin-offline` package.
echo $Env:Path
cmd /c start /i /b /wait mintty /bin/bash -l -c "echo init"

# Convert path to Cygwin.
$bootstrap_base_dir_cygwin = "$(cygpath -u $bootstrap_base_dir)"
$host_config_file_path_cygwin = "$(cygpath -u $host_config_file_path_windows)"


# DISABLED: Both LibYAML and PyYAML are pre-installed with Cygwin.
{% if False %} # libyaml

# Install LibYAML.
# See: http://pyyaml.org/wiki/LibYAML
$LibYAML_package_name = "resources/depository/$project_name/$profile_name/{{ get_registered_content_item_rel_path(LibYAML_resource_id) }}"
$LibYAML_content_subdir = "{{ pillar['system_resources'][LibYAML_resource_id]['content_root_subdir_path_cygwin'] }}"
cmd /c start /i /b /wait bash -c "/usr/bin/tar -xvf $LibYAML_package_name ; cd $LibYAML_content_subdir ; ./configure ; /usr/bin/make install ; "
cmd /c start /i /b /wait bash -c "/usr/bin/rm -rf $LibYAML_content_subdir"

# Install PyYAML.
# See: http://pyyaml.org/wiki/PyYAML
$PyYAML_package_name = "resources/depository/$project_name/$profile_name/{{ get_registered_content_item_rel_path(PyYAML_resource_id) }}"
$PyYAML_content_subdir = "{{ pillar['system_resources'][PyYAML_resource_id]['content_root_subdir_path_cygwin'] }}"
cmd /c start /i /b /wait bash -c "export LIBRARY_PATH=/usr/local/lib ; /usr/bin/tar -xvf $PyYAML_package_name ; cd $PyYAML_content_subdir ; /usr/bin/python setup.py install ; /usr/bin/python setup.py test ; "
cmd /c start /i /b /wait bash -c "/usr/bin/rm -rf $PyYAML_content_subdir"

{% endif %} # libyaml

# Disable firewall to allow SSH and Salt minion connections.
# TODO: Move disabling firewall to Salt bootstrap package.
Set-NetFirewallProfile -All -Enabled False

# TODO: DISABLE: The SSH service is installed by Salt states.
{% if True %} # sshd_setup

# Install OpenSSH and start `sshd` service.
# NOTE: The `ssh-host-config` works perfectly but in a newly created session.
#       Because of this, the effective commands below only prepare
#       a script to run later.
# TODO: How to make these commands run in the new session?
# TODO: Move it to Salt states later.
#       It is only here to get convenient machine
#       before Salt bootstrap is fixed to set everything right.
# TODO: Move CYGWIN environment variable setting
#       like `winsymlinks:nativestrict` under dedicated `system_features` key.
#cmd /c start /i /b /wait bash -c "/usr/bin/cygrunsrv -R sshd"
#cmd /c start /i /b /wait bash -c "/usr/bin/mkpasswd -l > /etc/passwd"
#cmd /c start /i /b /wait bash -c "/usr/bin/mkgroup -l > /etc/group"
#cmd /c start /i /b /wait bash -c "/usr/bin/editrights -u vagrant -a SeAssignPrimaryTokenPrivilege"
#cmd /c start /i /b /wait bash -c "/usr/bin/editrights -u vagrant -a SeCreateTokenPrivilege"
#cmd /c start /i /b /wait bash -c "/usr/bin/editrights -u vagrant -a SeTcbPrivilege"
#cmd /c start /i /b /wait bash -c "/usr/bin/editrights -u vagrant -a SeServiceLogonRight"
#cmd /c start /i /b /wait bash -c "ssh-host-config --yes --cygwin winsymlinks:nativestrict --name sshd --pwd vagrant"
#cmd /c start /i /b /wait bash -c "cygrunsrv -S sshd"
cmd /c start /i /b /wait bash -c "echo '#!/bin/sh' > setup_sshd.sh"
cmd /c start /i /b /wait bash -c "echo ssh-host-config --yes --cygwin winsymlinks:nativestrict --name sshd --pwd vagrant >> setup_sshd.sh"
cmd /c start /i /b /wait bash -c "echo cygrunsrv -S sshd >> setup_sshd.sh"
cmd /c start /i /b /wait bash -c "chmod u+x setup_sshd.sh"

{% endif %} # sshd_setup

# TODO: DISABLE: The bootstrap script is ready.
{% if True %} # bootstrap_dev_setup

# Setup Git repository for Salt boostrap development.
# These are additional steps until Salt bootstrap script is ready.

# - Add entry for host machine to the hosts file.
$ip = "192.168.40.1"
$xhost = "parent-host"
"`n`t{0}`t{1}" -f $ip, $xhost | out-file "$env:windir\System32\drivers\etc\hosts" -enc ascii -append
# - Set up Git to make commits.
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/git config --global user.name \'Alexey Pakseykin\'"
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/git config --global user.email \'uvsmtid@gmail.com\'"
# - Prepare a script which prepares Git repository.
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/echo '#!/bin/sh' > prepare_repo.sh"
# TODO: Parameterize location of repository.
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/echo git clone uvsmtid@parent-host:Works/ida-root.git/salt/common-salt-states.git common-salt-states.git >> prepare_repo.sh"
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/echo rsync conf/ common-salt-states.git/states/bootstrap/bootstrap.dir/conf/ >> prepare_repo.sh"
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/echo rsync resources/ common-salt-states.git/states/bootstrap/bootstrap.dir/resources/ >> prepare_repo.sh"
cmd.exe /c C:\cygwin64\bin\bash -c "/usr/bin/chmod u+x prepare_repo.sh"

{% endif %} # bootstrap_dev_setup

# Run actual (Python) bootstrap script.
cmd /c start /i /b /wait bash -c "/usr/bin/python $bootstrap_base_dir_cygwin/bootstrap.py $bootstrap_action $bootstrap_use_case $host_config_file_path_cygwin"

###############################################################################
# EOF
###############################################################################

