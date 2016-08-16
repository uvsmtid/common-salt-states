
@echo on
REM This script downloads Cygwin and its components.

REM Switch into installer directory (to avoid creating logs in the current one)
cd "C:\cygwin.distrib\installer"
IF NOT %errorlevel%==0 (
    echo "Command returned: " %errorlevel%
    EXIT /B 1
)

{% set cygwin_settings = pillar['system_features']['cygwin_settings'] %}

{% set cygwin_root_dir = cygwin_settings['installation_directory'] %}

REM Run the setup providing list of all required components.
REM Note: the `^` character makes `cmd` interpreter concatenate lines.
REM TODO: Solve the problem of waiting until setup finishes.
REM       The following "start /wait" does not work.
start /wait C:\cygwin.distrib\installer\setup-x86_64.exe --packages ^
mintty,^
bzip2,^
unzip,^
zip,^
cpio,^
subversion,^
gcc,^
gcc-g++,^
gdb,^
make,^
libboost,^
libboost-devel,^
openssh,^
rsh,^
vim,^
nc,^
wget,^
git,^
git-svn,^
gitk,^
git-gui,^
perl,^
python,^
tcl-tk,^
xinit,^
xorg-server,^
xhost,^
xeyes,^
xterm,^
rsync,^
nano,^
libintl8,^
libiconv2,^
libncursesw10,^
libreadline7,^
tree,^
dos2unix,^
 --download ^
 --quiet-mode ^
 --no-desktop ^
 --local-package-dir "C:\cygwin.distrib\installer" ^
 --root "{{ cygwin_root_dir }}" ^
 --only-site ^
 --site "http://mirrors.kernel.org/sourceware/cygwin/"

REM Parameters to download:
REM --download ^
REM --quiet-mode ^
REM --no-desktop ^
REM --local-package-dir "C:\cygwin.distrib\installer" ^
REM --root "{{ cygwin_root_dir }}" ^
REM --only-site ^
REM --site "http://mirrors.kernel.org/sourceware/cygwin/"

REM Parameters to install:
REM --local-install ^
REM --quiet-mode ^
REM --no-desktop ^
REM --local-package-dir "C:\cygwin.distrib\installer" ^
REM --root "{{ cygwin_root_dir }}" ^
REM --only-site ^
REM --site "http://mirrors.kernel.org/sourceware/cygwin/"

IF NOT %errorlevel%==0 (
    echo "Command returned: " %errorlevel%
    EXIT /B 1
)

REM Switch to original directory (where the current script was called)
cd "%~dp0"
IF NOT %errorlevel%==0 (
    echo "Command returned: " %errorlevel%
    EXIT /B 1
)

