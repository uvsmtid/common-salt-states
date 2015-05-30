
Key `resolved_in` selects one of the network where particular host is defined.

For example, one of the important consequences is hostname resolution
(regardless of [hostname resolution type][1]):
* Host may have more than one IP address.
* The IP address which hostname is resolved to will be selected from
  the network provided in `resolved_in` value.

[1]: /docs/pillars/common/system_features/hostname_resolution_config/hostname_resolution_type/readme.md

