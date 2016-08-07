
The preference is to keep "clean base OS".

Because Windows cannot run Python by default, it cannot be used
as entry point into bootstrap script. However, using Windows-specific
shell language (like `cmd` or PowerShell) for entire bootstrap runtime
logic requires undesired expertise in them (and Python is much more mature).

The approach is to run minimal `PowerShell` script to install Cygwin and then
run normal bootstrap script using Python provided by Cygwin. In other words,
the bootstrap packages mandatorily installs Cygwin on Windows first.

# Vagrant #

## Problem of Vagrant Synced Folder ##

For non-VirtualBox Vagrant provider (specifically, `libvirt`)
with Linux host and Windows guest, there is no opton for Vagrant
Synced Folders native to both host and guest.

*   [NFS][1]:

    > NFS folders do not work on Windows hosts. Vagrant will ignore your
    > request for NFS synced folders on Windows.

*   [`rsync`][2]:

    > On Windows, `rsync` installed with Cygwin or MinGW will be detected by
    > Vagrant and works well.

*   [SMB][3]:

    > Windows only! SMB is currently only supported when the host machine is
    > Windows.

*   [VirtualBox][4]: N/A

## Workaround using HTTP ##

It seems like the best option is `rsync`, but it requires Cygwin
pre-installed on Windows before bootstrap package is even uploaded to Windows
(which moves setup away from "clean base OS"). This is not an option.

The solution is to "pull" (download) instead of "push" (upload) -
run script on guest Windows to download bootstrap content from
known HTTP server. In short, use HTTP client instead `rsync` source.

There is a native `bitsadmin` tool (see [here][5] and [here][6] how)
on Windows for HTTP download. Another alternative is
[`wget` command in PowerShell][7], or other commands.
The main point is to use existing software for download client.

---

[1]: https://www.vagrantup.com/docs/synced-folders/nfs.html
[2]: https://www.vagrantup.com/docs/synced-folders/rsync.html
[3]: https://www.vagrantup.com/docs/synced-folders/smb.html
[4]: https://www.vagrantup.com/docs/synced-folders/virtualbox.html
[5]: http://superuser.com/a/284147/176657
[6]: http://stackoverflow.com/a/18198936/441652
[7]: http://superuser.com/a/693179/176657

