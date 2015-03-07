#

# System modules
import os
import logging
import subprocess

################################################################################
#
# Function to call scripts
#

def call_subprocess(
    command_args,
    raise_on_error = True,
    # In this script stdout is reserved for Collector->Slave->Master
    # communication: capture stdout by default.
    capture_stdout = True,
    # In this script stderr is used primarily for
    # feedback to user Collector->Slave->Master->User: do not capture stderr.
    capture_stderr = False,
):

    logging.debug("command line: " + "\"" + "\" \"".join(command_args) + "\"")

    stdoutsink = None
    stderrsink = None

    if capture_stdout:
        stdoutsink = subprocess.PIPE

    if capture_stderr:
        stderrsink = subprocess.PIPE

    p = subprocess.Popen(command_args, stdout=stdoutsink, stderr=stderrsink)

    # Wait until command stops
    p.wait()

    # Return dictionary
    result = {}

    result["code"] = p.returncode

    if raise_on_error:
        check_generic_errors(
            command_args = command_args,
            process_output = result,
            raise_on_error = raise_on_error,
            check_code = True,
            check_stderr = False,
            check_stdout = False,
        )

    stds = p.communicate()
    if capture_stdout:
        result["stdout"] = stds[0]
    if capture_stderr:
        result["stderr"] = stds[1]

    return result


################################################################################
#

def check_generic_errors(
    command_args,
    process_output,
    raise_on_error = True,
    check_code = True,
    check_stderr = True,
    check_stdout = False,
):
    error_code = 0
    format_msg = "Error: command failed\n%(command)s"
    format_dict = {
        "command": "\"" + "\" \"".join(command_args) + "\""
    }

    if check_code:
        if process_output["code"] != 0:
            # Command failed
            error_code = 1
            format_dict["code"] = process_output["code"]
            format_msg += "\nExit code: %(code)s"

    if check_stderr:
        if len(process_output["stderr"]) != 0:
            # There are some error output
            error_code = 1
            format_dict["stderr"] = process_output["stderr"]
            format_msg += "\nSTDERR: %(stderr)s"

    if check_stdout:
        if len(process_output["stdout"]) != 0:
            # There are some standard output
            error_code = 1
            format_dict["stdout"] = process_output["stdout"]
            format_msg += "\nSTDOUT: %(stdout)s"

    if raise_on_error:
        if error_code != 0:
            # Print captured stderr and stdout (if any) before raising
            if "stderr" in process_output.keys():
                logging.debug("\'stderr' before failure:\n" + process_output["stderr"])
            if "stdout" in process_output.keys():
                logging.debug("\'stdout' before failure:\n" + process_output["stdout"])

            # Raise
            msg = format_msg % format_dict
            raise Exception(msg)

    return error_code

################################################################################
#

def print_process_output(
    process_output,
    suppress_success_output = False,
):

    if suppress_success_output:
        if "code" in process_output.keys():
            if process_output["code"] == 0:
                return

    if "stdout" in process_output.keys():
        # Use stderr to print stdout of the command.
        # If stdout results were captured,
        # they are not meant to be on stdout by default.
        logging.info(process_output["stdout"])
    if "stderr" in process_output.keys():
        logging.info(process_output["stderr"])
    if "code" in process_output.keys():
        logging.info("exit code = " + str(process_output["code"]))

###############################################################################
# EOF
###############################################################################

