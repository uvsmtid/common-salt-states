
###############################################################################
#

system_resources:

    # Common SSH public key.
    common_insecure_ssh_public_key.id_rsa.pub:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/ssh
        item_base_name: common.id_rsa.pub
        item_content_hash: md5=5b515e74909b772197b85521bee766a7

    # Common SSH public key.
    common_insecure_ssh_private_key.id_rsa:
        resource_repository: shared_content
        bootstrap_use_cases: True
        enable_content_validation: True
        enable_installation: True
        item_parent_dir_path: distrib/ssh
        item_base_name: common.id_rsa
        item_content_hash: md5=f9c7023d4b5bd54e27642db293f862c0

###############################################################################
# EOF
###############################################################################

