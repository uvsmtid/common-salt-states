
Field `dns_server_type` can have two string values:

*   `managed`

    This means that DNS server is configured on `hostname_resolver_role`.

    This, in turn, means that DNS settings for all hosts will point
    to `hostname_resolver_role` instead of DNS server specified in
    [external_dns_server][1] parameter.

    Note that `hostname_resolver_role` is still normally configured to forward
    DNS requests for other zones to `external_dns_server`.

*   `external`

    This means that DNS settings for all hosts will point to server
    specified in [external_dns_server][1] parameter.

[1]: /docs/pillars/common/system_features/hostname_resolution_config/external_dns_server/readme.md

