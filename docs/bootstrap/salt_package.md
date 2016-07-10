
## Intro ##

In order for bootstrap package to work, it has to contain Salt with all
its dependencies for every target platform, for example,
all necessary RPMs pre-downloaded.

At the moment all such archived Salt and its dependencies pre-downloaded
for each supported platform are registered [this pillar file][1].
For example:

*   `rhel5` resource ids:

    *   `salt_downloaded_rpms_with_dependencies_2015.5.3-4.el5.x86_64.tar`
    *   `salt-master-2015.5.3-4.noarch.el5.rpm`
    *   `salt-minion-2015.5.3-4.noarch.el5.rpm`

*   `rhel7` resource ids:

    *   `salt-minion_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64`
    *   `salt-master_downloaded_rpms_with_dependencies_2014.7.1-1.el7.x86_64`

The resource ids are specified as archives providing componentes
like `salt-master` or `salt-minion` in [this pillar file][2].

## How to update the archives? ##

*   Instantiate Vagrant boxes with clean OS images
    (as minimum configuration as possible).

    For example:

    *   `rhel5`: `uvsmtid/centos-5.5-minimal`
    *   `rhel7`: `uvsmtid/centos-7.1-1503-gnome`

*   Log in as `root` in the newly instantiated VMs.

*   Make sure package manager can download packages without installing them.

    See this for details: https://access.redhat.com/solutions/10154

    *   `rhel5`

        ```
        sudo yum install yum-downloadonly
        ```

    *   `rhel7`

        The necessary download functionality is provided by `yum` by default.

*   Configure and enable required repositories - see [official Salt repos][3].

    *   `rhel5`

        Create file `/etc/yum.repos.d/salt.repo`:

        ```
        [salt]
        name=salt
        baseurl=https://repo.saltstack.com/yum/redhat/5/x86_64/2015.5/
        gpgcheck=1
        enabled=1
        gpgkey=https://repo.saltstack.com/yum/redhat/5/x86_64/2015.5/SALTSTACK-EL5-GPG-KEY.pub
        ```

    *   `rhel7`:

        Create file `/etc/yum.repos.d/salt.repo`:

        ```
        [salt]
        name=salt
        baseurl=https://repo.saltstack.com/yum/redhat/7/x86_64/2015.5/
        gpgcheck=1
        enabled=1
        gpgkey=https://repo.saltstack.com/yum/redhat/7/x86_64/2015.5/SALTSTACK-GPG-KEY.pub
        ```

*   Download packages and their dependencies.

    *   `rhel5`

        ```
        sudo yum install --downloadonly --downloaddir=salt.rpms/ salt
        sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
        sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
        ```

    *   `rhel7`

        ```
        sudo yum install --downloadonly --downloaddir=salt.rpms/ salt
        sudo yum install --downloadonly --downloaddir=salt-master.rpms/ salt-master
        sudo yum install --downloadonly --downloaddir=salt-minion.rpms/ salt-minion
        ```

*   Archive pre-downloaded content.

    Notice that there can be lists of files common to
    both `salt-master` and `salt-minion`:

    ```
    md5sum salt-master.rpms/* | sed 's/salt-master.rpms//g' | sort > salt-master.rpms.md5sum.txt
    md5sum salt-minion.rpms/* | sed 's/salt-minion.rpms//g' | sort > salt-minion.rpms.md5sum.txt
    md5sum salt.rpms/*        | sed 's/salt.rpms//g'        | sort > salt.rpms.md5sum.txt

    diff salt-master.rpms.md5sum.txt salt-minion.rpms.md5sum.txt
    diff salt.rpms.md5sum.txt        salt-master.rpms.md5sum.txt
    diff salt.rpms.md5sum.txt        salt-minion.rpms.md5sum.txt
    ```

    It makes sense to archive
    common part separately. For example, specifically for `rhel5`
    dependencies downloaded for `salt` are exactly the same as
    dependencies downloaded for both `salt-minion` and `salt-master`.
    In fact, the only difference of `salt-minion` and `salt-master` from
    dependencies for `salt` RPM package are the corresponding
    `salt-minion` and `salt-master` RPM packages. Therefore,
    archiving single RPM packages for `salt-minion` and `salt-master` is
    not even necessary - they can be registered in resources as is.

    *   `rhel5`

        ```
        cd salt.rpms/
        tar -cvf ../salt-rpms-[VERSION].tar *
        ```

    *   `rhel7`

        ```
        cd salt.rpms/
        tar -cvf ../salt-rpms-[VERSION].tar *
        ```

*   Update [resource file][1].

*   Update [bootstrap components file][2].

---

[1]: /pillars/profile/bootstrap/system_resources/salt.sls
[2]: /pillars/profile/bootstrap/system_features/static_bootstrap_configuration.sls
[3]: https://repo.saltstack.com/#rhel

