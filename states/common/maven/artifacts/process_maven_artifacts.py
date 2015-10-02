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
    # get_verification_report

    get_verification_report_p = commands_sps.add_parser(
        'get_verification_report',
        description = "Generate effective poms in temporary directories "
            +"with config file point to them"
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_verification_report_p.add_argument(
        '--input_salt_pillar_yaml_path',
        default = def_value,
        help="Input file path with Salt pillar data"
    )
    def_value = None
    get_verification_report_p.add_argument(
        '--input_all_pom_files_per_repo_yaml_path',
        default = def_value,
    )
    def_value = None
    get_verification_report_p.add_argument(
        '--output_all_effective_poms_per_repo_dir',
        default = def_value,
    )
    def_value = None
    get_verification_report_p.add_argument(
        '--output_verification_report_yaml_path',
        default = def_value,
    )
    get_verification_report_p.set_defaults(func=get_verification_report_wrapper)

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

    return salt_pillar

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

def get_single_effective_pom(
    input_original_pom_file_path,
    output_single_effective_pom_file_path,
):

    """
    Generate output effective pom file from specified input original pom file.
    """

    assert(os.path.isabs(input_original_pom_file_path))

    # NOTE: If output is not absolute, Maven writes it into subdirectory
    #       of original pom file.
    assert(os.path.isabs(output_single_effective_pom_file_path))

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

def get_repo_path(
    repo_id,
    salt_pillar,
):

    repo_configs = salt_pillar['system_features']['deploy_environment_sources']

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

    return repo_path

#------------------------------------------------------------------------------
#

def normalize_pom_rel_path(
    rel_pom_path,
):
    # Remove any leading `./` from `rel_pom_path`.
    if './' in rel_pom_path[:2]:
        rel_pom_path = rel_pom_path[2:]
        logging.debug('rel_pom_path: ' + str(rel_pom_path))

    return rel_pom_path

#------------------------------------------------------------------------------
#

def check_if_pom_is_tracked(
    repo_path,
    rel_pom_path,
):
    # NOTE: Quick fix: check that file is tracked by Git.
    #           git ls-files --error-unmatch path/to/pom.xml
    # TODO: Currently it is limited to Git repository only.

    exit_data = call_subprocess(
        command_args = [
            'git',
            'ls-files',
            '--error-unmatch',
            rel_pom_path,
        ],
        cwd = repo_path,
        raise_on_error = False,
    )
    if exit_data['code'] != 0:
        logging.warning('this file is not tracked: ' + str(abs_pom_file))
        return False

    return True

#------------------------------------------------------------------------------
#

def get_pom_file_data(
    repo_id,
    rel_pom_path,
    salt_pillar,
):

    pom_file_data = {
        # Defaults.
        'is_exception': False,
    }

    repo_path = get_repo_path(
        repo_id,
        salt_pillar,
    )

    pom_file_data['relative_path'] = rel_pom_path

    # Get abs path to pom file.
    abs_pom_file = os.path.join(
        repo_path,
        rel_pom_path,
    )
    assert(os.path.exists(abs_pom_file))
    pom_file_data['absolute_path'] = abs_pom_file

    # NOTE: The `isfile` check follows symlinks as required.
    if not os.path.isfile(abs_pom_file):
        pom_file_data['is_file'] = False
        logging.warning('this path is not a file: ' + str(abs_pom_file))
        return None

    if not check_if_pom_is_tracked(
        repo_path,
        rel_pom_path,
    ):
        pom_file_data['is_tracked'] = False
        logging.warning('ignore untracked pom file: ' + str(abs_pom_file))
        return pom_file_data
    else:
        pom_file_data['is_tracked'] = True

    if repo_id in salt_pillar['system_maven_artifacts']['pom_file_exceptions']:
        if rel_pom_path in salt_pillar['system_maven_artifacts']['pom_file_exceptions'][repo_id]:
            pom_file_data['is_exception'] = True
            logging.warning('ignore this pom file from exceptions: ' + str(abs_pom_file))

    return pom_file_data

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
    for repo_id in salt_pillar['system_features']['deploy_environment_sources']['repository_roles']['maven_project_container_role']:

        repo_path = get_repo_path(
            repo_id,
            salt_pillar,
        )

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

        pom_files_per_repo = {}
        for rel_pom_path in exit_data['stdout'].split('\n'):

            # Skip empty lines.
            if not rel_pom_path:
                continue

            rel_pom_path = normalize_pom_rel_path(rel_pom_path)
            assert(rel_pom_path not in pom_files_per_repo)

            pom_files_per_repo[rel_pom_path] = get_pom_file_data(
                repo_id,
                rel_pom_path,
                salt_pillar,
            )

        all_pom_files_per_repo[repo_id] = pom_files_per_repo

    return all_pom_files_per_repo

###############################################################################
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
def get_maven_coordinate(
    dependency_elem,
    coordinate_tag_name,
    ignore_dependency_tags,
):

    maven_coords = get_xpath_elements(dependency_elem, './x:' + coordinate_tag_name)
    logging.debug(coordinate_tag_name + ': ' + str(maven_coords))
    if len(maven_coords) == 0:
        logging.debug('dependency_elem.tag: ' + str(dependency_elem.tag))
        assert(dependency_elem.tag in ignore_dependency_tags)
        return None
    else:
        assert(len(maven_coords) == 1)
        return maven_coords[0].text

#------------------------------------------------------------------------------
#

def get_single_pom_dependencies(
    # This object is output of this function call:
    #     etree.parse(input_xml_file_path).getroot()
    single_effective_pom_data,
):
    """
    Find Maven Coordinates for all (potential) pom dependencies.

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
    # NOTE: It's not clear whether these cases can be ignored.
    ignore_dependency_tags = [
        pom_xml_ns_prefix + 'reportPlugin',
        pom_xml_ns_prefix + 'plugin',

        # Tag `exclusion` exclude some dependencies from classpath.
        # See:
        #    https://maven.apache.org/guides/introduction/introduction-to-optional-and-excludes-dependencies.html
        pom_xml_ns_prefix + 'exclusion',

        # Tag `inclusion` is used by `maven-assembly-plugin`:
        # See:
        #    https://maven.apache.org/plugins/maven-assembly-plugin/examples/single/including-and-excluding-artifacts.html
        pom_xml_ns_prefix + 'inclusion',

        # Tag `pluginExecutionFilter` was seen used for Eclipse configuration
        # (without affecting build itself as claimed by comments).
        pom_xml_ns_prefix + 'pluginExecutionFilter',
    ]

    single_pom_dependencies = []
    for artifactId_elem in all_artifactId_elems:
        dependency_elem = artifactId_elem.getparent()

        pom_dependency = {}

        logging.debug('dependency_elem: ' + str(dependency_elem) + ': ' + str(etree.tostring(dependency_elem)))

        for coordinate_tag_name in [
            'groupId',
            'artifactId',
            'version',
        ]:
            pom_dependency[coordinate_tag_name] = get_maven_coordinate(
                dependency_elem,
                coordinate_tag_name,
                ignore_dependency_tags,
            )

        # Tag `artifactId` cannot be missed.
        assert(pom_dependency['artifactId'] != None)

        # Seve dependency.
        single_pom_dependencies += [ pom_dependency ]

    return single_pom_dependencies

#------------------------------------------------------------------------------
#

def get_single_pom_maven_coordinates(
    # This object is output of this function call:
    #     etree.parse(input_xml_file_path).getroot()
    single_effective_pom_data,
):
    """
    Find Maven Coordinates of pom.

    The information collected about dependency includes Maven Coordinates:
        https://maven.apache.org/pom.html#Maven_Coordinates
    """

    # The single first element in pom is `project`.
    project_element = single_effective_pom_data

    logging.debug('project_element: ' + str(project_element) + ': ' + str(etree.tostring(project_element)))

    pom_maven_coordinates = {}

    for coordinate_tag_name in [
        'groupId',
        'artifactId',
        'version',
    ]:
        pom_maven_coordinates[coordinate_tag_name] = get_maven_coordinate(
            project_element,
            coordinate_tag_name,
            ignore_dependency_tags = [],
        )
        # For pom Maven Coordinates all main tags must be defined.
        assert(pom_maven_coordinates[coordinate_tag_name] != None)

    return coordinate_tag_name

#------------------------------------------------------------------------------
#

def match_pom_dependencies_to_artifact_descriptors(
    report_data,
    single_pom_dependencies,
):

    for pom_dependency in single_pom_dependencies:

        dep_groupId = ''
        if pom_dependency['groupId']:
            dep_groupId = pom_dependency['groupId']

        artifact_key = dep_groupId + ':' + pom_dependency['artifactId']
        logging.debug('artifact_key: ' + str(artifact_key))

        if artifact_key not in report_data['artifact_descriptors']:
            msg = 'Artifact `' + artifact_key + '` is missing in `artifact_descriptors`'
            logging.error(msg)

            # Create artifact descriptor for report.
            report_data['artifact_descriptors'][artifact_key] = {
                'used': True,
                'source_type': None,
                'auto_verification_keys': {
                    'overall_result': False,
                    'error_messages': [
                        msg,
                    ],
                }
            }

        artifact_descriptor = report_data['artifact_descriptors'][artifact_key]

        # Create `auto_verification_keys` dict, if still missing.
        if 'auto_verification_keys' not in artifact_descriptor:
            artifact_descriptor['auto_verification_keys'] = {
                'overall_result': True,
            }

        if not artifact_descriptor['used'] or not artifact_descriptor['used']:
            msg = 'Artifact `' + artifact_key + '` is defined in `artifact_descriptors` but NOT declared as `used`'
            loggin.error(msg)
            artifact_descriptor['auto_verification_keys']['overall_result'] = False
            artifact_descriptor['auto_verification_keys']['error_messages'] += [ msg ]

        # At the moment, we only track/verify version of internal artifacts -
        # those which sources are internal to the project (artifacts are
        # built from sources in project repositories).
        # TODO: Add reference to docs.
        if artifact_descriptor['source_type'] in [
            'available-closed',
            'modified-open',
        ]:
            # TODO: What if there are more than one version used?
            #       There is only one value in `current_version`.
            # TODO: If there are more than one version, there should also be
            #       verification of unused versions in `artifact_descriptors`.
            current_version = artifact_descriptor['current_version']
            dep_version = pom_dependency['version']
            if dep_version != current_version:
                msg = 'Artifact `' + artifact_key + '` has different version `' + dep_version + '` from version `' + current_version + '` in `artifact_descriptors`'
                loggin.error(msg)
                artifact_descriptor['auto_verification_keys']['overall_result'] = False
                artifact_descriptor['auto_verification_keys']['error_messages'] += [ msg ]

        # Increment reference counter.
        if 'pom_reference_counter' not in artifact_descriptor['auto_verification_keys']:
            artifact_descriptor['auto_verification_keys']['pom_reference_counter'] = 0
        artifact_descriptor['auto_verification_keys']['pom_reference_counter'] += 1

###############################################################################
#

def get_verification_report_wrapper(
    context,
):

    salt_pillar = load_yaml_file(
        context.input_salt_pillar_yaml_path,
    )

    all_pom_files_per_repo = load_yaml_file(
        context.input_all_pom_files_per_repo_yaml_path,
    )

    verification_report = get_verification_report(
        salt_pillar,
        all_pom_files_per_repo,
        context.output_all_effective_poms_per_repo_dir,
    )

    save_yaml_file(
        verification_report,
        context.output_verification_report_yaml_path,
    )

    return verification_report['overall_result']

#------------------------------------------------------------------------------
#

def get_effective_pom_file_data(
    repo_id,
    pom_file_data,
    output_dir,
):

    effective_pom_abs_path = os.path.join(
        output_dir,
        repo_id,
        pom_file_data['relative_path'],
    )

    # Record information in captured report.
    pom_file_data['effective_absolute_path'] = effective_pom_abs_path

    # Create directories.
    effective_pom_parent_dir = os.path.dirname(effective_pom_abs_path)
    if not os.path.exists(effective_pom_parent_dir):
        logging.debug('effective_pom_parent_dir: ' + str(effective_pom_parent_dir))
        os.makedirs(effective_pom_parent_dir)

    # Generate effective pom file.
    get_single_effective_pom(
        pom_file_data['absolute_path'],
        effective_pom_abs_path,
    )

    return pom_file_data

#------------------------------------------------------------------------------
#

def get_verification_report(
    salt_pillar,
    all_pom_files_per_repo,
    output_all_effective_poms_per_repo_dir,
):

    # Root directory for effective pom files (in current dir).
    output_dir = output_all_effective_poms_per_repo_dir
    if not os.path.isabs(output_dir):
        output_dir = os.path.join(
            os.getcwd(),
            output_dir,
        )

    # NOTE: Make sure output directory for effective pom files is absolute
    #       to avoid Maven writting effective pom files into subdirectories
    #       of original ones.
    assert(os.path.isabs(output_dir))
    logging.debug('output_dir: ' + str(output_dir))

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Initialize report object.
    report_data = {
        # Initial data was captured during pom files search.
        'pom_files': all_pom_files_per_repo
        ,
        # Initial data is loaded directly from pillar.
        'artifact_descriptors': salt_pillar['system_maven_artifacts']['artifact_descriptors']
        ,
        # Default.
        'overall_result': True
    }

    # Verify data from pom to descriptors.
    for repo_id in report_data['pom_files'].keys():
        pom_files = report_data['pom_files'][repo_id]

        for pom_rel_path in pom_files.keys():

            pom_file_data = pom_files[pom_rel_path]
            pom_abs_path = pom_file_data['absolute_path']

            # Create `auto_verification_keys` dict, if still missing.
            if 'auto_verification_keys' not in pom_file_data:
                pom_file_data['auto_verification_keys'] = {
                    'overall_result': True,
                    'error_messages': [],
                }

            if pom_file_data['is_exception']:
                msg = 'Pom `' + pom_rel_path + '` from `' + repo_id + '` repo is exception: ' + pom_abs_path
                logging.warning(msg)
                # NOTE: This is not a failure, just note about exceptoin.
                artifact_descriptor['auto_verification_keys']['error_messages'] += [ msg ]

            if not pom_file_data['is_tracked']:
                msg = 'Pom `' + pom_rel_path + '` from `' + repo_id + '` repo is not tracked: ' + pom_abs_path
                logging.error(msg)
                artifact_descriptor['auto_verification_keys']['overall_result'] = False
                artifact_descriptor['auto_verification_keys']['error_messages'] += [ msg ]

            try:

                # Generate effective pom file.
                pom_file_data = get_effective_pom_file_data(
                    repo_id,
                    pom_file_data,
                    output_dir,
                )

                # Load effective pom XML data.
                single_effective_pom_data = load_xml_file(
                    pom_file_data['effective_absolute_path'],
                )

                # Get Maven Coordinates.
                single_pom_dependencies = get_single_pom_dependencies(
                    single_effective_pom_data,
                )

                # Update report.
                match_pom_dependencies_to_artifact_descriptors(
                    report_data,
                    single_pom_dependencies,
                )

            except:

                logging.critical('FAILED at original_pom_path: ' + str(pom_file_data['absolute_path']))

                # Ignore missing effective pom data.
                if 'effective_absolute_path' in pom_file_data:
                    logging.critical('FAILED at effective_pom_path: ' + str(pom_file_data['effective_absolute_path']))

                # Re-throw.
                raise

            if not pom_file_data['auto_verification_keys']['overall_result']:
                report_data['overall_result'] = False

    # Verify data from descriptors to pom.
    for artifact_key in report_data['artifact_descriptors'].keys():

        artifact_descriptor = report_data['artifact_descriptors'][artifact_key]

        if not artifact_descriptor['used']:
            logging.warning('Artifact descriptor is not uses: ' + str(artifact_key))
            continue

        # At the moment, we only care about internal artifacts -
        # those which sources are internal to the project (artifacts are
        # built from sources in project repositories).
        # TODO: Add reference to docs.
        if artifact_descriptor['source_type'] not in [
            'available-closed',
            'modified-open',
        ]:
            logging.warning('Skip external artifact: ' + str(artifact_key))
        else:

            # Get initial pom file info.
            pom_file_data = get_pom_file_data(
                artifact_descriptor['repository_id'],
                artifact_descriptor['item_path'],
                salt_pillar,
            )

            # Generate effective pom file.
            pom_file_data = get_effective_pom_file_data(
                repo_id,
                pom_file_data,
                output_dir,
            )

            # Load effective pom XML data.
            single_effective_pom_data = load_xml_file(
                pom_file_data['effective_absolute_path'],
            )

            # Get Maven Coordinates.
            pom_maven_coordinates = get_single_pom_maven_coordinates(
                single_effective_pom_data,
            )

        if not artifact_descriptor['auto_verification_keys']['overall_result']:
            report_data['overall_result'] = False

    return report_data

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
        logging.critical('result: ' + str(result))
        sys.exit(1)

###############################################################################
# EOF
###############################################################################

