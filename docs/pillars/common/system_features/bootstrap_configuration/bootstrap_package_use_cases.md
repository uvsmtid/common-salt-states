
The value of `bootstrap_package_use_cases` key specifies bootstrap
use cases which bootstrap package should be built for:
*   `initial-online-node`
*   `offline-minion-installer`

See also:
*   [bootstrap documentation][1] for description of the use cases.
*   [bootstrap_use_cases][2] key for content items which specify
    whether bootstrap package should include it or not.

TODO: At the moment this option does not affect anything.
It should work together with [bootstrap_use_cases][2] to tailor bootstrap
package for specific use case.

[1]: docs/bootstrap.md
[2]: docs/pillars/common/registered_content_items/_id/bootstrap_use_cases.md

