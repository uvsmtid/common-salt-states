
TODO: Finish transition from Salt config file parameters to properties.
      See [properties.yaml][1].

*   Update documentation. Move config-related parameters to properties.
*   Use only one of two `*bootstrap_target_envs`.
    
    *   `load_bootstrap_target_envs`
    *   `bootstrap_target_envs`

    They were needed when pillars were not able to be parameterized
    without master restart. Now it is possible through properties.

*   Create a list of frequently changed parameters to be set through
    profiles: IP addresses, virtualization, platform, etc.

[1]: pillars/profile/properties.yaml

