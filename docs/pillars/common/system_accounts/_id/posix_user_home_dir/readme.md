
Key `posix_user_home_dir` specifies home directory on
POSIX systems (on Linux and within Cygwin on Windows).

This value is used on any type of systems (Linux and Windows because Windows
may be installed with Cygwin on top of it).

All the following values should be consistent among each other (see
consolidated explanation under [system_accounts][1] key):
*   `posix_user_home_dir` (this)
*   [posix_user_home_dir_windows][3]
*   [windows_user_home_dir][4]
*   [windows_user_home_dir_cygwin][5]

[1]: /docs/pillars/common/system_accounts/_id/readme.md
[2]: /docs/pillars/common/system_accounts/_id/posix_user_home_dir/readme.md
[3]: /docs/pillars/common/system_accounts/_id/posix_user_home_dir_windows/readme.md
[4]: /docs/pillars/common/system_accounts/_id/windows_user_home_dir/readme.md
[5]: /docs/pillars/common/system_accounts/_id/windows_user_home_dir_cygwin/readme.md

