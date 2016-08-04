
TODO: `pillar['registered_content_config']['URI_prefix']` is not used anymore.

Key `URI_prefix` defines root (or base) for location of all content items
listed under [system_resources][].

For example, if `URI_prefix` is `http://some_file_server/depository/`
than entries inside `system_resources` are looked up under this URI.

## Possible values ##

Character `~` designates NULL (or null) in YAML. It means that prefix is
undefined and states may use hardcoded default values.

Anything else specifies string URI prefix. The string is not interpreted
anyhow. It is used in concatenation with item's path components. If full
URI resulted in invalid location, state using this value will simply fail.

Example of valid (but possibly unavailable) `URI_prefix` values:
* `http://some_file_server`
* `salt://source_roots/common-salt-states/resources/project_name`

NOTE: There is no trailing slash at the end of the value for `URI_prefix`.

[system_resources]: /docs/pillars/common/system_resources/readme.md

