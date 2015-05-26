
###############################################################################
#

include:

    - {{ this_pillar }}.primary_net

    - {{ this_pillar }}.internal_net
    - {{ this_pillar }}.secondary_internal_net
    - {{ this_pillar }}.external_net
    - {{ this_pillar }}.secondary_external_net

###############################################################################
# EOF
###############################################################################

