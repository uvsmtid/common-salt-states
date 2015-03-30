#!/usr/bin/env python

# System modules
import os
import re
import sys
import yaml
import sets
import logging
import tempfile
import subprocess

################################################################################
#

def setLoggingLevel(
    level_name = None,
):

    # Set log level ahead of the processing
    num_level = getattr(logging, level_name.upper(), None)
    if not isinstance(num_level, int):
        raise ValueError('error: invalid log level \"%s\"' % level_name)
    logging.getLogger().setLevel(num_level)

################################################################################
#
# Function to call scripts
#

def call_subprocess_with_pipes(
    command_args,
    raise_on_error = True,
    capture_stdout = False,
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

###############################################################################

def call_subprocess_with_files(
    command_args,
    raise_on_error = True,
    capture_stdout = False,
    capture_stderr = False,
    cwd = None,
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

    p = subprocess.Popen(
        command_args,
        stdout = stdout_sink,
        stderr = stderr_sink,
        cwd = cwd,
    )

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
        )
    else:
        return call_subprocess_with_pipes(
            command_args = command_args,
            raise_on_error = raise_on_error,
            capture_stdout = capture_stdout,
            capture_stderr = capture_stderr,
            cwd = cwd,
        )

###############################################################################
#

def essentialize_dependency_items(
    dependency_items,
):

    """
    Extract only relevan information in the depencency items.

    * Strip off version and scope.
    * Make unique list of items.
    """

    unique_deps = sets.Set()
    for dependency_item in dependency_items:
        stripped_dep_item = dependency_item['artifact_group'] + ':' + dependency_item['artifact_name']
        unique_deps.add(stripped_dep_item)

    return sorted(unique_deps)

###############################################################################
#

def parse_maven_dependency_list_ouput(
    pom_file,
):

    # Resolve (download) all dependencies locally so that next command
    # can work offline.
    call_subprocess(
        command_args = [
            'mvn',
            '-f',
            pom_file,
            'dependency:resolve',
        ],
    )

    # Get list of all dependencies.
    process_output = call_subprocess(
        command_args = [
            'mvn',
            '-f',
            pom_file,
            'dependency:list',
        ],
        capture_stdout = True,
    )

    # Regex to capture artifact reported by Maven.
    # Example line:
    # [INFO]    org.hibernate.javax.persistence:hibernate-jpa-2.0-api:jar:1.0.1.Final:compile
    artifact_regex = re.compile('^\[INFO\]\s*([^:\s]*):([^:\s]*):([^:\s]*):([^:\s]*):([^:\s]*)$')

    dependency_items = []
    for str_line in process_output['stdout'].split('\n'):
        artifact_match = artifact_regex.match(str_line)

        if artifact_match:
            logging.info('line matched: ' + str(str_line))

            artifact_group = artifact_match.group(1)
            artifact_name = artifact_match.group(2)
            artifact_package = artifact_match.group(3)
            artifact_version = artifact_match.group(4)
            artifact_scope = artifact_match.group(5)

            dependency_item = {
                'artifact_group': artifact_group,
                'artifact_name': artifact_name,
                'artifact_package': artifact_package,
                'artifact_version': artifact_version,
                'artifact_scope': artifact_scope,
            }

            logging.info('artifact_group: ' + str(dependency_item))

            dependency_items += [ dependency_item ]
        else:
            logging.debug('line didn\'t match: ' + str(str_line))

    return dependency_items

###############################################################################
#

def find_project_pom_files_in_a_repo(
    repo_conf,
):

    # Find all `pom.xml` files.
    process_output = call_subprocess(
        command_args = [
            'find',
            repo_conf['repo_root_path'],
            '-iname',
            'pom.xml',
        ],
        capture_stdout = True,
    )

    logging.debug('find output: ' + str(process_output['stdout']))

    project_pom_files = []
    for pom_file in process_output['stdout'].split('\n'):
        if os.path.isfile(pom_file):
            project_pom_files += [ pom_file ]
        else:
            logging.warning('this path is not a file: ' + str(pom_file))

    return project_pom_files

###############################################################################
#

def verify_dep_items_info(
    essential_dep_items,
):

    for dep_item in essential_dep_items:
        logging.debug('TODO: ' + str(dep_item))

    return True

###############################################################################
#

def check_all_projects_in_all_repos(
    repo_confs,
    dep_confs,
):

    # Collect all dependencies.
    dependency_items = []
    for repo_conf in repo_confs.values():

        project_pom_files = find_project_pom_files_in_a_repo(
            repo_conf,
        )

        for pom_file in project_pom_files:

            logging.info('run maven for file: ' + str(pom_file))

            next_dependency_items = parse_maven_dependency_list_ouput(
                pom_file,
            )
            logging.info('len(next_dependency_items): ' + str(len(next_dependency_items)))

            dependency_items += next_dependency_items

    logging.debug('dependency_items: ' + str(dependency_items))
    logging.info('len(dependency_items): ' + str(len(dependency_items)))

    # Essentialize dependencies.
    essential_dep_items = essentialize_dependency_items(
        dependency_items,
    )

    logging.debug('essential_dep_items: ' + str(essential_dep_items))
    logging.info('len(essential_dep_items): ' + str(len(essential_dep_items)))

    # Check currently known information for each dependency with the newly
    # obtained one.
    result = verify_dep_items_info(
        essential_dep_items,
    )

    return result

###############################################################################
#
def load_yaml_file(
    file_path,
):

    try:
        yaml_stream = open(file_path, 'r')
        return yaml.load(yaml_stream)
    finally:
        yaml_stream.close()

###############################################################################
#

def load_repo_confs(
    repo_confs_file_path,
):

    return load_yaml_file(repo_confs_file_path)

###############################################################################
#

def load_dep_confs(
    dep_confs_file_path,
):

    return load_yaml_file(dep_confs_file_path)

###############################################################################
# MAIN

if __name__ == '__main__':


    setLoggingLevel('debug')

    repo_conf_file = sys.argv[1]
    dep_conf_file = sys.argv[2]

    # Load repository confs.
    repo_confs = load_repo_confs(repo_conf_file)

    # Load dependency confs.
    dep_confs = load_dep_confs(dep_conf_file)

    # Check for any discrepancies.
    result = check_all_projects_in_all_repos(
        repo_confs,
        dep_confs,
    )

    if result:
        sys.exit(0)
    else:
        sys.exit(1)

###############################################################################
# EOF
###############################################################################

