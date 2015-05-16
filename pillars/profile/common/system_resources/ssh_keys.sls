
###############################################################################
#

system_resources:

    # Vagrant public SHH key.
    # URL: https://raw.githubusercontent.com/mitchellh/vagrant/004ea50bf2ae55d563fd9da23cb2d6ec6cd447e4/keys/vagrant.pub
    vagrant_insecure_ssh_public_key.id_rsa.pub:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/vagrant
        item_base_name: vagrant_insecure.id_rsa.pub
        item_content_hash: md5=b440b5086dd12c3fd8abb762476b9f40

    # Vagrant private SSH key.
    # URL: https://raw.githubusercontent.com/mitchellh/vagrant/004ea50bf2ae55d563fd9da23cb2d6ec6cd447e4/keys/vagrant
    vagrant_insecure_ssh_private_key.id_rsa:
        resource_repository: common-resources
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: common/vagrant
        item_base_name: vagrant_insecure.id_rsa
        item_content_hash: md5=5a22f077ee1e084f37c3743cf3ce8e3a

###############################################################################
# EOF
###############################################################################

