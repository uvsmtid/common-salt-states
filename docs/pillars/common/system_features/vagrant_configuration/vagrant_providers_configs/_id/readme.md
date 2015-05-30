
The `id` to [vagrant_providers_configs][1] is a name of specific
vagrant provider.

Provider configuration under each `id` is only effective if this `id` matches
currently selected [vagrant provider][2].

The following vagrant providers can be configured:
* `libvirt` - most frequently used and tested (requires Linux);
* `virtualbox` - default for Vagrant;
* `docker` - deprecated, see [www.boycottdocker.org][3];
* ...

[1]: /docs/pillars/common/system_features/vagrant_configuration/vagrant_providers_configs/readme.md
[2]: /docs/pillars/common/system_features/vagrant_configuration/vagrant_provider/readme.md
[3]: http://www.boycottdocker.org/

