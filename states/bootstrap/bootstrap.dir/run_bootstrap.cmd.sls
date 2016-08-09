
REM ###############################################################################
REM # This script simply makes specifying arguments to bootstrap script
REM # more trivial. However, it still requires conscious reviewing and selecting
REM # (uncommenting) required `HOST_ID` assignment.
REM ###############################################################################

REM # Make sure `HOST_ID` value is not inherited from environment.
REM # This is to make this script fail before.
REM # TODO: Alternatively, allow passing `HOST_ID` via argument.
unset HOST_ID

REM # NOTE: Set different bootstrpap use case, if required.
set BOOTSTRAP_USE_CASE=initial-online-node

{% set target_env_pillar = pillar['bootstrap_target_profile'] %}
set PROJECT_NAME={{ target_env_pillar['properties']['project_name'] }}
set PROFILE_NAME={{ target_env_pillar['properties']['profile_name'] }}

REM NOTE: Uncomment required `HOST_ID` assignment before running the script.
REM #------------------------------------------------------------------------------
{% for host_id in target_env_pillar['system_hosts'].keys() %}
REM set HOST_ID={{ host_id }}
{% endfor %}
REM #------------------------------------------------------------------------------

echo "UNFORTUNATELY, it is difficult to display output in Windows
echo "while script output is still being written into a file."
echo "Review the `bootstrap.log` after the execution completes."
powershell -file .\bootstrap.ps1 ^
    deploy ^
    %BOOTSTRAP_USE_CASE% ^
    conf\%PROJECT_NAME%\%PROFILE_NAME%\%HOST_ID%.py ^
    > bootstrap.log 2>&1

IF NOT %errorlevel%==0 (
    echo "Command returned: " %errorlevel%
    echo "FAILURE"
    REM This is top-level script, so exit from `cmd` (without `/B`).
    pause
    EXIT 1
)
REM NOTE: We don't print "SUCCESS" as some commands don't
REM       return exit code on error.

echo "Review the `bootstrap.log` file for any errors."
pause

REM ###############################################################################
REM # EOF
REM ###############################################################################

