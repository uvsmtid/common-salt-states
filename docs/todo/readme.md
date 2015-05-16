TODO

# See also #

* All individual files under [todo directory][todo_dir].
* All files under `todo` directories of individual project_names.

# TODOs #

* TODO: Make sure that Jenkins jobs can be chained.

* TODO: Add jenkins job which runs Salt highstate to make sure that
        configuration is up to date and verified.

* TODO: Create a proper script to add new path items to PATH env var.
        Basically, there is no easy way on Windows to do it properly.
        The script should remove duplicates and use registry directly.
        1. Command `setx` either merge user to global or
           global to user PATH values. And both of them is not what is needed.
           What happens is that with `setx -m` user part of PATH is repeated
           every time `setx -m` is called.
           See also:
               http://stackoverflow.com/a/10292113/441652
        2. There is a limit of 1024 characters for `setx` command which
           is often not enough. Instead, direct changes on registry should
           be done.

* TODO:       Orchestration states cannot be used without adding
              minion id of Salt master (how master's `grains['id']`
              is defined while running `salt-run`).
              In order to determine, you have to run simple orchestrate
              state. After running it, the master id will be reported
              in the output.
              For example, add the following content into `detect_master_id.sls` file:
              ```
              cmd.run:
                  salt.function:
                      - tgt: '*'
                      - arg:
                          - echo nothing
              ```
              Then run the following command (the master's id will be the first line):
              ```
              salt-run state.orchestrate detect_master_id
              ```

* TODO: Any state which creates files in 'C:\cygwin64' should depend on
        Cygwin installation instead of creating these files directly
        (as result creating this parent directory).
        Otherwise it creates this files and breaks
        "side effect check" for Cygwin installation (which is 'C:\cygwin64'
        directory at the moment). In addition to that change Cygwin
        installation "side effect" to something unique (a file created
        somewhere) otherwise this type of issue will come back with
        any new poorly written state.

* TODO: During distribution connecting to hosts for SSH keys distribution
        (accepting a host) file `~/.ssh/known_hosts` may contain residual
        keys if VM is not clean (i.e. remote VM was reinstalled, but not
        local one). This makes the process fail. Try to clean specific
        key from the ~/.ssh/known_hosts to make it automatic again.

* TODO: Add a state to import all required RPM keys.
        If EPEL is not configured (RPM package `epel-release`
        is not installed), there is a need to add EPEL RPM keys
        because some EPEL packages are part of pre-downloaded
        "offline" set of packages.
        For example, running `meld` installation via Salt will fail
        if EPEL RPM key is not imported.

* TODO: If Cygwin is installed for the first time using Salt,
        it fails because in order to have user's directory under
        /home/<username>, shell should be launched for this user
        at least once:
        ```
        ----------
	          ID: C:\cygwin64\home\username
	    Function: file.exists
	      Result: False
	     Comment: Specified path C:\cygwin64\home\username does not exist
	     Changes:
        ```

* Add deployment of "origin" Git repository from `depository-role`.
  This is to make sure there is initial repo for "origin" of all
  environment sources.

* TODO: Add support for bigger resolution on Virtual Box running this command
        on hypervisor-role:
            VBoxManage setextradata global GUI/MaxGuestResolution any

* TODO: Retrospectively, add `repository_role`'s items for 7Zip and Python:
        Specify their deployment path so that other scripts can refer
        to it by their name.
        See also:
            *       7Zip
            *       Salt
            *       Python
            * DONE: Cygwin
            *       Java

* TODO: Assign different hosts (linux or windows) to Jenkins jobs depending
        on Jenkins slave configuration.
        Or is current "restrict to host role" is good enough?

* TODO: Add one more sub-dir to `depository-role` (in addition to: `distrib`
        `repository`, `images`): `data` with clear documented organization,
        content type, purpose of splitting, etc.

# NOTES FOR ORCHESTRATION #

Setting up functionality on nodes should be done in sequence.

The following are notes of manual execution of required states to set up
new `blackbox` profile.

'blackbox':

    * Change profile name in `/srv/pillar/top.sls`.

    * After linking `/srv` to `./states` in repository, run
      the following command to sync everything (including
      extended grains Python modules under `/srv/states/_grains/`):
        salt '*' saltutil.sync_all

    * salt '{{ master_minion_id }}' state.sls {{ primary_state }}
    * Setup common packages (make life more comfortable):
          salt-run -l all state.orchestrate {{ project_name }}.orchestrate.setup.common

    * Configure hypervisor-role:
          salt-run -l all state.orchestrate {{ project_name }}.orchestrate.setup.hypervisor-role
      This sets /etc/resolv.conf to non-existing network address on
      Linux hypervisor (because network is not automatically configured).
      So, the following manual step is required to recover and continue:
        salt-call -l all state.sls {{ project_name }}.libvirt.network

      TODO: This state is obsolete and deprecated.
            It was created before Vagrant integration was done.

      TODO: add packages to install:
        virt-manager virt-viewer libvirt libvirt-python libvirt-client

# NOTES FOR TROUBLESHOOTING #

* Check what pillar a host sees (on the minion):
  salt-call -l debug pillar.items > pillar.txt

* Use:
    salt '*' saltutil.sync_all

# LOW PRIORITY #

## Add validator states and scripts for network configuration ##

TODO: This was a real need before Vagrant with bootstrap script were first
      created. However, having additional states to do validation will
      not harm - it's sort of unit testing (a second leg which will
      keep problems highlighted should the setup fail).

