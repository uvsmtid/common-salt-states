# -*- mode: ruby -*-
# vi: set ft=ruby :

# Define properties (they are loaded as values to the root of pillars):
{% set props = pillar %}

# Include other macros.
{% set resources_macro_lib = 'common/system_secrets/lib.sls' %}
{% from resources_macro_lib import get_single_line_system_secret with context %}

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# This is the only known way to force default provider to `libvirt`
# avoiding the "smart" default provider selection process (which chooses
# `virtualbox`, if it is installed):
#   https://www.vagrantup.com/docs/providers/basic_usage.html#default-provider
# See also:
#   http://stackoverflow.com/a/21843623/441652
{% set vagrant_provider = pillar['system_features']['vagrant_configuration']['vagrant_provider'] %}
ENV['VAGRANT_DEFAULT_PROVIDER'] = '{{ vagrant_provider }}'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "base"

  # Based on Vagrant explanation, in the future they may support provider
  # per each VM. At the moment, it should only be configured per all
  # set of VMs (outside of individual configuration).
  # In other words, in theory (multiple Vagrantfile-s were never tested
  # together on the same machine), there is single provided for all boxes
  # per Vagrantfile. In practice (as currently implemented with
  # single Vagrant file) entire system defined through Salt
  # must use the same Vagrant provider.
  # As of Vagrant 1.7+, there is smart process selecting default provider:
  #   https://www.vagrantup.com/docs/providers/basic_usage.html#default-provider
  # It is so "smart" that it now selects `virtualbox` provider
  # ignoring even the setting below (if `virtualbox` is installed).
  # So, the only way to force provider (without typing `--provider`)
  # is to set `VAGRANT_DEFAULT_PROVIDER` environment variable (see above).
  config.vm.provider "{{ vagrant_provider }}"
  config.vm.provider :{{ vagrant_provider }} do |{{ vagrant_provider }}|

      {% if vagrant_provider == 'libvirt' %}
      # In case of `libvirt`, specify `qxl` graphics card type.
      # This graphics supports multiple monitors for VM and better resolution.
      {{ vagrant_provider }}.video_type = 'qxl'
      {% endif %}

  end

  # Without this line it fails when proxy is used to access Internet and
  # SSL certificates break somehow:
  config.vm.box_download_insecure = true

{% from 'common/libs/host_config_queries.sls' import get_host_id_by_role with context %}

{% if False %}
  # NOTE: This does not set IP address for physical host machine.
  #       Instead, Vagrant treats this as some sort of "global" config
  #       and assigns this IP as additional to the first virtual host.
{% set hypervisor_host_id = pillar['system_host_roles']['virtual_machine_hypervisor_role']['assigned_hosts'][0] %}
  config.vm.network "public_network", ip: "{{ pillar['system_hosts'][hypervisor_host_id]['hosts_networks'][sys_net_name]['ip'] }}"
{% endif %}

{% set project_name = pillar['project_name'] %}
{% set profile_name = pillar['profile_name'] %}

{% set bootstrap_dir_basename = pillar['system_features']['static_bootstrap_configuration']['bootstrap_files_dir'] %}

{% for selected_host_name in pillar['system_hosts'].keys() %}

{% set selected_host = pillar['system_hosts'][selected_host_name] %}

{% if selected_host['instantiated_by'] %}

{% set os_type = pillar['system_platforms'][ selected_host['os_platform'] ]['os_type'] %}
{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}
{% set network_resolved_in = selected_host['resolved_in'] %}
{% set network_config = pillar['system_networks'][network_resolved_in] %}

{% if vagrant_provider == instance_configuration['vagrant_provider'] %} # match provider
{% else %} # match provider
# Provider per machine instance should match globally selected one.
{{ THIS_VARIABLE_DOES_NOT_EXISTS_vagrant_provider_does_not_match }}
{% endif %} # match provider

# Docker requires special configuration.
{% if instance_configuration['vagrant_provider'] == 'docker' %} # vagrant_provider

  config.vm.define "{{ selected_host_name }}" do |{{ selected_host_name }}|
    {{ selected_host_name }}.vm.provider "{{ instance_configuration['vagrant_provider'] }}" do |d|
      d.build_dir = "{{ selected_host_name }}"
      d.cmd = [ "sleep", "60" ]
    end
  end

{% else %} # vagrant_provider

