
###############################################################################
#

system_features:

    sonarqube_quality_gates:

        # TODO: This is a draft for setting SonarQube
        #       Quality Gates automatically through pillars.

        default:

            metrics_key: metrics_value

            # SINCE PREVIOUS VERSION ------------------------------------------

            # Coverage on new code
            # since previous version
            # is less than
            # 20

            # Technical Debt Ratio on new code
            # since previous version
            # is greater than
            # 5

            # New Blocker issues
            # since previous version
            # is greater than
            # 0

            # New Critical issues
            # since previous version
            # is greater than
            # 0


            # NOTE: The same conditions with multiple periods are broken
            #       in SonarQube 5.2 - see this link:
            #           http://stackoverflow.com/a/33648347/441652
            #       So, this was subsequently disabled until it can work again.

            # SINCE PREVIOUS ANALYSIS -----------------------------------------

            # Coverage on new code
            # since previous analysis
            # is less than
            # 20

            # Technical Debt Ratio on new code
            # since previous analysis
            # is greater than
            # 5

            # New Blocker issues
            # since previous analysis
            # is greater than
            # 0

            # New Critical issues
            # since previous analysis
            # is greater than
            # 0

###############################################################################
# EOF
###############################################################################

