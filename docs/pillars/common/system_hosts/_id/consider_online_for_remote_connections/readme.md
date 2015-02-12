
Key `consider_online_for_remote_connections` is used to specify whether this
host should be online in order to proceed with various deployment stages.

For example, if it is set to `False` deployment of SSH public key won't be
done for this host.

The need for such parameter becomes obvious when there are many _external_
hosts which should be automatically listed in hosts files or DNS records
whith their IP addresses provided in host's network settings. If they are
not managed hosts, they will not be seen as accepted by Salt master in
`salt-key` command output. However, this is not enough because some Salt
states may try to contact them over network and attempt push some
configuration (i.e over SSH like SSH public key). In order to avoid such
attempts, set `consider_online_for_remote_connections` to `False`.

Normally, if this host has running Salt minion and is connected to Salt master
(listed as accepted in `salt-key` output), it also specifies this parameter
as `True`. The opposite is not likely: the host may not be connected Salt
minion (it may not be managed by Salt master), but it may still be part of
the system and should be contacted over network. For example, it may be
required to deploy public SSH key on the external host.

## Limitations ##

TODO: This settings should probably be renamed into more specific like `deploy_public_ssh_key`.

At the moment, it is not clear what exactly it may imply. More over, it may be
the case that `consider_online_for_remote_connections` will be overloaded in
its usage so that clear separation is required, for example:
* `deploy_public_ssh_key`
* `push_some_content_over_the_network`