# Common part for all non-docker providers.

  config.vm.define "{{ selected_host_name }}" do |{{ selected_host_name }}|

    {{ selected_host_name }}.vm.box = "{{ instance_configuration['base_image'] }}"
    {% if props['use_local_vagrant_box_publisher'] %}
    # The URL is set to system-local server.
    # NOTE: In this case, it is also likely that `vagrant` command
    #       should be executed with undefined
    #       `http_proxy` and `https_proxy` environment variables.
    {{ selected_host_name }}.vm.box_url = 'http://{{ pillar['system_host_roles']['vagrant_box_publisher_role']['hostname'] }}/{{ instance_configuration['base_image'] }}.json'
    {% endif %}

    # See libvirt configuration:
    #   https://github.com/pradels/vagrant-libvirt
    {{ selected_host_name }}.vm.provider :{{ instance_configuration['vagrant_provider'] }} do |{{ selected_host_name }}_domain|
        {% for domain_property_name in instance_configuration['domain_config'].keys() %}
        {{ selected_host_name }}_domain.{{ domain_property_name }} = '{{ instance_configuration['domain_config'][domain_property_name] }}'
        {% endfor %}
    end

    {% set vagrant_bootstrap_use_case = pillar['system_features']['vagrant_configuration']['vagrant_bootstrap_use_case'] %}

    # TODO: It doesn't seem right that package type (archive type)
    #       depends on any platform. What if there are multiple
    #       platforms within a system, will there be multiple packages?
    #       The whole idea about bootstrap is to have single package
    #       per system instance.
    {% set default_bootstrap_cmd = 'echo WARNING: No bootstrap package provided.' %}
    {% set package_type = pillar['system_features']['static_bootstrap_configuration']['os_platform_package_types'][pillar['system_hosts'][selected_host_name]['os_platform']] %}
    {% if not pillar['system_features']['source_bootstrap_configuration']['generate_packages'] %} # generate_packages
    {% set src_sync_dir = bootstrap_dir_basename + '/targets/' + project_name + '/' + profile_name %}
    {% set boostrap_cmd = 'python /vagrant/' + bootstrap_dir_basename + '/bootstrap.py deploy ' + vagrant_bootstrap_use_case + ' conf/' + project_name + '/' + profile_name + '/' + selected_host_name + '.py' %}
    {% else %} # generate_packages
    {% set src_sync_dir = bootstrap_dir_basename + '/packages/' + project_name + '/' + profile_name %}
    {% if not package_type %} # package_type
    {% set boostrap_cmd = default_bootstrap_cmd %}
    {% elif package_type == 'tar.gz' %} # package_type
    {% set boostrap_cmd = 'tar -xzvf /vagrant/' + bootstrap_dir_basename + '/salt-auto-install.' + package_type + ' --directory=/vagrant/' + bootstrap_dir_basename + '/ ; python /vagrant/' + bootstrap_dir_basename + '/bootstrap.py deploy ' + vagrant_bootstrap_use_case + ' conf/' + project_name + '/' + profile_name + '/' + selected_host_name + '.py' %}
    {% else %} # package_type
    {% set boostrap_cmd = default_bootstrap_cmd %}
    {% endif %} # package_type
    {% endif %} # generate_packages

    {{ selected_host_name }}.vm.provision "shell", inline: "{{ boostrap_cmd }}"

    # NOTE: `rsync` is not available on Windows by default.
    {% if os_type != "windows" %}
    # Use `rsync` for synced folder.
    # Parameter `--copy-unsafe-links` is required for bootstrap directory
    # which might be a symlink.
    {{ selected_host_name }}.vm.synced_folder '{{ src_sync_dir }}/', '/vagrant/{{ bootstrap_dir_basename }}/', type: 'rsync',
        rsync__args: [
            "--verbose",
            "--archive",
            "--delete",
            "--copy-unsafe-links",
        ]
    {% endif %}

    # Disable default sync folder.
    {{ selected_host_name }}.vm.synced_folder '.', '/vagrant', disabled: true

    # Based on Vagrant explanation, in the future they may support provider
    # per each VM. At the moment, it should only be configured per all
    # set of VMs (outside of individual configuration).
    #{{ selected_host_name }}.vm.provider = "{{ instance_configuration['vagrant_provider'] }}"

    # NOTE: SSH is not available on Windows by default.
    #       Setting specific Vagrant communicator (e.g. `ssh`, `winrm`, etc.).
    {% set communicator_type = instance_configuration['vagrant_communicator']['communicator_type'] %}
    {{ selected_host_name }}.vm.communicator = "{{ communicator_type }}"
    {% if 'password_secret_id' in instance_configuration['vagrant_communicator'] %}
    {{ selected_host_name }}.{{ communicator_type }}.password = "{{ get_single_line_system_secret(instance_configuration['vagrant_communicator']['password_secret_id']) }}"
    {% endif %}
    # Loop through keys ignoring those which are processed differently.
    {% for communicator_param in instance_configuration['vagrant_communicator'].keys() %}
    {% if communicator_param not in [
            'password_secret_id',
            'communicator_type',
        ]
    %}
    {{ selected_host_name }}.{{ communicator_type }}.{{ communicator_param }} = "{{ instance_configuration['vagrant_communicator'][communicator_param] }}"
    {% endif %}
    {% endfor %}

