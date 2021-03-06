#

# System modules
import os
import logging
import tempfile
import subprocess

################################################################################
#
# Function to call scripts
#

# TODO: This function, if used, won't work with `stdin_string`.
def call_subprocess_with_pipes(
    command_args,
    raise_on_error = True,
    capture_stdout = False,
    capture_stderr = False,
    stdin_string = None,
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

###############################################################################
#

def call_subprocess_with_files(
    command_args,
    raise_on_error = True,
    capture_stdout = False,
    capture_stderr = False,
    cwd = None,
    stdin_string = None,
):

    logging.debug("command line: " + "\"" + "\" \"".join(command_args) + "\"")

    stdout_sink = None
    stderr_sink = None

    stdout_file_path = None
    stdout_file = None
    if capture_stdout:
        (handle, stdout_file_path) = tempfile.mkstemp()
        logging.debug("stdout_file_path: " + str(stdout_file_path))
        stdout_file = os.fdopen(handle, "w")
        stdout_sink = stdout_file

    stderr_file_path = None
    stderr_file = None
    if capture_stderr:
        (handle, stderr_file_path) = tempfile.mkstemp()
        logging.debug("stderr_file_path: " + str(stderr_file_path))
        stderr_file = os.fdopen(handle, "w")
        stderr_sink = stderr_file

    stdin = None
    if stdin_string:
        stdin = subprocess.PIPE

    p = subprocess.Popen(
        command_args,
        stdout = stdout_sink,
        stderr = stderr_sink,
        cwd = cwd,
        stdin = stdin,
    )

    logging.debug('stdin_string: ' + str(stdin_string))
    if stdin_string:
        logging.debug('before write: ' + str(stdin_string))
        p.stdin.write(stdin_string)
        logging.debug('before communicate')
        p.communicate()
        logging.debug('before close')
        p.stdin.close()

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

    if stdout_file:
        stdout_file.close()
    if stderr_file:
        stderr_file.close()

    if capture_stdout:
        stdout_file = open(stdout_file_path, "r")
        result["stdout"] = stdout_file.read()
        stdout_file.close()
    if capture_stderr:
        stderr_file = open(stderr_file_path, "r")
        result["stderr"] = stderr_file.read()
        stderr_file.close()

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
#

def call_subprocess(
    command_args,
    raise_on_error = True,
    # In this script stdout is reserved for Collector->Slave->Master
    # communication: capture stdout by default.
    capture_stdout = False,
    # In this script stderr is used primarily for
    # feedback to user Collector->Slave->Master->User: do not capture stderr.
    capture_stderr = False,
    cwd = None,
    stdin_string = None,
):

    # Alternative versions of the same function which captures output into
    # temporary files or through pipes.
    if True:
        return call_subprocess_with_files(
            command_args = command_args,
            raise_on_error = raise_on_error,
            capture_stdout = capture_stdout,
            capture_stderr = capture_stderr,
            cwd = cwd,
            stdin_string = stdin_string,
        )
    else:
        return call_subprocess_with_pipes(
            command_args = command_args,
            raise_on_error = raise_on_error,
            capture_stdout = capture_stdout,
            capture_stderr = capture_stderr,
            cwd = cwd,
            stdin_string = stdin_string,
        )

###############################################################################
# EOF
###############################################################################

