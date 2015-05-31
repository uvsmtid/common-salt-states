
Dictionary `system_host_roles` _emulates_ role-based configuration for hosts
defined in [system_hosts][1] dictionary.

The key in this dictionary is a role name.

The value of this dictionary contains key [assigned_hosts][2]
which lists minion ids assigned to the corresponding role.

Example:

```yaml
system_host_roles:
    name_1_role:
        assigned_hosts:
            - minion_id_1
            # ...
            - minion_id_N
    # ...
    name_N_role:
        assigned_hosts:
            - minion_id_1
            # ...
            - minion_id_N
```

## Conventions ##

*   Role name should not contain any hyphens `-` as it may be used
    to generate code for scripts (and hyphens are not allowed for variable
    names in most of the programming languages).

*   Role name should always be postfixed with `_role` to make it clear
    that this id is a role (and not a minion id, for example).

*   In order to refer to hosts indirectly via their role name,
    additional [hostname][3] field should be set.
    The value of this field must not contain any _underscores_ `_`
    because DNS names cannot contain them.

## Existing roles ##

* [jenkins_master_role][4]

# [footer] #

[1]: /docs/pillars/common/system_hosts/readme.md
[2]: /docs/pillars/common/system_host_roles/_id/assigned_hosts/readme.md
[3]: /docs/pillars/common/system_host_roles/_id/hostname/readme.md
[4]: /docs/pillars/common/system_host_roles/jenkins_master_role/readme.md

