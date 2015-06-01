
TODO:
*   Explain other fields of `system_accounts`

## Key credentials ##

*   `username`

    As it implies, synonym is "account name".

*   `password`

    This clear-text password may be used to distribute public SSH keys
    first time (for subsequent passwordless auth).

*   `password_hash`

    This is password hash as used for `password` field in `user.present`
    Salt state function - see [official Salt documentation][6].

## Various `*_user_home_dir*` values ##

Several different `*_user_home_dir*` should be maintained (for Windows hosts)
even though they may point to the same location in the underlying filesystem.

Linux requires _only_ [posix_user_home_dir][2] value and the rest are _ignored_.

On Windows we need to deal with another user home directory because there are
indeed two of them:
*   Home directory [windows_user_home_dir][4] provided by Windows itself.
*   Additional home directory [posix_user_home_dir][2] provided by Cygwin.
And what makes them 4 different values is the fact that these two locations
on the underlying filesystem can be addressed by paths in different formats
(Windows one and POSIX one within Cygwin on Windows).

For example, on Windows user effectively has two home directories:
*   `C:\users\username` provided by Windows ([windows_user_home_dir][4])
*   `/home/username` provided by Cygwin ([posix_user_home_dir][2])
Translating these paths (or computing other values dynamically in Salt states
is rather difficult). How would Salt being executed in Windows within native
Python translate native Windows path into Cygwin path?

These two paths can be tralsated by Cygwin utility in the other two,
for example:

```
cygpath -w '/home/username'
cygpath -u 'C:\users\username'
```

In the choice "cumbersome states" and "cumbersome config" the second option
"cumbersome config" has won at the moment and we got summary of 4
configuration values for single `username`, for example:
*   `/home/username` ([posix_user_home_dir][2]) points to user home directory as seen from Linux or Cygwin shell.
*   `C:\cygwin64\home\username` [posix_user_home_dir_windows][3] points to user home directory in Cygwin as seen from native Windows.
*   `C:\users\username` ([windows_user_home_dir][4]) points to user home directory as seen from native Windows.
*   `/cygdrive/c/users/username` ([windows_user_home_dir_cygwin][5]) points to user home directory in Windows as seen from Cygwin.

[1]: /docs/pillars/common/system_accounts/_id/readme.md
[2]: /docs/pillars/common/system_accounts/_id/posix_user_home_dir/readme.md
[3]: /docs/pillars/common/system_accounts/_id/posix_user_home_dir_windows/readme.md
[4]: /docs/pillars/common/system_accounts/_id/windows_user_home_dir/readme.md
[5]: /docs/pillars/common/system_accounts/_id/windows_user_home_dir_cygwin/readme.md
[6]: http://docs.saltstack.com/en/latest/ref/states/all/salt.states.user.html

