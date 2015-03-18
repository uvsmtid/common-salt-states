#!/usr/bin/env python

import os
import re
import platform

###############################################################################
#
def provide_os_platform_type():

    if False:
        pass
    elif platform.system() == 'Linux':
        uname_release = platform.uname()[2]
        # Example string to select from:
        #   3.18.9-200.fc21.x86_64
        distrib_string_regex = '^\d*\.\d*\.\d*-\d*\.(\w*)\.(\w*)$'
        #return uname_release
        re_match = re.match(distrib_string_regex, uname_release)
        platform_id = re_match.group(1)
        platform_arch = re_match.group(2)

        # Fedora
        if platform_id.startswith('fc'):
            return { 'os_platform_type': platform_id }

        # RedHat Enterprise Linux
        # CentOS
        if platform_id.startswith('el'):
            return { 'os_platform_type': 'rh' + platform_id }
 
    elif platform.system() == 'Windows':
        return { 'os_platform_type': 'win7' }

###############################################################################
#
if __name__ == '__main__':
    print provide_os_platform_type()