Check:
* IP,
* MAC,
* name resolution,
* access to YUM repositories,
* access to `depository-role` (HTTP web server),
* etc.
This is to validatate that system is running in expected state.
The decision whether to test this or not should come from the fact whether
this particular configuration is pushed/enforced (automated) or have to be
manually done. If it was manually done to allow running Salt, it should be
validatated instead of enforcing. And another question is whether currently
running VMs are affected by required changes on the hypervisor (i.e.
changes in virtual network configuration or storage). VMs have to be
checked whether the changes took effect or the whole infrastructure should
be rebooted.

## Finish definitions for all `depository-role` items ##

Add definitions for remaining items in `depository-role`:
* wether item is validated or not in the `depository-role`;
* path within `depository-role`;
* hash;
* basename;
* etc.

## Find a command line way to optimize Windows for performance ##

There is a way to disable all visual effects (Computer -> Properties ->
Advanced System Settings -> Advanced -> Performance properties).

Do it by command line.

NOTE: "smoothing the edges of fonts" should be left. Otherwise Sikuli
      will fail.
No way to set it automatically was found. But at least a way to
validate it. Cygwin accesses registry as a file system. The registry
key should contain 2 (not 0):
   '/proc/HKEY_CURRENT_USER/Control Panel/Desktop/FontSmoothing'

## Add command line way to set proper taskbar on Windows ##

There are at lest two settins:
* "Auto-hide the taskbar"
* "Use small icons"
* "Do not hide tray icons"

## Find a command line way to set default folder view in Windows ##

* Do not hide extensions of know types.
* Do not hide special directories.
* Do not hide anything, except system _hidden_ files.

## Find a comman line way to ensure PATH especially on Windows ##

PATH value can become a mess on Windows.
A way to enforce required PATH is important.

This can be done by a single line script. Search for `setx` in the states
for `*.bat` files which arleady use it.

## Find a command line way to reduce PATH and remove uplicates ##

PATH on Windows tends to contain duplicate locations.
This can become a problem after PATH variable exceeds (guess) 1024 characters.
Long PATH cannot be updated by `setx` anymore.

UPDATE: It seems that `setx -m` can actually work without limit. At least
        many SLSes use it at the moment. Is limit still a problem?

## Packages to VMs ##

INSTALL:

gpm
    Mouse server for console.
spice-vdagent
    Enhanced integration with SPICE viewer.
telnet
    Telnet client just in case.

## Add automatic installation of SPICE Guest Tools on Windows ##

Windows VMs does not have clipboard integration and cannot be provided
with additional screens/displays/heads.

## Disable all virtual networks except one to use single dnsmasq ##

Undefine / disable any other networks managed through libvirtd/dnsmasq.

There were a history of surprized DNS name resolutions to different IP
addresses of VMs staying on the same network using the same(!) DNS server.
Or some of them couldnt' get DHCP reply while others could. It all seemed
like some VMs were answerded by different simultaneously running dnsmasq.

## WARNING: Make sure correct slash is used in paths ##

Check template expressions, for example, like these:
 {{ pillar['system_hosts'][grains['os']]['primary_user']['user_home_dir'] }}/whatever
Make sure that for forward slash is used for Linux and backslash is used for Windows.

## VirtIO drivers for Windows storage ##

Exact names of virtio drivers for networking and storage:
* Network:
    "Red Hat VirtIO Ethernet Adapter (D:\WIN7\AMD64\NETKVM.INF)"
