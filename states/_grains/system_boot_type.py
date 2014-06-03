
import os
import platform

def provide_system_boot_type():

    if platform.system() == 'Linux':
        # See also:
        #  http://askubuntu.com/a/162896
        if os.path.exists('/sys/firmware/efi'):
            return { 'system_boot_type': 'UEFI' }
        else:
            return { 'system_boot_type': 'BIOS' }
    else: 
        return { 'system_boot_type': False }

