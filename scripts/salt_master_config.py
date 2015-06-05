#!/usr/bin/env python

import yaml
import logging

# This script facilitates verification and modification of Salt master
# to provide environment expected by `common-salt-states` repository.

###############################################################################
#

salt_master_conf_path = '/etc/salt/master'

###############################################################################
#

def main():

    salt_master_conf = None
    salt_master_conf_stream = None
    try:
        salt_master_conf_stream = open(salt_master_conf_path)
        salt_master_conf = yaml.load(salt_master_conf_stream)
    finally:
        salt_master_conf_stream.close()
        
    print str(salt_master_conf)

###############################################################################
#
if __name__ == '__main__':
    main()

###############################################################################
# END
###############################################################################

