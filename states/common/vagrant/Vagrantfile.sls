# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "base"

  # Based on Vagrant explanation, in the future they may support provider
  # per each VM. At the moment, it should only be configured per all
  # set of VMs (outside of individual configuration).
  config.vm.provider "{{ pillar['system_features']['vagrant_configuration']['vagrant_provider'] }}"

  # Without this line it fails when proxy is used to access Internet and
  # SSL certificates break somehow:
  config.vm.box_download_insecure = true

{% from 'common/libs/host_config_queries.sls' import get_host_id_by_role with context %}

{% if False %}
  # NOTE: This does not set IP address for physical host machine.
  #       Instead, Vagrant treats this as some sort of "global" config
  #       and assigns this IP as additional to the first virtual host.
{% set hypervisor_host_id = pillar['system_host_roles']['hypervisor_role']['assigned_hosts'][0] %}
  config.vm.network "public_network", ip: "{{ pillar['system_hosts'][hypervisor_host_id]['internal_net']['ip'] }}"
{% endif %}

{% set salt_master_host_name = pillar['system_host_roles']['hypervisor_role']['assigned_hosts'][0] %}
{% set salt_master_host_ip = pillar['system_hosts'][salt_master_host_name]['internal_net']['ip'] %}

{% set project_name = salt['config.get']('this_system_keys:project') %}
{% set profile_name = salt['config.get']('this_system_keys:profile') %}

{% set bootstrap_dir_basename = pillar['system_features']['bootstrap_configuration']['bootstrap_files_dir'] %}

{% for selected_host_name in pillar['system_hosts'].keys() %}

{% set selected_host = pillar['system_hosts'][selected_host_name] %}

{% if selected_host['instantiated_by'] %}

{% set instantiated_by = selected_host['instantiated_by'] %}
{% set instance_configuration = selected_host[instantiated_by] %}
{% set network_defined_in = selected_host['defined_in'] %}
{% set network_config = pillar[network_defined_in] %}

{% if pillar['system_features']['vagrant_configuration']['vagrant_provider'] == instance_configuration['vagrant_provider'] %} # match provider
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

  config.vm.define "{{ selected_host_name }}" do |{{ selected_host_name }}|

    {{ selected_host_name }}.vm.box = "{{ instance_configuration['base_image'] }}"

    # NOTE: Before target environment can be deployed (before using `deploy`),
    #       bootstrap script should be run with `build` in order to create
    #       package (configuration and resource files) for this target
    #       environment.
    # TODO: At the moment bootstrap hasn't been modified to understand
    #       `initial-online-node`, so we convert it here to known
    #       values 'initial-master' or 'online-minion' depending on role
    #       assignment to the host.
    {% if pillar['system_features']['vagrant_configuration']['bootstrap_use_case'] == 'initial-online-node' %} # bootstrap_use_case
    {% if selected_host_name in pillar['system_host_roles']['controller_role'] %} # selected_host_name
    {% set bootstrap_use_case = 'initial-master' %}
    {% else %} # selected_host_name
    {% set bootstrap_use_case = 'online-minion' %}
    {% endif %} # selected_host_name
    {% elif 'offline-minion-installer' %} # bootstrap_use_case
    {% set bootstrap_use_case = 'offline-minion-installer' %}
    {% else %} # bootstrap_use_case
    {{ UNEXPECTED_VALUE }}
    {% endif %} # bootstrap_use_case

    {{ selected_host_name }}.vm.provision "shell", inline: "python /vagrant/{{ bootstrap_dir_basename }}/bootstrap.py deploy {{ bootstrap_use_case }} 'conf/{{ project_name }}/{{ profile_name }}/{{ selected_host_name }}.py'"

    # Use `rsync` for synced folder.
    # Parameter `--copy-unsafe-links` is required for bootstrap directory
    # which might be a symlink.
    {{ selected_host_name }}.vm.synced_folder '{{ bootstrap_dir_basename }}/packages/{{ project_name }}/{{ profile_name }}/content/', '/vagrant/{{ bootstrap_dir_basename }}/', type: 'rsync',
        rsync__args: [
            "--verbose",
            "--archive",
            "--delete",
            "--copy-unsafe-links",
        ]

    # Based on Vagrant explanation, in the future they may support provider
    # per each VM. At the moment, it should only be configured per all
    # set of VMs (outside of individual configuration).
    #{{ selected_host_name }}.vm.provider = "{{ instance_configuration['vagrant_provider'] }}"

{# There is some difference how the network configuration line looks for `virtualbox` and `libvirt`. #}
{% if instance_configuration['vagrant_provider'] == 'libvirt' %} # libvirt
    {#
        # This works for `libvirt`.
        # See example config at: https://github.com/pradels/vagrant-libvirt
    #}
{% if instance_configuration['network_type'] == 'public_network' %} # public_network
    {{ selected_host_name }}.vm.network 'public_network',
        ip: '{{ selected_host[network_defined_in]['ip'] }}',
        :dev => '{{ instance_configuration['host_bridge_interface'] }}',
        :mode => 'bridge'
{% endif %} # public_network
{% if instance_configuration['network_type'] == 'private_network' %} # private_network
    {{ selected_host_name }}.vm.network 'private_network',
        ip: '{{ selected_host[network_defined_in]['ip'] }}',
        :dev => '{{ instance_configuration['host_bridge_interface'] }}',
        :libvirt__netmask => '{{ network_config['netmask'] }}',
        :libvirt__network_name => '{{ network_defined_in }}',
        :libvirt__forward_mode => 'nat',
        # Use DHCP to offer addresses to avoid too long initialization
        # of network interfaces during first boot (before static IP is
        # configured by Vagrant).
        # NOTE: At the time of coding IP range for DHCP server was not
        #       configurable. So, we hope that there will be no conflicts
        #       with IP addresses assigned statically.
        :libvirt__dhcp_enabled => true
{% endif %} # private_network

{% else %} # libvirt
    {#
        # This works for `virtualbox`.
    #}
{% if instance_configuration['network_type'] == 'public_network' %} # public_network
    {{ selected_host_name }}.vm.network 'public_network',
        ip: '{{ selected_host[network_defined_in]['ip'] }}',
        bridge: '{{ instance_configuration['host_bridge_interface'] }}'
{% endif %} # public_network
{% if instance_configuration['network_type'] == 'private_network' %} # private_network
    {{ TODO }}
{% endif %} # private_network
{% endif %} # libvirt

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
