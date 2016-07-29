
###############################################################################
#

system_features:

    # TODO: Refactor. Rename `validate_depository_role_content` key
    #       to something more appropriate as sub key
    #       `depository_role_content_parent_dir` is used in many different
    #       cases beside just validation of content.

    # Use checksums for all content items to validate integrity of files on `depository_role`.
    validate_depository_role_content:
        feature_enabled: False

        depository_role_content_parent_dir: '/var/www/html/depository_role/content'

###############################################################################
# EOF
###############################################################################

