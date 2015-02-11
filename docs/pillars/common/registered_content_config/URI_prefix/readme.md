
Key `URI_prefix` defines root (or base) for location of all content items
listed under [registered_content_items][].

For example, if `URI_prefix` is `http://some_file_server/depository/`
than entries inside `registered_content_items` are looked up under this URI.

## Possible values ##

Character `~` designates NULL (or null) in YAML. It means that prefix is
undefined and states may use their defaults.

Anything else specifies string URI prefix. The string is not interpreted
anyhow. It is used in concatenation with item's path components. If full
URI resulted in invalid location, state using this value will simply fail.

Example of valid (but possibly unavailable) `URI_prefix` values:
* `http://some_file_server`
* `salt://source_roots/common-salt-states/resources/project_name`

NOTE: There is no trailing slash at the end of the value for `URI_prefix`.

[registered_content_items]: docs/pillars/common/registered_content_items/readme.md

