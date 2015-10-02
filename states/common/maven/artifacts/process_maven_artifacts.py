#!/usr/bin/env python

# System modules
import os
import re
import sys
import yaml
import sets
import logging
import tempfile
import argparse
import subprocess

# Without this line `salt.client` somehow prevents all subsequent output.
logging.debug('initialize logging')

# NOTE: This command depends on `python-lxml` package (as of Fedora 22).
#       See also: http://lxml.de/tutorial.html
from lxml import etree

################################################################################
# Global variables

config = None

pom_xml_ns = 'http://maven.apache.org/POM/4.0.0'
pom_xml_ns_prefix = '{' + pom_xml_ns + '}'

################################################################################
#

def build_parser(
):

    default_format_string = "[default from config = \"%(default)s\"]"

    # Build command line parser.
    parser = argparse.ArgumentParser(description="Process Maven Artifacts")

    sections_ps = parser.add_subparsers(
        title = 'sections',
        description = "select section [c]commands or [u]unused"
        ,
        help = 'valid sections'
    )
    commands_p = sections_ps.add_parser(
        'c',
        help = "[c]ommands - section with various commands"
    )
    tests_p = sections_ps.add_parser(
        'u',
        help = "[u]unused - TODO"
    )

    # ==========================================================================
    # Commands

    commands_sps = commands_p.add_subparsers(
        title = 'commands',
        description = "TODO"
        ,
        help = 'Description of each command:'
    )

    # --------------------------------------------------------------------------
    # verify_known_dependencies

    verify_known_dependencies_p = commands_sps.add_parser(
        'verify_known_dependencies',
        description = ""
            + ""
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = 'TODO'
    verify_known_dependencies_p.add_argument(
        '--repos_config_file',
        dest = 'repos_config_file',
        metavar = 'repos_config_file',
        default = def_value,
        help="File with configuration for all repositories "
            + default_format_string % { "default": def_value }
    )
    def_value = 'TODO'
    verify_known_dependencies_p.add_argument(
        '--artifacts_config_file',
        dest = 'artifacts_config_file',
        metavar = 'artifacts_config_file',
        default = def_value,
        help="File with configuration for all Maven artifacts "
            + default_format_string % { "default": def_value }
    )
    verify_known_dependencies_p.set_defaults(func=verify_known_dependencies)

    # --------------------------------------------------------------------------
    # get_salt_pillar

    get_salt_pillar_p = commands_sps.add_parser(
        'get_salt_pillar',
        description = "Connect to Salt and retrieve pillar data"
            + ""
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_salt_pillar_p.add_argument(
        '--output_salt_pillar_yaml_file_path',
        default = def_value,
        help="Output Salt pillar YAML file path"
    )
    get_salt_pillar_p.set_defaults(func=get_salt_pillar_wrapper)

    # --------------------------------------------------------------------------
    # get_single_effective_pom

    get_single_effective_pom_p = commands_sps.add_parser(
        'get_single_effective_pom',
        description = "Generate Maven effective pom for specified original pom"
            + ""
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_single_effective_pom_p.add_argument(
        '--input_original_pom_file_path',
        default = def_value,
        help="Input original pom file path"
    )
    def_value = None
    get_single_effective_pom_p.add_argument(
        '--output_single_effective_pom_file_path',
        default = def_value,
        help="Output effective pom file path"
    )
    get_single_effective_pom_p.set_defaults(func=get_single_effective_pom_wrapper)

    # --------------------------------------------------------------------------
    # get_all_pom_files_per_repo

    get_all_pom_files_per_repo_p = commands_sps.add_parser(
        'get_all_pom_files_per_repo',
        description = "Find list of pom files per repository"
            + ""
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_all_pom_files_per_repo_p.add_argument(
        '--input_salt_pillar_yaml_path',
        default = def_value,
        help="Input file path with Salt pillar data"
    )
    def_value = None
    get_all_pom_files_per_repo_p.add_argument(
        '--output_all_pom_files_per_repo_yaml_path',
        default = def_value,
        help="Output file path for pom files per repo"
    )
    get_all_pom_files_per_repo_p.set_defaults(func=get_all_pom_files_per_repo_wrapper)

    # --------------------------------------------------------------------------
    # get_single_pom_dependencies

    get_single_pom_dependencies_p = commands_sps.add_parser(
        'get_single_pom_dependencies',
        description = "Get list of dependencies from pom data"
            + ""
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_single_pom_dependencies_p.add_argument(
        '--input_single_effective_pom_xml_path',
        default = def_value,
        help="Input effective pom.xml file path"
    )
    def_value = None
    get_single_pom_dependencies_p.add_argument(
        '--output_single_pom_dependencies_yaml_path',
        default = def_value,
        help="Output file path with pom dependencies"
    )
    get_single_pom_dependencies_p.set_defaults(func=get_single_pom_dependencies_wrapper)

    # --------------------------------------------------------------------------
    # get_all_effective_poms_per_repo

    get_all_effective_poms_per_repo_p = commands_sps.add_parser(
        'get_all_effective_poms_per_repo',
        description = "Generate effective poms in temporary directories "
            + "with config file point to them"
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_all_effective_poms_per_repo_p.add_argument(
        '--input_all_pom_files_per_repo_yaml_path',
        default = def_value,
    )
    def_value = None
    get_all_effective_poms_per_repo_p.add_argument(
        '--output_all_effective_poms_per_repo_yaml_path',
        default = def_value,
    )
    def_value = None
    get_all_effective_poms_per_repo_p.add_argument(
        '--output_all_effective_poms_per_repo_dir',
        default = def_value,
    )
    get_all_effective_poms_per_repo_p.set_defaults(func=get_all_effective_poms_per_repo_wrapper)

    # --------------------------------------------------------------------------
    # get_verification_report_pom_files_with_artifact_descriptors

    get_verification_report_pom_files_with_artifact_descriptors_p = commands_sps.add_parser(
        'get_verification_report_pom_files_with_artifact_descriptors',
        description = "Generate effective poms in temporary directories "
            +"with config file point to them"
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_verification_report_pom_files_with_artifact_descriptors_p.add_argument(
        '--input_salt_pillar_yaml_path',
        default = def_value,
        help="Input file path with Salt pillar data"
    )
    def_value = None
    get_verification_report_pom_files_with_artifact_descriptors_p.add_argument(
        '--input_all_pom_files_per_repo_yaml_path',
        default = def_value,
    )
    def_value = None
    get_verification_report_pom_files_with_artifact_descriptors_p.add_argument(
        '--output_all_effective_poms_per_repo_dir',
        default = def_value,
    )
    def_value = None
    get_verification_report_pom_files_with_artifact_descriptors_p.add_argument(
        '--output_verification_report_pom_files_with_artifact_descriptors_yaml_path',
        default = def_value,
    )
    get_verification_report_pom_files_with_artifact_descriptors_p.set_defaults(func=get_verification_report_pom_files_with_artifact_descriptors_wrapper)

    # Result
    return parser

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

def call_subprocess_with_files(
    command_args,
    raise_on_error = True,
    capture_stdout = False,
    capture_stderr = False,
    cwd = None,
    stdin_string = None,
):

    logging.debug('cwd: ' + str(cwd))
    logging.debug("command_args: " + "\"" + "\" \"".join(command_args) + "\"")

    # Return dictionary
    exit_data = {}

    stdout_sink = None
    stderr_sink = None

    stdout_file_path = None
    stdout_file = None
    if capture_stdout:
        (handle, stdout_file_path) = tempfile.mkstemp()
        logging.debug("stdout_file_path: " + str(stdout_file_path))
        exit_data['stdout_file_path'] = stdout_file_path
        stdout_file = os.fdopen(handle, "w")
        stdout_sink = stdout_file

    stderr_file_path = None
    stderr_file = None
    if capture_stderr:
        (handle, stderr_file_path) = tempfile.mkstemp()
        logging.debug("stderr_file_path: " + str(stderr_file_path))
        exit_data['stderr_file_path'] = stderr_file_path
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

    exit_data["code"] = p.returncode

    if raise_on_error:
        check_generic_errors(
            command_args = command_args,
            exit_data = exit_data,
            raise_on_error = raise_on_error,
            check_code = True,
            check_stderr = False,
            check_stdout = False,
            cwd = cwd,
        )

    if stdout_file:
        stdout_file.close()
    if stderr_file:
        stderr_file.close()

    if capture_stdout:
        stdout_file = open(stdout_file_path, "r")
        exit_data["stdout"] = stdout_file.read()
        stdout_file.close()
    if capture_stderr:
        stderr_file = open(stderr_file_path, "r")
        exit_data["stderr"] = stderr_file.read()
        stderr_file.close()

    return exit_data

################################################################################
#

def check_generic_errors(
    command_args,
    exit_data,
    raise_on_error = True,
    check_code = True,
    check_stderr = True,
    check_stdout = False,
    cwd = None,
):
    error_code = 0
    format_msg = "Error: command failed\n%(command)s\ncwd: %(cwd)s"
    format_dict = {
        "command": "\"" + "\" \"".join(command_args) + "\"",
        "cwd": str(cwd),
    }

    if check_code:
        if exit_data["code"] != 0:
            # Command failed
            error_code = 1
            format_dict["code"] = exit_data["code"]
            format_msg += "\nExit code: %(code)s"

    if check_stderr:
        if len(exit_data["stderr"]) != 0:
            # There are some error output
            error_code = 1
            format_dict["stderr"] = exit_data["stderr"]
            format_msg += "\nSTDERR: %(stderr)s"

    if check_stdout:
        if len(exit_data["stdout"]) != 0:
            # There are some standard output
            error_code = 1
            format_dict["stdout"] = exit_data["stdout"]
            format_msg += "\nSTDOUT: %(stdout)s"

    if raise_on_error:
        if error_code != 0:
            # Print captured stderr and stdout (if any) before raising
            if "stderr" in exit_data.keys():
                logging.debug("\'stderr' before failure:\n" + exit_data["stderr"])
            if "stdout" in exit_data.keys():
                logging.debug("\'stdout' before failure:\n" + exit_data["stdout"])

            # Raise
            msg = format_msg % format_dict
            raise Exception(msg)

    return error_code

################################################################################
#

def print_exit_data(
    exit_data,
    suppress_success_output = False,
):

    if suppress_success_output:
        if "code" in exit_data.keys():
            if exit_data["code"] == 0:
                return

    if "stdout" in exit_data.keys():
        # Use stderr to print stdout of the command.
        # If stdout results were captured,
        # they are not meant to be on stdout by default.
        logging.info(exit_data["stdout"])
    if "stderr" in exit_data.keys():
        logging.info(exit_data["stderr"])
    if "code" in exit_data.keys():
        logging.info("exit code = " + str(exit_data["code"]))

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
        raise Exception("Not implemented")

###############################################################################
#

def essentialize_dependency_items(
    dependency_items,
):

    """
    Extract only relevant information in the depencency items.

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
    exit_data = call_subprocess(
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
    for str_line in exit_data['stdout'].split('\n'):
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
    exit_data = call_subprocess(
        command_args = [
            'find',
            repo_conf['repo_root_path'],
            '-iname',
            'pom.xml',
        ],
        capture_stdout = True,
    )

    logging.debug('find output: ' + str(exit_data['stdout']))

    project_pom_files = []
    for pom_file in exit_data['stdout'].split('\n'):
        if os.path.isfile(pom_file):
            project_pom_files += [ pom_file ]
        else:
            logging.warning('this path is not a file: ' + str(pom_file))

    return project_pom_files

###############################################################################
#

def verify_dep_items_info(
    essential_dep_items,
    dep_confs,
):

    # Check every item in collected dependencies against
    # known status from configuration item.
    for dep_item_name in essential_dep_items:

        logging.debug('verify 1st-way: ' + str(dep_item_name))

        if dep_item_name in dep_confs:


            if dep_confs[dep_item_name]['used']:

                # We deal with exiting known dependency.
                logging.info('EXISTING: %(dep_name)s' % {
                        'dep_name': str(dep_item_name),
                    }
                )

                source_type_value = None

                if 'source_type' in dep_confs[dep_item_name]:
                    source_type_value = dep_confs[dep_item_name]['source_type']

                if source_type_value == None:
                    logging.critical('no value specified for `source_type`')

                elif source_type_value == 'thales':

                    # We could try to build the item here based on known
                    # location of its sources, but it's a lengthy process
                    # to do this for each dependency. Besides that,
                    # the dependency may require build some other
                    # dependencies it depends on (transient dependencies),
                    # for example, new version of them.
                    # In order to make this reliable, one should start going
                    # from the roots of dependency trees not to fail. This
                    # all complicates it and not implemented at the moment.

                    source_repo_name_value = None
                    source_repo_pom_path_value = None

                    if 'source_repo_name' in dep_confs[dep_item_name]:
                        source_repo_name_value = dep_confs[dep_item_name]['source_repo_name']

                    if 'source_repo_pom_path' in dep_confs[dep_item_name]:
                        source_repo_pom_path_value = dep_confs[dep_item_name]['source_repo_pom_path']

                    if source_repo_name_value == None:
                        logging.critical('no value specified for `source_repo_name`')

                    if source_repo_pom_path_value == None:
                        logging.critical('no value specified for `source_repo_pom_path`')

                    # TODO: Check if specified `pom.xml` file exists.

                    logging.info('%(dep_name)s is thales' % {
                            'dep_name': str(dep_item_name),
                        }
                    )

                elif dep_confs[dep_item_name]['source_type'] == 'open':
                    logging.info('%(dep_name)s is open sourced' % {
                            'dep_name': str(dep_item_name),
                        }
                    )

                else:
                    logging.critical('unknown value for `source_type`: ' + str(source_type_value))

            else:
                # The dependency is in current desription, but it
                # is marked as not used while we just spotted its use.
                # Therefore, it's `ADDED` (again).
                logging.info('ADDED: %(dep_name)s' % {
                        'dep_name': str(dep_item_name),
                    }
                )

        else:

            # We found new dependency which is not described in our
            # current file describing each dependency.

            logging.info('ADDED: %(dep_name)s' % {
                    'dep_name': str(dep_item_name),
                }
            )

    # Check if there is any dependency we knew about and it is
    # not referenced anymore.
    for dep_item_name in dep_confs.keys():

        logging.debug('verify 2nd-way: ' + str(dep_item_name))

        if dep_item_name in essential_dep_items:

            # These cases are already processed above.
            pass

        else:
            if dep_confs[dep_item_name]['used']:

                # This case tells us that there are some items in configuration
                # which are still makred as used, but they are not part of
                # actual (newly collected) dependencies.

                logging.info('UNUSED: %(dep_name)s' % {
                        'dep_name': str(dep_item_name),
                    }
                )

            else:

                # Item is not in the newly collected dependencies
                # and it is actually not used.

                logging.info('SKIPPED: %(dep_name)s' % {
                        'dep_name': str(dep_item_name),
                    }
                )

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
        dep_confs,
    )

    return result

###############################################################################
#

def load_yaml_file(
    file_path,
):

    """
    Return data loaded from specified YAML file path.
    """

    yaml_stream = None

    try:
        yaml_stream = open(file_path, 'r')
        return yaml.load(yaml_stream)
    finally:
        if yaml_stream:
            yaml_stream.close()

###############################################################################
#

def save_yaml_file(
    data,
    file_path,
):

    """
    Save data into specified YAML file path.
    """

    yaml_stream = None

    logging.debug('save_yaml_file.file_path: ' + str(file_path))

    try:
        yaml_stream = open(file_path, 'w')
        yaml.dump(
            data,
            yaml_stream,
            default_flow_style = False,
            indent = 4,
        )
    finally:
        if yaml_stream:
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
#

def load_xml_file(
    xml_file_path,
):
    """
    Parse arbitrary XML file.
    """

    xml_data = etree.parse(xml_file_path).getroot()

    return xml_data

###############################################################################
#

def get_salt_pillar_wrapper(
    context,
):
    """
    Wrap input/output and verify conditions for `get_salt_pillar`
    """

    if os.geteuid() != 0:
        raise Exception('This operation requires root privileges')

    salt_pillar = get_salt_pillar()

    # Save Salt pillar data.
    save_yaml_file(
        salt_pillar,
        context.output_salt_pillar_yaml_file_path
    )

#------------------------------------------------------------------------------
#

def get_salt_pillar(
):

    """
    Connects to Salt and retrieves pillar data.

    This function requires root privelege.
    """

    # Salt modules.
    import salt.client

    caller = salt.client.Caller()
    logging.debug(str(caller))

    salt_pillar = caller.function('pillar.items')
    logging.debug(str(salt_pillar))

    return salt_pillar

###############################################################################
#

def get_single_effective_pom_wrapper(
    context,
):
    """
    Wrap input/output and verify conditions for `get_single_effective_pom`
    """

    input_original_pom_file_path = context.input_original_pom_file_path
    output_single_effective_pom_file_path = context.output_single_effective_pom_file_path

    return get_single_effective_pom(
        input_original_pom_file_path,
        output_single_effective_pom_file_path,
    )

#------------------------------------------------------------------------------
#

def get_single_effective_pom(
    input_original_pom_file_path,
    output_single_effective_pom_file_path,
):

    """
    Generate output effective pom file from specified input original pom file.
    """

    exit_data = call_subprocess(
        command_args = [
            'mvn',
            '-f',
            input_original_pom_file_path,
            'help:effective-pom',
            '-Doutput=' + output_single_effective_pom_file_path,
        ],
    )

###############################################################################
#

def verify_known_dependencies(
    context,
):

    repo_conf_file = context.repos_config_file
    dep_conf_file = context.artifacts_config_file

    # Load repository confs.
    repo_confs = load_repo_confs(repo_conf_file)
    logging.debug('repo_confs: ' + str(repo_confs))

    # Load dependency confs.
    dep_confs = load_dep_confs(dep_conf_file)
    logging.debug('dep_confs: ' + str(dep_confs))

    # Check for any discrepancies.
    result = check_all_projects_in_all_repos(
        repo_confs,
        dep_confs,
    )

    return result

###############################################################################
#

def get_all_pom_files_per_repo_wrapper(
    context,
):
    """
    Wrap input/output and verify conditions for `get_all_pom_files_per_repo`
    """

    salt_pillar = load_yaml_file(
        context.input_salt_pillar_yaml_path
    )

    all_pom_files_per_repo = get_all_pom_files_per_repo(
        salt_pillar,
    )

    save_yaml_file(
        all_pom_files_per_repo,
        context.output_all_pom_files_per_repo_yaml_path
    )

    return all_pom_files_per_repo

#------------------------------------------------------------------------------
#

def get_all_pom_files_per_repo(
    salt_pillar,
):
    """
    Find all pom files in all Maven repositories.
    """

    all_pom_files_per_repo = {}

    # Select all Maven repositories.
    repo_configs = salt_pillar['system_features']['deploy_environment_sources']
    for repo_id in repo_configs['repository_roles']['maven_project_container_role']:

        # Only Git repository is supported at the moment.
        assert(repo_configs['source_repo_types'][repo_id] == 'git')

        repo_config = repo_configs['source_repositories'][repo_id]['git']

        # Get absolute path to repository.
        account_conf = salt_pillar['system_accounts'][
            salt_pillar['system_hosts'][
                repo_config['source_system_host']
            ]['primary_user']
        ]
        repo_path_base = account_conf['posix_user_home_dir']
        repo_path_rest = repo_config['origin_uri_ssh_path']
        repo_path = repo_path_base + '/' + repo_path_rest

        # Find all `pom.xml` files.
        exit_data = call_subprocess(
            command_args = [
                'find',
                '-iname',
                'pom.xml',
            ],
            cwd = repo_path,
            capture_stdout = True,
        )

        logging.debug('find output: ' + str(exit_data['stdout']))

        pom_files = []
        for rel_pom_file in exit_data['stdout'].split('\n'):

            # Remove any leading `./` from `rel_pom_file`.
            if './' in rel_pom_file[:2]:
                rel_pom_file = rel_pom_file[2:]
                logging.debug('rel_pom_file: ' + str(rel_pom_file))

            # Get abs path to pom file.
            abs_pom_file = os.path.join(
                repo_path,
                rel_pom_file,
            )
            assert(os.path.exists(abs_pom_file))

            if os.path.isfile(abs_pom_file):

                # NOTE: Quick fix: check that file is tracked by Git.
                #           git ls-files --error-unmatch pom.xml
                # TODO: Currently it is limited to Git repository only.

                exit_data = call_subprocess(
                    command_args = [
                        'git',
                        'ls-files',
                        '--error-unmatch',
                        os.path.basename(abs_pom_file),
                    ],
                    cwd = os.path.dirname(abs_pom_file),
                    raise_on_error = False,
                )
                if exit_data['code'] != 0:
                    logging.warning('this file is not tracked: ' + str(abs_pom_file))
                    continue

                if repo_id in salt_pillar['system_maven_artifacts']['pom_file_exceptions']:
                    if rel_pom_file not in salt_pillar['system_maven_artifacts']['pom_file_exceptions'][repo_id]:
                        pom_files += [ abs_pom_file ]
                    else:
                        logging.warning('ignore this pom file from exceptions: ' + str(abs_pom_file))
                else:
                    pom_files += [ abs_pom_file ]
            else:
                logging.warning('this path is not a file: ' + str(abs_pom_file))

        all_pom_files_per_repo[repo_id] = pom_files

    return all_pom_files_per_repo

###############################################################################
#

def get_single_pom_dependencies_wrapper(
    context
):

    single_effective_pom_data = load_xml_file(
        context.input_single_effective_pom_xml_path,
    )

    single_pom_dependencies = get_single_pom_dependencies(
        single_effective_pom_data,
    )

    save_yaml_file(
        single_pom_dependencies,
        context.output_single_pom_dependencies_yaml_path,
    )

    return single_pom_dependencies

#------------------------------------------------------------------------------
#
def get_xpath_elements(
    # NOTE: The elements must be prefixed by `x:` namespece.
    #       For example, `x:artifactId`.
    parent_elem,
    xpath_expr,
    x_xml_ns = pom_xml_ns,
):

    return parent_elem.xpath(
        xpath_expr,
        namespaces = {
            'x': x_xml_ns,
        }
    )

#------------------------------------------------------------------------------
#

def get_single_pom_dependencies(
    # This object is output of this function call:
    #     etree.parse(input_xml_file_path).getroot()
    single_effective_pom_data,
):
    """
    Find Maven pom dependencies.

    The information collected about dependency includes Maven Coordinates:
        https://maven.apache.org/pom.html#Maven_Coordinates

    The search for dependencies includes (hopefully, all) locations
    where Maven Coordinates can be specified.
    """

    all_artifactId_elems = get_xpath_elements(single_effective_pom_data, './/x:artifactId')

    logging.debug('artifactIds: ' + str(all_artifactId_elems))

    # Skip some tags without considering them as dependency.
    # The problem is that plugins often miss some information
    # like `groupId` or `version` which is hard to guess.
    ignore_dependency_tags = [
        pom_xml_ns_prefix + 'reportPlugin',
        pom_xml_ns_prefix + 'plugin',
    ]

    single_pom_dependencies = []
    for artifactId_elem in all_artifactId_elems:
        dependency_elem = artifactId_elem.getparent()

        pom_dependency = {}

        logging.debug('dependency_elem: ' + str(dependency_elem) + ': ' + str(etree.tostring(dependency_elem)))

        # Get `groupId`.
        maven_coords = get_xpath_elements(dependency_elem, './x:groupId')
        logging.debug('groupId: ' + str(maven_coords))
        if len(maven_coords) == 0:
            logging.debug('dependency_elem.tag: ' + str(dependency_elem.tag))
            assert(dependency_elem.tag in ignore_dependency_tags)
            pom_dependency['groupId'] = ''
        else:
            assert(len(maven_coords) == 1)
            pom_dependency['groupId'] = maven_coords[0].text

        # Get `artifactId`.
        maven_coords = get_xpath_elements(dependency_elem, './x:artifactId')
        logging.debug('artifactId: ' + str(maven_coords))
        assert(len(maven_coords) == 1)
        pom_dependency['artifactId'] = maven_coords[0].text

        # Get `version`.
        maven_coords = get_xpath_elements(dependency_elem, './x:version')
        logging.debug('version: ' + str(maven_coords))
        if len(maven_coords) == 0:
            logging.debug('dependency_elem.tag: ' + str(dependency_elem.tag))
            assert(dependency_elem.tag in ignore_dependency_tags)
            pom_dependency['version'] = ''
        else:
            assert(len(maven_coords) == 1)
            pom_dependency['version'] = maven_coords[0].text

        # Seve dependency.
        single_pom_dependencies += [ pom_dependency ]

    return single_pom_dependencies

###############################################################################
#

def get_all_effective_poms_per_repo_wrapper(
    context,
):

    all_pom_files_per_repo = load_yaml_file(
        context.input_all_pom_files_per_repo_yaml_path,
    )

    all_effective_poms_per_repo = get_all_effective_poms_per_repo(
        all_pom_files_per_repo,
        context.output_all_effective_poms_per_repo_dir,
    )

    save_yaml_file(
        all_effective_poms_per_repo,
        context.output_all_effective_poms_per_repo_yaml_path,
    )

    return all_effective_poms_per_repo

#------------------------------------------------------------------------------
#

def get_all_effective_poms_per_repo(
    all_pom_files_per_repo,
    output_all_effective_poms_per_repo_dir,
):

    # Root directory for effective pom files (in current dir).
    output_dir = output_all_effective_poms_per_repo_dir
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    all_effective_poms_per_repo = {}
    for repo_id in all_pom_files_per_repo.keys():
        original_pom_paths = all_pom_files_per_repo[repo_id]

        all_effective_poms_per_repo[repo_id] = []
        for original_pom_path in original_pom_paths:

            effective_pom_path = original_pom_path

            if os.path.isabs(effective_pom_path):
                # Drop the first char `/`.
                # Otherwise, `os.path.join` may take abs path.
                effective_pom_path = effective_pom_path[1:]

            effective_pom_path = os.path.join(
                output_dir,
                effective_pom_path,
            )

            # Create directories.
            effective_pom_parent_dir = os.path.dirname(effective_pom_path)
            if not os.path.exists(effective_pom_parent_dir):
                os.makedirs(effective_pom_parent_dir)

            # Generate effective pom file.
            get_single_effective_pom(
                original_pom_path,
                effective_pom_path,
            )

            # Record information in captured config.
            all_effective_poms_per_repo[repo_id] += [ effective_pom_path ]

    return all_effective_poms_per_repo

###############################################################################
#

def get_verification_report_pom_files_with_artifact_descriptors_wrapper(
    context,
):

    salt_pillar = load_yaml_file(
        context.input_salt_pillar_yaml_path,
    )

    all_pom_files_per_repo = load_yaml_file(
        context.input_all_pom_files_per_repo_yaml_path,
    )

    verification_report_pom_files_with_artifact_descriptors = get_verification_report_pom_files_with_artifact_descriptors(
        salt_pillar,
        all_pom_files_per_repo,
        context.output_all_effective_poms_per_repo_dir,
    )

    save_yaml_file(
        verification_report_pom_files_with_artifact_descriptors,
        context.output_verification_report_pom_files_with_artifact_descriptors_yaml_path,
    )

    return verification_report_pom_files_with_artifact_descriptors

#------------------------------------------------------------------------------
#

def get_verification_report_pom_files_with_artifact_descriptors(
    salt_pillar,
    all_pom_files_per_repo,
    output_all_effective_poms_per_repo_dir,
):

    # Root directory for effective pom files (in current dir).
    output_dir = output_all_effective_poms_per_repo_dir
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    all_effective_poms_per_repo = {}
    for repo_id in all_pom_files_per_repo.keys():
        original_pom_paths = all_pom_files_per_repo[repo_id]

        all_effective_poms_per_repo[repo_id] = []
        for original_pom_path in original_pom_paths:

            effective_pom_path = original_pom_path

            if os.path.isabs(effective_pom_path):
                # Drop the first char `/`.
                # Otherwise, `os.path.join` may take abs path.
                effective_pom_path = effective_pom_path[1:]

            effective_pom_path = os.path.join(
                output_dir,
                effective_pom_path,
            )

            # Create directories.
            effective_pom_parent_dir = os.path.dirname(effective_pom_path)
            if not os.path.exists(effective_pom_parent_dir):
                os.makedirs(effective_pom_parent_dir)

            # Generate effective pom file.
            get_single_effective_pom(
                original_pom_path,
                effective_pom_path,
            )

            # Record information in captured config.
            all_effective_poms_per_repo[repo_id] += [ effective_pom_path ]

    return all_effective_poms_per_repo

###############################################################################
# MAIN

if __name__ == '__main__':

    setLoggingLevel('debug')

    # Build parser
    parser = build_parser()
    # Parse command line
    context = parser.parse_args()
    # Execute
    result = context.func(context)

    if result:
        sys.exit(0)
    else:
        sys.exit(1)

###############################################################################
# EOF
###############################################################################

