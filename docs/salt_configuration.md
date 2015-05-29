
## Configure Salt ##

These sources provide a [framework][2] for automation for multiple projects.

However, the following steps result in installation of only framework itself
using sample configuration.

Option `file_roots` specifies location where Salt looks up file references
(including state files).

Option `pillar_roots` specifies location where Salt loads pillars.

Other parameters are framework-specific:
*   [`project_name`][9]
*   [`profile_name`][10]
*   [`master_minion_id`][11]
*   [`default_username`][12]

```
# ...
file_roots:
    base:
        # Conventionally, the following directory is a symlink pointing to
        # `/home/[username]/Works/common-salt-states.git/states`
        - /srv/states

        # The following directory is a common place for all additional
        # symlinks pointing to various source code repositories.
        # These symlinks are configured automatically by using
        # `common.source_symlinks` state - see below.
        - /srv/sources

        # A directory with symlinks to resources.
        - /srv/resources
# ...
pillar_roots:
    base:
        # Conventionally, the following directory is a symlink pointing to
        # `/home/[username]/Works/project_name-salt-states.git/pillars`
        - /srv/pillars
# ...
this_system_keys:
    # ...
    # Salt master orchestrates only one `project_name`:
    project_name: common
    # Profile can be named after the same host which is used as Salt master.
    profile_name: whatever
    # Specify id of the Salt minion which is collocated with Salt master. 
    master_minion_id: minion_id
    # Specify name of the user which is used by default.
    # This is the user which has `~/Works/common-salt-states.git` repository.
    default_username: username
    # ...
# ...
```

### Clone repositories ###

Clone repositories (if not done yet):

*   states

    ```
    git clone git@[hostname]:[username]/common-salt-states.git ~/Works/common-salt-states.git
    ```

*   resources

    ```
    git clone git@[hostname]:[username]/common-salt-resources.git ~/Works/common-salt-resources.git
    ```

*   pillars

    ```
    git clone git@[hostname]:[username]/common-salt-pillars.git ~/Works/common-salt-pillars.git
    ```

### Link repositories ###

Set up links to repositories so that Salt can use them:

*   states

    ```
    ln -sfn /home/[username]/Works/common-salt-states.git/states /srv/states
    ```

*   resources

    The resources are linked automatically later by Salt itself using `common.resource_symlink` state.

*   pillars

    ```
    ln -sfn /home/[username]/Works/common-salt-pillars.git/pillars /srv/pillars
    ```

# [footer] #

[1]: docs/bootstrap/readme.md
[2]: docs/framework.md
[3]: docs/orchestration.md
[4]: http://docs.saltstack.com/
[5]: https://github.com/uvsmtid/vagrant-boxes/tree/master/centos-5.5-minimal
[6]: http://docs.saltstack.com/en/latest/topics/installation/rhel.html
[7]: https://copr.fedoraproject.org/coprs/saltstack/salt-el5/
[8]: https://copr.fedoraproject.org/coprs/saltstack/salt-el5/repo/epel-5/saltstack-salt-el5-epel-5.repo
[9]: docs/configs/common/this_system_keys/project_name/readme.md
[10]: docs/configs/common/this_system_keys/profile_name/readme.md
[11]: docs/configs/common/this_system_keys/master_minion_id/readme.md
[12]: docs/configs/common/this_system_keys/default_username/readme.md
[13]: pillars
[14]: docs/salt_runtime.md

