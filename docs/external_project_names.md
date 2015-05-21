

# Intro #

Common Salt state set a framework for
common configuration and deployment problems (hence `common-salt-states`).

project_name-specific Salt states with solutions for particular domain are not
supposed to be put in the same repository. Instead, these project_name-specific
solutions should be managed as external project_name.

Deployment-specific Salt pillars provide configuration data for both
common Salt states and project_name-specific Salt states.

The main problem is how to make all these available to Salt:
*   common Salt states
*   project_name-specific Salt states
*   deployment-specific Salt pillars

And in addition to providing it to Salt:
*   organize it clearly
*   make it easy to use

# Requirements #

TODO:
*   When `*` is specified for `salt` command, only minions participating
    in specific project_name deployment should be affected.
*   Common and project_name-specific Salt states should be in different namespace
    to co-exist together.

# Approaches #

Several approaches were tried:
* nodegroups - naming list of minions in master config to be used in targeting
* assignments - use special dict in master config to assign list of minions to specific project

## Identified issues ##

* If more than one project_name is listed under `this_system_keys`/`project_names`, some hosts (i.e. Salt master when `salt-run` is used) load conflicting pillar (containing the same top-level keys) from these project_names.
* Every time the configuration changes, Salt master has to be restarted to re-load it (because it is part of `/etc/salt/master`).
* In order to target all hosts from specific project_name, `*` cannot be used anymore. Instead, nodegroups should be configured which is a duplicate of what `this_system_keys`/`assignments` lists provide.
* The top file is shared for all project_names which clutters it and exposes details even for those who have nothing to do with this project_name.
* Salt master has to be listed under its unreliable hostname (sometimes FQDN, sometimes not) just for the sake of loading pillars when `salt-run` is used for orchestration. See also: https://github.com/saltstack/salt/issues/12451

## Options for improvement ##

NOTE: There are many ways to use Salt grains from minion side to split the state space per project_name. However, this is not convenient because minion grains are distributed configuration data, not centralized like Salt master config, top file, or pillar data. In fact, all this problems above appeared after configuration was moved into central place (requirement to centralize configuration is above all). See also: https://github.com/saltstack/salt/issues/12916

* Salt environments should probably solve some of the issues above. For example, environments allow setting priority for specific hosts where pillar or states are searched for.
* Using node groups (or any other ways instead of `*`) to target nodes is unavoidable because there is simply no other way for `salt` command to know which project_name your command is applied for. The problem is that `*` means all connected minions not filtered by any condition.
* How to avoid Salt master (when `salt-run` is used) from loading more than one (conflicting) pillar and yet loading at least one (because `orchestrate` runner needs pillar data like host assignments to roles)? The only way is to modify Salt master config (central place) to render all top files for specific project_name.

## Proposed actions to close this issue ##

* Use node groups only to select which node is assigned to which project_name. Do not need to duplicate this information in any custom config data.
* Use single variable `project_name` in Salt master to specify currently active project_name. The project_name name should match the node group name. Salt master custom config data is the only way to centrally configure template paramter which can be used in both top files (states and pillars).
* Forget about using `*` for targeting minion *anywhere* (including orchestration stages) - use only node groups. There is no way to make Salt avoid contacting minions (when `*` is used, minion must be online for the state to succeed even if it won't do anything).
* Forget about convenience of automatically re-loading config after changes. When node groups or `project_name` are changed, Salt master has to be re-started - there is no way out of it under current requirements.
* Do not wory about issue of loading conflicting pillars from different project_names anymore. It is solved because `project_name` variable renders pillars top files as required.

## Final turn ##

* The idea to use nodegroups was dropped. Instead, required minions should be
  listed by modifying list of accepted keys through `salt-key`.
* The idea to use multiple project_names were dropped either.
  If minions need to get states from other project_names, they can still be assigned
  these states as nothing prevents setup for one project_name call states from other.
* Targeting entire system of minions under the same project_name is done by `*`.
  In other words, whether minion is for the project_name or not is defined by
  connection to the master - simply check who is connected using `salt-key`.

For example, look at the current snippet from Salt master config file `/etc/salt/master`:
```
this_system_keys:
    project_name: {{ project_name }}
    profile_name: {{ profile_name }}
```


