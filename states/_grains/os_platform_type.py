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
        #   - Fedora 21:
        #       3.18.9-200.fc21.x86_64
        #   - CentOS 7.0:
        #       3.10.0-229.7.2.el7.x86_64
        #   - CentOS 5.5:
        #       2.6.18-194.el5

        # Try various patterns until the first match.
        re_match = None
        for distrib_string_regex in [
            '^\d*\.\d*\.\d*-\d*\.(\w*)\.\w*$', # Fedora 21
            '^\d*\.\d*\.\d*-\d*\.\d*\.\d*\.(\w*)\.\w*$', # CentOS 7.0
            '^\d*\.\d*\.\d*-\d*\.(\w*)$', # CentOS 5.5
        ]:
            re_match = re.match(distrib_string_regex, uname_release)
            if re_match:
                break;

        platform_id = re_match.group(1)

        # Fedora
        if platform_id.startswith('fc'):
            return { 'os_platform_type': platform_id }

        # RedHat Enterprise Linux
        # CentOS
        if platform_id.startswith('el'):
            return { 'os_platform_type': 'rh' + platform_id }

    elif platform.system() == 'Windows':

        platform_string = platform.platform()
        detected_platform = None

        # At the moment we only know how to differentiate Windows Server 2012.
        # TODO: Add other Windows versions when such minions are available.

        # NOTE: Function `platform.platform()` returns
        #       `Windows-2012Server-6.2.9200` for Windows Server 2012 R2.
        re_match = re.match('.*2012Server.*', platform_string)
        if re_match:
            detected_platform = 'winserv2012'

        return { 'os_platform_type': str(detected_platform) }

###############################################################################
#

if __name__ == '__main__':
    print provide_os_platform_type()

