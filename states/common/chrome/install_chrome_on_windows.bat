REM LEAVE THIS LINE TO ENABLE BASIC SYNTAX HIGHLIGHTING

{% from 'common/libs/utils.lib.sls' import get_salt_content_temp_dir with context %}

REM TODO: Rewrite to use `google_chrome_64_bit_windows` content item.

REM Install Chrome:
"{{ get_salt_content_temp_dir() }}\ChromeStandaloneSetup.exe"