* Storage:
    "Red Hat VirtIO SCSI controller (D:\WIN7\AMD64\VIOSTOR.INF)"

## Add installation of BgInfo ##

See:
  http://technet.microsoft.com/en-sg/sysinternals/bb897557.aspx

In fact, alternative software called "DesktopInfo" seems even better because
it saves configuration into text-based `*.ini` file (rather thay binary as
BgInfo does).
  http://www.glenn.delahoy.com/software/
Direct download link:
  http://www.glenn.delahoy.com/software/files/DesktopInfo140.zip

## Install TortoiseSVN ##

Make sure TortoiseSVN is synced in versions with Cygwin svn.
Otherwise there is a problem of directory format which just makes
one application (Cygwin svn or TortoiseSVN) useless.

## Create system role "Developer Host" ##

This is the machine which is supposed to be automatically configured with
all required software for development rather than pushing these tools
to every host.

## Duplicate Linux environment on Cygwin ##

All shell environment and script installation for Linux should also
be duplicated for Cygwin:
  * Shell settings: variables, aliases, etc.
  * Scripts: i.e. content of package with project_name-specific automation, etc.

## NOTE: Problem for Windows/Cygwin paths ##

There are difficulties when execution of Salt state uses some Cygwin scripts
on Windows.

EXAMPLE

If a file deployed by Salt state on Windows minion, it uses
Windows-style path like:
```
C:\whatever
```
Then the state uses a script referring to this path via Cygwin:
```
/cygdrive/c/whatever
```
Salt can only use Linux or Windows paths (it does not understand Cygwin
paths). The problem is to keep the same location on the disk expressed
in various paths depending on whether Windows or Cygwin uses it.

## Add time synchronization for minions (NTP) ##

There should be a role of Time server (Linux only, normally provided by
`hypervisor-role`) and role of Time client (all other hosts: Linux and Windows).

Find a command line way to configure Windows NTP client.
See this:
  http://defaultreasoning.com/2009/11/16/synchronize-time-with-external-ntp-server-on-windows-server-2008-r2/

## Extend time zone settings on Windows ##

For example, all hosts use the same time zone (i.e. Asia/Singapore).

UPDATE: There ia already SLS for Linux (but unlikely for Windows) at the moment.

## Add generic `depository-role` content validation ##

Profile descriptor contains neccessary information to run
achiver content validation in single generic state (rather than creating
separate states manually).

## Change Windows hostname persistently ##

A Windows VM may be a clone of another VM (where system was installed
using different hostname).

There should be a command line way to set new hostname (depending on
Salt minion configuration):
  http://stackoverflow.com/questions/54989/change-windows-hostname-from-command-line

## Monitor annoying Salt bugs and provide walkaround ##

### `__salt__` is not defined ###

Currently, there is only one which happens (so far) on Windows:
* https://github.com/saltstack/salt/issues/10773
* `Unable to manage file: global name '__salt__' is not defined`
Restart of Salt minion on Windows helped to avoid it.

### lost minion connection ###

Another problem (which seemingly happens sometimes) is lost of
connection between master and minion. In fact, minion warns about possible
problems by this error message in the log:
   2014-03-13 02:00:50,930 [salt.minion      ][WARNING ] You have a version of ZMQ less than ZMQ 3.2! There are known connection keep-alive issues with ZMQ < 3.2 which may result in loss of contact with minions. Please upgrade your ZMQ!
During running synchronous (blocking) `salt` command master sometimes simply
exists "successfully". It doesn't mean the job fails. It can be retreived
by `salt-run jobs.lookup_jid"` command. But it feels wrong.
Even Fedora 20 only has ZMQ version 2.2.0:
  yum info zeromq
It seems like this is the issue discussed on GitHub:
  * Salt Minion keepalive is not valid in CentOS 5
      https://github.com/saltstack/salt/issues/4440
  * Host ZMQ3 RPM on repos.saltstack.org
      https://github.com/saltstack/salt/issues/5318

However, `salt` exiging without waiting for job completion might be not
an issue at all and simply a feature. Check `--timeout` option for `salt`.
Increasing timeout may guarantee that all `salt` waits until everything is done.

## Home and End keys in tmux ##

Sometime Home and End keys do not work in `tmux`.

Initially, it seemed to be TERM env var problem. However, they may not work
in two different windows of the same `tmux` session with the same TERM value.
A somewhat throught description of the problem is here:
  https://wiki.archlinux.org/index.php/Home_and_End_keys_not_working

# [footer] #

[todo_dir]: docs/todo
