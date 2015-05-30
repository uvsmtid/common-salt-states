
Key `windows_user_home_dir` specifies [primary_user][1]'s home directory on
Windows in standard windows format, for example, `C:\users\username`.

This value is not used on Linux systems because it is simply not applicable
(because there is no Windows on Linux).

However, on Windows we need to deal with this second user home directory because
there are indeed two of them:
* This home directory `windows_user_home_dir` provided by Windows itself.
* Additional home directory [posix_user_home_dir][2] provided by Cygwin.

All the following values should be consistent among each other (see
consolidated explanation in their parent [primary_user][1] key):
* [posix_user_home_dir][2]
* [posix_user_home_dir_windows][3]
* `windows_user_home_dir` (this)
* [windows_user_home_dir_cygwin][5]

[1]: /docs/pillars/common/system_hosts/_id/primary_user/readme.md
[2]: /docs/pillars/common/system_hosts/_id/primary_user/posix_user_home_dir/readme.md
[3]: /docs/pillars/common/system_hosts/_id/primary_user/posix_user_home_dir_windows/readme.md
[4]: /docs/pillars/common/system_hosts/_id/primary_user/windows_user_home_dir/readme.md
[5]: /docs/pillars/common/system_hosts/_id/primary_user/windows_user_home_dir_cygwin/readme.md

