TODO

# Requirements #

* TODO: Split common project_name and other project_names
        into separate git repositories.

  However, in order to make them plugable to with each other, there are
  several requirements to fulfil:
  * If a project_name is plugged in, there is no need to change any of its sources.
    The only thing which could be done is changed Salt configuration file.
  * Links in documentation should be valid (browsable) through project_names
    repositories (i.e. on GitLab).
  * Pillar should be automatically accessible if Salt configuration file
    indicates that this project_name is plugged in.
  * The `/srv/pillars` and `/srv/states` should only be symlinked to
    the `common` repository. A project_name is plugged in by adding symlinks
    from within `common` repository to the plugged project_name.
  * The best part whould be ability to put entire source code of
    plugable repository under single directory of `common` repository
    so that they can be developed as single entity via Git submodules.

* TODO: There should be a script to run which automatcailly adjusts symlinks
  to plugable project_name repository within `common` repository, for example:
  ```
  scripts/plug_project_repo.sh project_name /abs/path/to/project_name/repo
  ```

* TODO: There should be a script to run on salt master to make sure that all
  minions listed in `salt-key` (or accessed through `salt '*' test.ping) are
  actually defined in the project_name `system_hosts`.

*   DONE: There could be a mechanisim defeloped which allows Salt master to
    automatically accept minions defined in specific project_name.
    Whether minions can spoof it or not - this is another question.
    At the moment no spoof-proof authentication needs to be done - just
    automate.
    See: http://docs.saltstack.com/en/latest/ref/configuration/master.html#auto-accept

# Proposal #

Plug in project_names as additional entry in `file_roots` in Salt config.

At the moment there are two entries: for main sources pointing to
salt states (`states`) and addditional pointing to source code repositories
which may be used in setup (`sources`).
```
file_roots:
    base:
        - /srv/states
        - /srv/sources
        - /srv/resources
```
What if remove `/srv/sources` and rename `/srv/states` to `/srv/artifacts`?
We can generalize management of "project_names", "sources" and "resources".
All of them are managed under the same pillar key (i.e.) named
`artifacts_configuration`. For the moment let's leave
"sources" and "resources".

## Mechanics ##

Let's say project_name `common` is represented as the following symlink:
```
/srv/artifacts/common => /path/to/repository/common.git/states/common
```
Such symlinks are automatically created based keys under
`artifacts_configuration`.

Note how the path from repository root is `states/common` - this is current
path for all `common` states.
All other project_names are simply represented by a similar symlink:
```
/srv/artifacts/project_A => /path/to/repository/project_A.git/states/project_A
```

## Renames ##

This even allows several project_name to be under the same root (for example,
until they are split):
```
/srv/artifacts/project_B => /path/to/repository/project_A.git/states/project_B
```
It's also possible to represent all states in the `project_A` as `project_C`
```
/srv/artifacts/project_C => /path/to/repository/project_A.git/states/project_A
```

## Renames are possible but discauraged ##

If the name of the symlink under `/srv/artifacts` directory corresponds to
the project_name, it obvious that no changes required to the references:
```
common.git => "/srv/artifacts"/"common"/"git" => ...
"/path/to/repository/common.git/states/common"/"git"/init.sls
```
In fact, renames should not be used. They only create confusion. They will
also break if `project_A.state_x` reference within the same renamed `project_A`
point to this same project_name - reference will be broken because the project
is renamed into `project_B`.

## Other artifacts ##

Now let's come back to other types of artifacts: "sources" and "resources".

In fact, "project_name" is just a "source" artifact without no additional
meaning to this framework. Only the fact that there can be some Salt states
makes it a "project_name", but requires no additional implementation for
the framework as long as "sources" are well managed.

The "resources" are actually just another `type` of artifacts. And just
like with "project_names", if all supported types of artifacts are managed well,
there is no difference.

In other words, all "project_names", "sources" and "resources" are managed by
abstract concept of "artifacts".

## Conclusion ##

Let's review how we met requirements:
* MET: System state can be split into multiple repositories depending on
  the project_name.
* MET: If a project_name is plugged in, there is no need to change any
  of its sources. The only thing which could be done is changed Salt
  configuration file.
  * Even configuration file does not need to be changed - there is a static
    reference to `/srv/artifacts`.
* MET: Links in documentation should be valid (browsable) through project_names
  repositories (i.e. on GitLab).
  * If project_names do not change current structure, and named correspondingly,
    the links won't be broken.
* MET: Pillar should be automatically accessible if Salt configuration file
  indicates that this project_name is plugged in.
  * This simply requires the same approach for `pillar_roots`:
    ```
    /srv/pillars/common => path/to/repository/common.git/pillars/common
    ```
* MET: The `/srv/pillars` and `/srv/states` should only be symlinked to
  the `common` repository. A project_name is plugged in by adding symlinks
  from within `common` repository to the plugged project_name.
  * But why is this important? It's important only to use single directory
    for all changes in all plugged in project_names.
    But it is still possible to add symlinks (i.e.) from `common` to
    `project_A` like this symlink:
    ```
    /path/to/repository/common.git/states/project_A => /path/to/repository/project_A.git/states/project_A
    ```
    The intent behind requirement is met.
* MET: The best part whould be ability to put entire source code of
  plugable repository under single directory of `common` repository.
  * Already discussed above.

# Q&A #

## How to add a project_name? ##

Entire framework works with "namespaces".

Configuration of `*_roots` in Salt only includes:
```
file_roots:
  /srv/states
pillar_roots:
  /srv/pillars
```
Each additional project_name is connected as a "namespace" symlink named after
the project_name:
```
/srv/states/project_A -> /path/to/project_A/states/project_A
/srv/pillars/project_A -> /path/to/project_B/pillars/project_A
```

## How both syscore and project_name states are integrated? ##

The main top states file must be accessible as:
```
/srv/states/top.sls
```
However, separate project_names have their own "top" states accessible as:
```
/srv/states/project_A/top.sls
```

That's why there will be one symlink for the main top file and one symlink
for each connected namespace:
```
/srv/states/top.sls -> /path/to/syscore.git/states/top.sls
/srv/states/syscore -> /path/to/syscore.git/states/syscore
/srv/states/project_A -> /path/to/project_A.git/states/project_A
```

## How both syscore and project_name pillars are integrated? ##

The main top pillar file must be accessible as:
```
/srv/pillars/top.sls
```
However, separate project_names have their own "top" pillars accessible as:
```
/srv/pillars/project_A/top.sls
```

That's why there will be one symlink for the main top file and one symlink
for each connected namespace:
```
/srv/pillars/top.sls -> /path/to/syscore.git/pillars/top.sls
/srv/pillars/syscore -> /path/to/syscore.git/pillars/syscore
/srv/pillars/project_A -> /path/to/project_A.git/pillars/project_A
```

Main top file load top pillar file of the project_name (among other files required
for bootstrap and multi-project_name framework).

## How will bootstrap work? ##

Bootstrap is only required to setup Salt and the framework (with multiple
project_names). There is no impact of multiple project_names on bootstrap.

TODO: For bootstrap, there are some pillars which are templates, some
are not. And there are many of them, not one anymore. So, there should
be a definition which pillar data whould be written into which file.
Otherwise how these pillars will get loaded if they are all merged in
one file and other files do not exist (not found)?

TODO: Maybe pillar rewrite shouldn't be the case during bootstrap?
Maybe it can all be managed through boostrap mode Salt config?

## How will orchestrate work? ##

Orchestrate will work because states will be available.

# [footer] #