{% for vagrant_net_name in pillar['system_features']['vagrant_configuration']['vagrant_networks'].keys() %} # vagrant_networks
# Vagrant configuration maps `vagrant_net_name` into system net name via `system_network`.
{% set vagrant_net_conf = pillar['system_features']['vagrant_configuration']['vagrant_networks'][vagrant_net_name] %}
{% set sys_net_name = vagrant_net_conf['system_network'] %}
{% set sys_net_conf = pillar['system_networks'][sys_net_name] %}
{% if vagrant_net_conf['enabled'] %} # enabled

# NOTE: If host does not list this network,
#       the network will silently be omitted.
{% if sys_net_name in selected_host['host_networks'] %} # host_networks
    {{ selected_host_name }}.vm.network :{{ vagrant_net_conf['vagrant_net_type'] }},

        {% if instance_configuration['vagrant_provider'] == 'libvirt' %}
        :libvirt__network_name => '{{ vagrant_net_name }}',
        {% endif %}

        {% if instance_configuration['vagrant_provider'] == 'virtualbox' %}
        :virtualbox__intnet => '{{ vagrant_net_name }}',
        {% endif %}

        :ip => '{{ selected_host['host_networks'][sys_net_name]['ip'] }}',

        {% if 'mac' in selected_host['host_networks'][sys_net_name] %}
        # NOTE: Use lowercase due to current issue with Vagrant explained her:
        #           https://github.com/vagrant-libvirt/vagrant-libvirt/issues/312#issuecomment-229963533
        :mac => '{{ selected_host['host_networks'][sys_net_name]['mac']|lower }}',
        {% endif %}

        # TODO: How to configure netmask on `virtualbox`?
        {% if instance_configuration['vagrant_provider'] == 'libvirt' %}
        :libvirt__netmask => '{{ sys_net_conf['netmask'] }}',
        {% endif %}

        {% if vagrant_net_conf['vagrant_net_type'] == 'public_network' %} # vagrant_net_type

        # TODO: Isn't it possible to use `bridge:` parameter for `libvirt`
        #       just like for `virtualbox`?
        {% if instance_configuration['vagrant_provider'] == 'libvirt' %}
        :dev => '{{ vagrant_net_conf['host_bridge_interface'] }}',
        {% endif %}

        {% if instance_configuration['vagrant_provider'] == 'virtualbox' %}
        :bridge => '{{ vagrant_net_conf['host_bridge_interface'] }}',
        {% endif %}

        :mode => 'bridge',

        {% elif vagrant_net_conf['vagrant_net_type'] == 'private_network' %} # vagrant_net_type

        :libvirt__forward_mode => 'nat',

        {% else %} # vagrant_net_type

        {{ FAIL_unknown_vagrant_net_type }}

        {% endif %} # vagrant_net_type

        # Use DHCP to offer addresses to avoid too long initialization
        # of network interfaces during first boot (before static IP is
        # configured by Vagrant).
        # NOTE: At the time of coding IP range for DHCP server was not
        #       configurable. So, we hope that there will be no conflicts
        #       with IP addresses assigned statically.
        {% if vagrant_net_conf['enable_dhcp'] %}
        :libvirt__dhcp_enabled => true,
        {% else %}
        :libvirt__dhcp_enabled => false,
        {% endif %}

        :whatever => true

{% endif %} # host_networks

{% endif %} # enabled

{% endfor %} # vagrant_networks

  end

{% endif %} # vagrant_provider

{% endif %} # instantiated_by

{% endfor %} # selected_host_name

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with CFEngine. CFEngine Community packages are
  # automatically installed. For example, configure the host as a
  # policy server and optionally a policy file to run:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.am_policy_hub = true
  #   # cf.run_file = "motd.cf"
  # end
  #
  # You can also configure and bootstrap a client to an existing
  # policy server:
  #
  # config.vm.provision "cfengine" do |cf|
  #   cf.policy_server_address = "10.0.2.15"
  # end

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file default.pp in the manifests_path directory.
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "default.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision "chef_solo" do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { mysql_password: "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
