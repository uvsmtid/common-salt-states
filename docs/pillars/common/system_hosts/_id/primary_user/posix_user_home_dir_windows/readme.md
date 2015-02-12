
Key `posix_user_home_dir_windows` specifies [primary_user][1]'s home directory
provided in another [posix_user_home_dir][2] key (as it is used within Cygwin
on Windows) translated into Windows format.

For example, user's home directory `/home/username` within Cygwin points to
_exactly_ the same directory `C:\cygwin64\home\username` expressed in
Windows format. Translation from Cygwin format to Windows format can be done
by the following Cygwin utility:
```
cygpath -w '/home/username'
```

This value is not used on Linux systems (because Linux does not have Windows
to install Cygwin on top of it).

However, on Windows we need to deal with this second user home directory because
there are indeed two of them:
* Home directory [windows_user_home_dir][4] provided by Windows itself.
* Additional home directory [posix_user_home_dir][2] provided by Cygwin.
This `posix_user_home_dir_windows` value is simply a translation of Cygwin home
directory to Windows path format.

All the following values should be consistent among each other (see
consolidated explanation in their parent [primary_user][1] key):
* [posix_user_home_dir][2]
* `posix_user_home_dir_windows` (this)
* [windows_user_home_dir][4]
* [windows_user_home_dir_cygwin][5]

[1]: docs/pillars/common/system_hosts/_id/primary_user/readme.md
[2]: docs/pillars/common/system_hosts/_id/primary_user/posix_user_home_dir/readme.md
[3]: docs/pillars/common/system_hosts/_id/primary_user/posix_user_home_dir_windows/readme.md
[4]: docs/pillars/common/system_hosts/_id/primary_user/windows_user_home_dir/readme.md
[5]: docs/pillars/common/system_hosts/_id/primary_user/windows_user_home_dir_cygwin/readme.md

