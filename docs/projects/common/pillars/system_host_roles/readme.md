
Dictionary `system_host_roles` _emulates_ role-based configuration for hosts
defined in [system_hosts](docs/projects/common/pillars/system_hosts/readme.md) dictionary.

The key in this dictionary is a role name.

The value of this dictionary contains single key [assigned_hosts](docs/projects/common/pillars/system_hosts/assigned_hosts/readme.md)
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

Role name should always be postfixed with `_role` to make it clear that this id is a role (and not a minion id, for example).

Configuration of the role under `system_host_roles` is supposed to have a single sub-key `assigned_hosts` and _nothing_ else.
All additional configuration should go under [system_features](docs/projects/common/pillars/system_features/readme.md).

## Existing roles ##

* [jenkins_master_role](docs/projects/common/pillars/system_host_roles/jenkins_master_role/readme.md)

