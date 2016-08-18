
###############################################################################

from utils.exec_command import call_subprocess

###############################################################################
#

def ping_host_linux(
    # Use either hostname or IP address.
    resolvable_string,
    ping_times = 3,
):
    call_subprocess(
        command_args = [
            '/bin/ping',
            '-c',
            str(ping_times),
            resolvable_string,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def ping_host_windows(
    # Use either hostname or IP address.
    resolvable_string,
    ping_times = 3,
):
    call_subprocess(
        command_args = [
            'ping',
            '-n',
            str(ping_times),
            resolvable_string,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def set_net_config_var(
    var_name,
    var_value,
    file_path,
    # TODO
    append_if_absent = True,
):

    call_subprocess(
        command_args = [
            'sed',
            '-i',
            's/^' + var_name + '=.*$/' + var_name + '=' + var_value + '/g',
            '/etc/sysconfig/network',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def set_transient_route(
    # Do not call default route `default`, use `0.0.0.0/0`.
    network_address,
    router_address,
):

    # Check if default route is set before removing.
    route_exists = False
    process_output = call_subprocess(
        command_args = [
            '/sbin/ip',
            'route',
            'list',
            'exact',
            network_address,
        ],
        raise_on_error = False,
        capture_stdout = True,
        capture_stderr = False,
    )
    # If route exists, there will be output.
    if process_output["stdout"] and not process_output["stdout"].isspace():
        route_exists = True

    # Remove current existing default route.
    if route_exists:
        call_subprocess(
            command_args = [
                '/sbin/ip',
                'route',
                'del',
                network_address,
            ],
            raise_on_error = True,
            capture_stdout = False,
            capture_stderr = False,
        )

    # Set route.
    call_subprocess(
        command_args = [
            '/sbin/ip',
            'route',
            'add',
            network_address,
            'via',
            router_address,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def set_hostname_windows(
    hostname,
):

    # NOTE: Unfortunately for Windows,
    #       the name will only become effective after restart.
    call_subprocess(
        command_args = [
            'powershell',
            'Rename-Computer',
            '-NewName',
            hostname,
            # NOTE: Command complains that NetBIOS names are
            #       limited to 15 bytes. We force it - what else we can do?
            '-Force',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def disable_windows_firewall(
):

    call_subprocess(
        command_args = [
            'powershell',
            'Set-NetFirewallProfile',
            '-All',
            '-Enabled',
            'False',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# Set default getway (this is both transient and persistent for Windows).

def set_route_windows(
    network_destination,
    network_mask,
    router_address,
):

    # Set route.
    # See: http://serverfault.com/a/790434/134406
    # NOTE: We ignore error code
    #       (just in case the route already exists).
    call_subprocess(
        command_args = [
            'route',
            '-p',
            'add',
            network_destination,
            'mask',
            network_mask,
            router_address,
        ],
        raise_on_error = False,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Update route
    # (just in case the route existed and only needs to be changed).
    call_subprocess(
        command_args = [
            'route',
            '-p',
            'change',
            network_destination,
            'mask',
            network_mask,
            router_address,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# Set DNS servers on Windows.

# This is both transient and persistent setting.
def set_dns_server_windows(
    dns_server_ip,
):

    # See: http://stackoverflow.com/a/38374786/441652

    # Clear DNS servers.
    call_subprocess(
        command_args = [
            'wmic',
            'nicconfig',
            'where',
            '(IPEnabled=True)',
            'call',
            'SetDNSServerSearchOrder',
            '()',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Set DNS server.
    call_subprocess(
        command_args = [
            'wmic',
            'nicconfig',
            'where',
            '(IPEnabled=True)',
            'call',
            'SetDNSServerSearchOrder',
            '("' + dns_server_ip + '")',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

