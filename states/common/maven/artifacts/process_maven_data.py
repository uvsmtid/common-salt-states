#!/usr/bin/env python

# System modules
import os
import re
import sys
import yaml
import sets
import types
import shutil
import random
import logging
import tempfile
import argparse
import datetime
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
    # get_incremental_report

    get_incremental_report_p = commands_sps.add_parser(
        'get_incremental_report',
        description = "Load all necessary information into initial report."
            + ""
        ,
        help = ""
            + ""
            + ""
    )
    def_value = None
    get_incremental_report_p.add_argument(
        '--input_salt_pillar_yaml_path',
        default = def_value,
        help="Input file path with Salt pillar data"
    )
    def_value = None
    get_incremental_report_p.add_argument(
        '--input_all_pom_files_per_repo_yaml_path',
        default = def_value,
    )
    def_value = None
    get_incremental_report_p.add_argument(
        '--output_pom_data_dir',
        default = def_value,
    )
    def_value = None
    get_incremental_report_p.add_argument(
        '--input_incremental_report_yaml_path',
        default = def_value,
    )
    def_value = None
    get_incremental_report_p.add_argument(
        '--output_incremental_report_yaml_path',
        default = def_value,
    )
    get_incremental_report_p.set_defaults(func=get_incremental_report_wrapper)

    # --------------------------------------------------------------------------
    # Return parser

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
                logging.debug("`stderr' before failure:\n" + exit_data["stderr"])
            if "stdout" in exit_data.keys():
                logging.debug("`stdout' before failure:\n" + exit_data["stdout"])

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

    xml_data = etree.parse(xml_file_path)

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
    logging.debug(str(salt_pillar.keys()))

    # At the moment Salt does not return non-zero exit code on error.
    # Instead, problems to compile pillar data result in message
    # inside pillar itself under `_errors` key.
    if '_errors' in salt_pillar:
        raise Exception('Salt pillar compilation error: ' + str(salt_pillar['_errors']))

    return salt_pillar

#------------------------------------------------------------------------------
#

def maven_reactor_root_clean(
    salt_pillar,
):

    repo_id = salt_pillar['system_maven_artifacts']['maven_reactor_root_pom']['repository_id']
    pom_rel_path = salt_pillar['system_maven_artifacts']['maven_reactor_root_pom']['pom_relative_path']
    pom_file_data = get_pom_file_data(
        repo_id,
        pom_rel_path,
        salt_pillar,
        None,
    )

    assert(pom_file_data['is_file'])
    assert(pom_file_data['is_tracked'])
    assert(not pom_file_data['is_exception'])
    assert(os.path.isabs(pom_file_data['absolute_path']))
    assert(not os.path.isabs(pom_file_data['relative_path']))

    exit_data = call_subprocess(
        command_args = [
            'mvn',
            '-f',
            pom_file_data['absolute_path'],
            'clean',
        ],
    )

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
    logging.debug('output_single_effective_pom_file_path: ' + str(output_single_effective_pom_file_path))
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

def get_all_pom_files_per_repo_wrapper(
    context,
):
    """
    Wrap input/output and verify conditions for `get_all_pom_files_per_repo`
    """

    salt_pillar = load_yaml_file(
        context.input_salt_pillar_yaml_path
    )

    maven_reactor_root_clean(
        salt_pillar,
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
    pom_rel_path,
):
    # Remove any leading `./` from `pom_rel_path`.
    if './' in pom_rel_path[:2]:
        pom_rel_path = pom_rel_path[2:]
        logging.debug('pom_rel_path: ' + str(pom_rel_path))

    return pom_rel_path

#------------------------------------------------------------------------------
#

def check_if_pom_is_tracked(
    repo_path,
    pom_rel_path,
):
    # NOTE: Quick fix: check that file is tracked by Git.
    #           git ls-files --error-unmatch path/to/pom.xml
    # TODO: Currently it is limited to Git repository only.

    # NOTE: This command also returns required results when
    #       file is outside of repository rooted at `repo_path`
    #       (for example, when file is in submodule) -
    #       submodule files should not be considered tracked by
    #       top level repository.

    exit_data = call_subprocess(
        command_args = [
            'git',
            'ls-files',
            '--error-unmatch',
            pom_rel_path,
        ],
        cwd = repo_path,
        raise_on_error = False,
    )

    abs_pom_file = os.path.join(
        repo_path,
        pom_rel_path,
    )
    if exit_data['code'] != 0:
        logging.warning('This pom file is not tracked: ' + str(abs_pom_file))
        return False

    return True

#------------------------------------------------------------------------------
#

def get_pom_file_data(
    repo_id,
    pom_rel_path,
    salt_pillar,
    item_descriptor,
):

    pom_file_data = {
        # Defaults.
        'is_file': True,
        'is_tracked': False,
        'is_exception': False,
    }

    repo_path = get_repo_path(
        repo_id,
        salt_pillar,
    )
    logging.debug('repo_path: ' + str(repo_path))

    pom_file_data['relative_path'] = pom_rel_path
    logging.debug('relative_path: ' + str(pom_rel_path))

    # Get abs path to pom file.
    abs_pom_file = os.path.join(
        repo_path,
        pom_rel_path,
    )
    logging.debug('abs_pom_file: ' + str(abs_pom_file))

    # Check if file exists.
    if not os.path.exists(abs_pom_file):
        if item_descriptor:
            msg = item_descriptor.get_desc_coords_string() + 'abs_pom_file does not exist: ' + str(abs_pom_file)
            logging.error(msg)
            item_descriptor.add_step_log(
                'missing_abs_pom_file_`' + repo_id + '`:`' + pom_rel_path + '`',
                False,
                msg,
            )
        return None

    pom_file_data['absolute_path'] = abs_pom_file

    # NOTE: The `isfile` check follows symlinks as required.
    if not os.path.isfile(abs_pom_file):
        pom_file_data['is_file'] = False
        logging.warning('this path is not a file: ' + str(abs_pom_file))
        return None

    if not check_if_pom_is_tracked(
        repo_path,
        pom_rel_path,
    ):
        pom_file_data['is_tracked'] = False
        logging.warning('ignore untracked pom file: ' + str(abs_pom_file))
        return pom_file_data
    else:
        pom_file_data['is_tracked'] = True

    if repo_id in salt_pillar['system_maven_artifacts']['pom_file_exceptions']:
        if pom_rel_path in salt_pillar['system_maven_artifacts']['pom_file_exceptions'][repo_id]:
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
        for pom_rel_path in exit_data['stdout'].split('\n'):

            # Skip empty lines.
            if not pom_rel_path:
                continue

            pom_rel_path = normalize_pom_rel_path(pom_rel_path)
            assert(pom_rel_path not in pom_files_per_repo)

            pom_files_per_repo[pom_rel_path] = get_pom_file_data(
                repo_id,
                pom_rel_path,
                salt_pillar,
                None,
            )

        all_pom_files_per_repo[repo_id] = pom_files_per_repo

    return all_pom_files_per_repo

###############################################################################
#

def get_artifact_key(
    maven_coords,
):

    dep_groupId = ''
    if maven_coords['groupId']:
        dep_groupId = maven_coords['groupId']

    artifact_key = dep_groupId + ':' + maven_coords['artifactId']
    logging.debug('artifact_key: ' + str(artifact_key))

    return artifact_key

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

def get_maven_coordinates(
    dependency_elem,
    coordinate_tag_name,
    ignore_dependency_tags,
):

    maven_coords = get_xpath_elements(dependency_elem, './x:' + coordinate_tag_name)
    logging.debug('maven_coordianates: ' + coordinate_tag_name + ': ' + str(maven_coords))
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
    #     etree.parse(input_xml_file_path)
    single_effective_pom_data,
):
    """
    Find Maven Coordinates for all (potential) pom dependencies.

    The information collected about dependency includes Maven Coordinates:
        https://maven.apache.org/pom.html#Maven_Coordinates

    The search for dependencies includes (hopefully, all) locations
    where Maven Coordinates can be specified.
    """

    project_element = single_effective_pom_data.getroot()

    all_artifactId_elems = get_xpath_elements(project_element, './/x:artifactId')

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

        # Tag `deployable` is used by `cargo` Maven plugin configuration.
        pom_xml_ns_prefix + 'deployable',
    ]

    single_pom_dependencies = {}
    for artifactId_elem in all_artifactId_elems:
        dependency_elem = artifactId_elem.getparent()
        elem_xpath = single_effective_pom_data.getpath(dependency_elem)

        pom_dependency = {}

        logging.debug('dependency_elem: ' + str(dependency_elem) + ': ' + str(etree.tostring(dependency_elem)))

        for coordinate_tag_name in [
            'groupId',
            'artifactId',
            'version',
        ]:
            pom_dependency[coordinate_tag_name] = get_maven_coordinates(
                dependency_elem,
                coordinate_tag_name,
                ignore_dependency_tags,
            )

        # Tag `artifactId` cannot be missed.
        assert(pom_dependency['artifactId'] != None)

        # Seve dependency.
        # There can be repeatative dependencies
        # (i.g. refrerenced by more than one tag in pom file).
        artifact_key = get_artifact_key(pom_dependency)
        if artifact_key not in single_pom_dependencies:
            single_pom_dependencies[artifact_key] = {}
        assert(elem_xpath not in single_pom_dependencies[artifact_key])
        single_pom_dependencies[artifact_key][elem_xpath] = pom_dependency

    return single_pom_dependencies

#------------------------------------------------------------------------------
#

def get_single_pom_maven_coordinates(
    # This object is output of this function call:
    #     etree.parse(input_xml_file_path)
    single_effective_pom_data,
):
    """
    Find Maven Coordinates of pom.

    The information collected about dependency includes Maven Coordinates:
        https://maven.apache.org/pom.html#Maven_Coordinates
    """

    root_element = single_effective_pom_data.getroot()
    logging.debug('root_element: ' + str(root_element) + ': ' + str(etree.tostring(root_element)))

    # NOTE: In case of parent pom,
    #       the root element is not `project` but `projects`.
    # TODO: We assume that the actual pom file of this root is the first,
    #       but we do not ensure it anyhow.
    project_element = None
    if root_element.tag == 'projects':
        project_elements = get_xpath_elements(root_element, './/x:project')
        project_element = project_elements[0]
    else:
        project_element = root_element
    logging.debug('project_element: ' + str(project_element) + ' tag: ' + str(project_element.tag) + ' contents: ' + str(etree.tostring(project_element)))
    assert(project_element.tag == pom_xml_ns_prefix + 'project')

    pom_maven_coordinates = {}

    for coordinate_tag_name in [
        'groupId',
        'artifactId',
        'version',
    ]:
        pom_maven_coordinates[coordinate_tag_name] = get_maven_coordinates(
            project_element,
            coordinate_tag_name,
            ignore_dependency_tags = [],
        )
        # For pom Maven Coordinates all main tags must be defined.
        assert(pom_maven_coordinates[coordinate_tag_name] != None)

    return pom_maven_coordinates

#------------------------------------------------------------------------------
#

def load_dependency_list_data(
    salt_pillar,
    repo_id,
    pom_rel_path,
    output_pom_data_dir,
):

    pom_abs_path = os.path.join(
        get_repo_path(
            repo_id,
            salt_pillar,
        ),
        normalize_pom_rel_path(
            pom_rel_path,
        ),
    )
    logging.debug('pom_abs_path :' + str(pom_abs_path))
    assert(os.path.isabs(pom_abs_path))

    logging.debug('output_pom_data_dir :' + str(output_pom_data_dir))
    assert(os.path.isabs(output_pom_data_dir))

    output_dependency_list_txt_path = os.path.join(
        output_pom_data_dir,
        repo_id,
        pom_rel_path + '.dependency_list.txt',
    )

    # NOTE: Make sure output path is absolute
    #       to avoid Maven writting into subdirectories
    #       of Maven projects.
    logging.debug('output_dependency_list_txt_path: ' + str(output_dependency_list_txt_path))
    assert(os.path.isabs(output_dependency_list_txt_path))


    # NOTE: This step is not required (for efficiencey) because
    #       next command will also be able to do resolve and
    #       download dependencies but only if needed.
    if False:
        # Resolve (download) all dependencies locally so that next command
        # can work offline.
        call_subprocess(
            command_args = [
                'mvn',
                '-f',
                pom_abs_path,
                'dependency:resolve',
            ],
        )

    # Get list of all dependencies.
    exit_data = call_subprocess(
        command_args = [
            'mvn',
            '-f',
            pom_abs_path,
            'dependency:list',
            # NOTE: At the moment only direct (not transitive)
            #       dependencies are included.
            #       If transitive dependencies are included,
            #       verification with XML references fails (because
            #       XML references are direct dependencies by definition).
            # TODO: Create another list with transitive dependencies
            #       which won't be checked agains references in XML file.
            '-DexcludeTransitive=true',
            '-DoutputFile=' + output_dependency_list_txt_path,
        ],
    )

    # Load `dependency:list` output.
    dependency_items = {}
    with open(output_dependency_list_txt_path, 'r') as dependency_list_file:

        # Regex to capture artifact reported by Maven.
        #   org.hibernate.javax.persistence:hibernate-jpa-2.0-api:jar:1.0.1.Final:compile
        artifact_regex = re.compile('^\s*([^:\s]*):([^:\s]*):([^:\s]*):([^:\s]*):([^:\s]*)$')

        for str_line in dependency_list_file:
            artifact_match = artifact_regex.match(str_line)

            if artifact_match:
                logging.info('line matched: ' + str(str_line))

                dependency_groupId = artifact_match.group(1)
                dependency_artifactId = artifact_match.group(2)
                dependency_package = artifact_match.group(3)
                dependency_version = artifact_match.group(4)
                dependency_scope = artifact_match.group(5)

                dependency_item = {
                    'groupId': dependency_groupId,
                    'artifactId': dependency_artifactId,
                    'package': dependency_package,
                    'version': dependency_version,
                    'scope': dependency_scope,
                }

                artifact_key = get_artifact_key(dependency_item)

                logging.info('dependency_item: ' + str(dependency_item))

                dependency_items[artifact_key] = dependency_item
            else:
                logging.debug('line didn\'t match: ' + str(str_line))

    return dependency_items

#------------------------------------------------------------------------------
#

def get_key_values(req_key_id, input_data):

    """
    Search complex object for dict with values of keys equal to `req_key_id`.
    """

    if (
        isinstance(input_data, list)
        or
        isinstance(input_data, types.GeneratorType)
    ):

        values_list = []

        # Continue searching for dicts in values of list element.
        for seq_item in input_data:
            values_list += get_key_values(req_key_id, seq_item)

        return values_list

    if isinstance(input_data, dict):

        values_list = []

        if req_key_id in input_data.keys():
            # Get value for `req_key_id`.
            values_list = [ input_data[req_key_id] ]

        # Continue searching for dicts in values of each key.
        for key_id in input_data.keys():
            values_list += get_key_values(req_key_id, input_data[key_id])

        return values_list

    # Simple value means no key `req_key_id`.
    return []

#------------------------------------------------------------------------------
#

def get_overall_result(
    report_data,
):

    # If any `last_stage_result` is false, overall result is false.
    overall_result = True
    total_counter = 0
    failed_conter = 0
    for verification_result in get_key_values('last_stage_result', report_data):
        total_counter += 1
        if not verification_result:
            overall_result = False
            failed_conter += 1

    if not overall_result:
        logging.error('last_stage_result: FAILED out of TOTAL: ' + str(failed_conter) + ' out of ' + str(total_counter))

    return overall_result

#------------------------------------------------------------------------------
#

def get_effective_pom_file_data(
    repo_id,
    pom_file_data,
    output_pom_data_dir,
):

    logging.debug('output_pom_data_dir: ' + str(output_pom_data_dir))
    effective_pom_abs_path = os.path.join(
        output_pom_data_dir,
        repo_id,
        os.path.join(
            os.path.dirname(pom_file_data['relative_path']),
            'effective.' + os.path.basename(pom_file_data['relative_path']),
        ),
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

###############################################################################
#

class ItemDescriptor:

    #--------------------------------------------------------------------------
    #

    # Order of stages each descriptor goes through.
    # As soon as decriptor passes each stage,
    # it is not processed on this stage again
    # until the stage is manually reset.
    # Each descriptor optimistically tries to pass all stages in a row
    # recording all errors/warnings.
    # In order to be processed, descriptor has to go through all stages.
    stage_order = [
        'inited',
        'transferred',
        'loaded',
        'verified',
    ]

    # Shared Salt pillar among all objects.
    salt_pillar = None

    # Shared output directory.
    output_pom_data_dir = None

    # Shared report among all objects.
    report_data = None

    # Shared descriptor coordinates order among all objects.
    desc_coords_order = None

    #--------------------------------------------------------------------------
    #

    def __init__(
        self,
        salt_pillar,
        output_pom_data_dir,
        report_data,
        data_item,
    ):

        self.salt_pillar = salt_pillar
        self.output_pom_data_dir = output_pom_data_dir
        self.report_data = report_data
        self.data_item = data_item

        # Descriptor coordinates in `report_data`.
        self.desc_coords = None

        if 'step_logs' not in self.data_item:
            self.data_item['step_logs'] = {}

    #--------------------------------------------------------------------------
    #

    def add_step_log(
        self,
        step_name,
        step_result,
        step_message = None,
    ):
        step_logs = self.data_item['step_logs']

        assert(isinstance(step_result, types.BooleanType))

        if step_name not in step_logs:
            step_logs[step_name] = {
                'step_result': step_result,
                'step_messages': [],
            }
        else:
            # Never overwrite `False` result.
            # It can only be deleted completely (at the start of new run).
            if step_logs[step_name]['step_result']:
                step_logs[step_name]['step_result'] = step_result

        if step_message:
            step_message_str = str(step_message)
            # Avoid duplicated `step_messages`.
            if step_message_str not in step_logs[step_name]['step_messages']:
                step_logs[step_name]['step_messages'].append(step_message_str)

    #--------------------------------------------------------------------------
    #

    def get_inited(
        self,
    ):
        return True

    #--------------------------------------------------------------------------
    #

    def get_transferred(
        self,
    ):
        return True

    #--------------------------------------------------------------------------
    #

    def set_field(
        self,
        field_name,
        field_value,
    ):
        assert(isinstance(self.data_item, dict))

        self.data_item[field_name] = field_value

    #--------------------------------------------------------------------------
    #

    def is_field_true(
        self,
        field_name,
    ):
        logging.debug(self.get_desc_coords_string() + 'visit field `' + field_name + '`')
        assert(isinstance(self.data_item, dict))

        if field_name not in self.data_item:
            # Initialize field.
            logging.debug(self.get_desc_coords_string() + 'init field `' + field_name + '`')
            self.data_item[field_name] = False
        else:
            logging.debug(self.get_desc_coords_string() + 'get field `' + field_name + '`: ' + str(self.data_item[field_name]))

        assert(isinstance(self.data_item[field_name], types.BooleanType))

        return self.data_item[field_name]

    #--------------------------------------------------------------------------
    #

    def progress_stage(
        self,
        stage_id,
    ):

        """
        Try to excecute stage which failed before.

        Results:
            True:
                There was an execution with successful result.
            False:
                Either old result was already successful or
                new result has failed again.
        """

        field_name = 'is_' + stage_id
        function_name = 'get_' + stage_id

        previous_stage_result = self.is_field_true(field_name)
        logging.debug('previous_stage_result: ' + str(previous_stage_result))

        # Never repeat successfully completed stages.
        if not previous_stage_result:

            # NOTE: Function already "remembers" its object
            #       (no need for `self` argument).
            function_object = getattr(self, function_name)
            logging.debug('function_object: ' + str(function_object))
            function_object()

            # We don't care what function returns.
            # We get results of all steps -
            # any failed step makes stage failed.
            stage_result = self.get_descriptor_status()
            logging.debug('stage_result: ' + str(stage_result))

            self.set_field(field_name, stage_result)
            self.set_field('last_stage_run', stage_id)
            self.set_field('last_stage_result', stage_result)

            if stage_result:
                logging.debug(self.get_desc_coords_string() + 'stage `' + stage_id + '` succeeded')
                # It is both success and progress.
                return True
            else:
                logging.debug(self.get_desc_coords_string() + 'stage `' + stage_id + '` failed')
                return False

        else:
            self.set_field('last_stage_result', previous_stage_result)

            logging.debug(self.get_desc_coords_string() + 'stage `' + stage_id + '` skipped as successfully competed')
            # Stage result has not changed - indicate no progress.
            return False

    #--------------------------------------------------------------------------
    #

    def process_all_stages(
        self,
    ):

        # Initialize as no progress - prepare for the worst.
        self.set_field('is_progressed', False)

        # Clean every `step_name` which has `False` result.
        # TODO: Put it in a separate function.
        step_logs = self.data_item['step_logs']
        step_names = step_logs.keys()
        for step_name in step_names:
            logging.debug('step_logs: ' + step_name + ': ' + str(step_logs[step_name]))
            if not step_logs[step_name]['step_result']:

                # If there was a failed `step_name`,
                # `last_stage_result` must be False.
                assert(not self.is_field_true('last_stage_result'))
                # If there was a failed `step_name`,
                # descriptor status must be False.
                assert(not self.get_descriptor_status())

                logging.debug('clear failed step_log: ' + str(step_name))
                del step_logs[step_name]

        # Clean every `stage_id` which has `False` result.
        # This will make stage re-run again.
        # TODO: Put it in a separate function.
        for stage_id in self.stage_order:
            field_name = 'is_' + stage_id
            if not self.is_field_true(field_name):
                # TODO: Put stages into separate sub-dict.
                field_name = 'is_' + stage_id

                logging.debug('clear failed stage: ' + str(stage_id))
                del self.data_item[field_name]

        # Clean all `False` `last_stage_result`.
        if not self.is_field_true('last_stage_result'):
            del self.data_item['last_stage_result']
        else:
            assert(self.get_descriptor_status())

        # Run through all stages.
        for stage_id in self.stage_order:
            stage_progressed = self.progress_stage(stage_id)

            # Update progress flag when there is a progress.
            if stage_progressed:
                self.set_field('is_progressed', stage_progressed)
            else:
                # Do not continue on failure.
                field_name = 'is_' + stage_id
                if not self.is_field_true(field_name):
                    logging.error(self.get_desc_coords_string() + 'stuck at stage ' + str(stage_id))
                    break

        # Return whether there were any progress.
        return self.is_field_true('is_progressed')

    #--------------------------------------------------------------------------
    #

    def get_desc_coords_string(
        self,
    ):
        """
        Get string of coordinates within report.

        This generic function is useful to indicate location
        of the descriptor in report.
        """

        desc_coords_string = ''
        for desc_coord_name in self.desc_coords_order:
            if desc_coord_name in self.desc_coords:
                desc_coords_string += desc_coord_name + ' = ' + self.desc_coords[desc_coord_name] + ': '
            else:
                desc_coords_string += desc_coord_name + ': '

        return desc_coords_string

    #------------------------------------------------------------------------------
    #

    def get_descriptor_status(
        self,
    ):

        descriptor_status = True
        for step_result in get_key_values(
            'step_result',
            self.data_item,
        ):
            if not step_result:
                descriptor_status = False

        logging.debug('get_descriptor_status(): ' + str(descriptor_status))

        return descriptor_status

    #--------------------------------------------------------------------------
    #

    def is_coord_exists(
        self,
        artifact_key,
        maven_coord,
        side_artifact,
        side_artifact_src,
        side_str,
    ):

        # TODO: Make it configurable and generic.
        # List of Maven cordinate which is allowed to be missing or not matched
        # per `source_type` (applicable to `artifact_descriptor`).
        excepted_maven_coords = {
            'unmodified-open': [
                'version',
            ],
        }

        if maven_coord not in side_artifact:
            msg = self.get_desc_coords_string() + 'artifact ' + str(artifact_key) + '` has no field `' + str(maven_coord) + '` in ' + str(side_artifact_src)
            result = False

            # NOTE: If `artifact_key` exists, it shall have `source_type`
            #       which is done by validation during loading.
            if artifact_key in self.report_data['artifact_descriptors']:
                source_type = self.report_data['artifact_descriptors'][artifact_key]['source_type']
            else:
                msg += " - artifact `" + str(artifact_key) + "` is NOT defined in `artifact_descriptors`"
                source_type = None

            # Check whether Maven coord is excepted.
            if source_type in excepted_maven_coords.keys():
                if maven_coord in excepted_maven_coords[source_type]:
                    # Result is true but keep all records.
                    result = True
                    msg += " - BUT field `" + str(maven_coord) + "` is excepted for `" + str(source_type) + "`"

            if not result:
                logging.error('side_artifact: ' + str(side_artifact))
                msg += " - field `" + str(maven_coord) + "` is NOT excepted"

            logging.error(msg)
            self.add_step_log(
                '`' + artifact_key + '`.`' + maven_coord + '`_exists_in_' + side_str,
                result,
                msg,
            )
            return False

        return True

    #--------------------------------------------------------------------------
    #

    def verify_artifact_maven_coordinates(
        self,
        artifact_key,
        left_coords_list,
        left_coords_src,
        right_coords_list,
        right_coords_src,
        force_result = None,
    ):
        # Now we assume that `left_coords_list` and `right_coords_list`
        # are _lists_ where (to avoid verification error)
        # at least one from left should match
        # at least one from right.
        # More specifically, it applies only to `version` value.
        # All `groupId` and `artifactId` should match.

        has_version_match = False

        for left_coords in left_coords_list:

            for right_coords in right_coords_list:

                # TODO: What if there are more than one version used?
                #       There is only one value in `current_version`.
                # TODO: If there are more than one version, there should also be
                #       verification of unused versions in `artifact_descriptors`.
                for maven_coord in [
                    'groupId',
                    'artifactId',
                    'version',
                ]:

                    if not self.is_coord_exists(
                        artifact_key,
                        maven_coord,
                        left_coords,
                        left_coords_src,
                        'left',
                    ):
                        break

                    if not self.is_coord_exists(
                        artifact_key,
                        maven_coord,
                        right_coords,
                        right_coords_src,
                        'right',
                    ):
                        break

                    if maven_coord in [
                        'groupId',
                        'artifactId',
                    ]:
                        if left_coords[maven_coord] != right_coords[maven_coord]:
                            step_result = False
                            if force_result is not None:
                                step_result = force_result
                            msg = self.get_desc_coords_string() + 'artifact `' + str(artifact_key) + '` has different ' + str(maven_coord) + ' = `' + str(left_coords[maven_coord]) + '` in ' + str(left_coords_src) + ' but ' + str(maven_coord) + ' = `' + str(right_coords[maven_coord]) + '` in ' + str(right_coords_src)
                            logging.error(msg)
                            self.add_step_log(
                                '`' + artifact_key + '`.`' + maven_coord + '`_is_matched',
                                step_result,
                                msg,
                            )
                    else:
                        assert(maven_coord == 'version')
                        if left_coords[maven_coord] == right_coords[maven_coord]:
                            has_version_match = True

        if not has_version_match:
            step_result = False
            if force_result is not None:
                step_result = force_result
            msg = self.get_desc_coords_string() + 'artifact `' + str(artifact_key) + '` has no version match in `' + str(left_coords_src) + '` = `' + str(left_coords_list) + '` with any of `' + str(right_coords_src) + '` = `' + str(right_coords_list) + '`'
            logging.error(msg)
            self.add_step_log(
                '`' + artifact_key + '`.version_is_matched',
                step_result,
                msg,
            )

    #--------------------------------------------------------------------------
    #

    def is_ignorable_pom_file(
        self,
        repo_id,
        pom_rel_path,
        pom_file_data,
        artifact_descriptor,
        artifact_key,
    ):

        if pom_file_data['is_exception']:
            msg = self.get_desc_coords_string() + 'artifact ' + artifact_key + '` refers to excepted pom file `' + pom_rel_path + '` in `' + repo_id + '` repository'
            logging.error(msg)
            self.add_step_log(
                'pom_`' + str(repo_id) + '`:`' + str(pom_rel_path) + '`_is_not_exception',
                False,
                msg,
            )
            return True

        if not pom_file_data['is_tracked']:
            msg = self.get_desc_coords_string() + 'artifact ' + artifact_key + '` refers to untracked pom file `' + pom_rel_path + '` in `' + repo_id + '` repository'
            logging.error(msg)
            self.add_step_log(
                'pom_`' + str(repo_id) + '`:`' + str(pom_rel_path) + '`_is_tracked',
                False,
                msg,
            )
            return True

    #--------------------------------------------------------------------------
    #

#------------------------------------------------------------------------------
#

class ArtifactDescriptor(ItemDescriptor):

    #--------------------------------------------------------------------------
    #

    def __init__(
        self,
        salt_pillar,
        output_pom_data_dir,
        report_data,
        artifact_key,
        artifact_descriptor,
    ):
        ItemDescriptor.__init__(
            self,
            salt_pillar,
            output_pom_data_dir,
            report_data,
            data_item = artifact_descriptor,
        )

        self.desc_coords_order = [
            'artifact_descriptors',
            'artifact_key',
        ]

        self.desc_coords = {
            'artifact_key': artifact_key,
        }

    #--------------------------------------------------------------------------
    #

    def get_inited(
        self,
    ):

        func_result = True

        if not ItemDescriptor.get_inited(self):
            func_result = False

        # Derive `artifactId` and `groupId` from `artifact_key`.
        parts = self.desc_coords['artifact_key'].split(":")
        if len(parts) != 2:
            msg = self.get_desc_coords_string() + '`artifact_key` does not split in two parts by `:`: ' + str(self.desc_coords['artifact_key'])
            logging.error(msg)
            self.add_step_log(
                'is_`artifact_key`_splittable',
                False,
                msg,
            )
            func_result = False
        else:
            derivedGroupId = parts[0]
            derivedArtifactId = parts[1]

            if derivedGroupId:
                self.data_item['groupId'] = derivedGroupId
            else:
                self.data_item['groupId'] = None

            if derivedArtifactId:
                self.data_item['artifactId'] = derivedArtifactId
            else:
                self.data_item['artifactId'] = None

        # Verify existence of key fields.

        if 'used' not in self.data_item:
            msg = self.get_desc_coords_string() + 'field `used` is not present'
            logging.error(msg)
            self.add_step_log(
                'is_`used`_field_present',
                False,
                msg,
            )
            func_result = False

        elif not isinstance(self.data_item['used'], types.BooleanType):
            msg = self.get_desc_coords_string() + 'field `used` is not boolean'
            logging.error(msg)
            self.add_step_log(
                'is_`used`_field_boolean',
                False,
                msg,
            )
            func_result = False

        if 'source_type' not in self.data_item:
            msg = self.get_desc_coords_string() + 'field `source_type` is not present'
            logging.error(msg)
            self.add_step_log(
                'is_`source_type`_field_present',
                False,
                msg,
            )
            func_result = False

        # Adaptor: change type of `current_version` field to list of strings.
        if 'current_version' in self.data_item:
            if isinstance(self.data_item['current_version'], dict):
                # For dictionary use only keys.
                self.data_item['current_version'] = self.data_item['current_version'].keys()
            # NOTE: This is not `elif` - process list of keys from the `dict` above (if it was).
            if isinstance(self.data_item['current_version'], list):
                # Take all items as is - nothing to do.
                pass
            elif isinstance(self.data_item['current_version'], basestring):
                self.data_item['current_version'] = [ self.data_item['current_version'] ]
            elif isinstance(self.data_item['current_version'], None):
                self.data_item['current_version'] = [ self.data_item['current_version'] ]
            else:
                # Catch all approach (works at least for a number).
                self.data_item['current_version'] = [ str(self.data_item['current_version']) ]
        else:
            # Use list with None value. This is required to generate
            # at least one full set of Maven coordinates later.
            self.data_item['current_version'] = [ None ]

        # Adaptor: change every item in `current_version` to string value
        #          except `None`.
        version_items = []
        for version_item in self.data_item['current_version']:
            if version_item is not None:
                version_items.append(str(version_item))
            else:
                version_items.append(version_item)
        self.data_item['current_version'] = version_items

        # Check validity of `source_type`.
        if self.data_item['source_type'] in [
            'available-closed',
            'modified-open',
        ]:

            # Make sure pom file is properly configured.

            if 'repository_id' not in self.data_item:
                msg = self.get_desc_coords_string() + 'field `repository_id` is not present'
                logging.error(msg)
                self.add_step_log(
                    'is_`repository_id`_field_present',
                    False,
                    msg,
                )
                func_result = False

            if 'pom_relative_path' not in self.data_item:
                msg = self.get_desc_coords_string() + 'field `pom_relative_path` is not present'
                logging.error(msg)
                self.add_step_log(
                    'is_`pom_relative_path`_field_present',
                    False,
                    msg,
                )
                func_result = False
            elif not isinstance(self.data_item['pom_relative_path'], basestring):
                msg = self.get_desc_coords_string() + 'field `pom_relative_path` is not string'
                logging.error(msg)
                self.add_step_log(
                    'is_`pom_relative_path`_field_string',
                    False,
                    msg,
                )
                func_result = False

        else:
            if self.data_item['source_type'] not in [
                'unmodified-open',
                'unavailable-closed',
            ]:
                msg = self.get_desc_coords_string() + 'field `source_type` can only be: ' + str([
                    'available-closed',
                    'modified-open',
                    'unmodified-open',
                    'unavailable-closed',
                ])
                logging.error(msg)
                self.add_step_log(
                    'is_`source_type`_valid',
                    False,
                    msg,
                )
                func_result = False

        # TODO: Normally, field `current_version` should always be supplied.
        # Field `current_version` must exists in case of:
        #   `unmodified-open`
        if 'source_type' in self.data_item and self.data_item['source_type'] not in [
            'unmodified-open'
        ]:
            if 'current_version' not in self.data_item:
                msg = self.get_desc_coords_string() + 'field `current_version` is not present'

                logging.error(msg)
                self.add_step_log(
                    'is_`current_version`_field_present',
                    False,
                    msg,
                )
                func_result = False
            elif not isinstance(self.data_item['current_version'], list):
                msg = self.get_desc_coords_string() + 'field `current_version` is not list'
                logging.error(msg)
                self.add_step_log(
                    'is_`current_version`_field_list',
                    False,
                    msg,
                )
                func_result = False

        # Adapt: use `maven_coordinates` key to keep them in list (as for pom).
        # Transform multiple `current_version` into products:
        # { groupId, artifactId, version_1 }
        # { groupId, artifactid, version_2 }
        # ...
        # { groupId, artifactid, version_N }
        maven_coords = []
        for current_version in self.data_item['current_version']:
            maven_coords += [
                {
                    'artifactId': self.data_item['artifactId']
                    ,
                    'groupId': self.data_item['groupId']
                    ,
                    'version': current_version
                }
            ]
        self.data_item['maven_coordinates'] = maven_coords

        return func_result

    #--------------------------------------------------------------------------
    #

    def get_loaded(
        self,
    ):

        salt_pillar = self.salt_pillar
        output_pom_data_dir = self.output_pom_data_dir
        artifact_descriptor = self.data_item
        artifact_key = self.desc_coords['artifact_key']
        report_data = self.report_data

        if not artifact_descriptor['used']:
            logging.warning('Artifact descriptor is not used: ' + str(artifact_key))
            return True

        # Only internal artifacts are supposed to have
        # `repository_id` and `pom_relative_path` keys
        # (artifacts which are built from sources in project repositories).
        # TODO: Add reference to docs.
        if artifact_descriptor['source_type'] in [
            'available-closed',
            'modified-open',
        ]:

            repo_id = artifact_descriptor['repository_id']
            pom_rel_path = artifact_descriptor['pom_relative_path']

            # Get initial pom file info.
            pom_file_data = get_pom_file_data(
                repo_id,
                pom_rel_path,
                salt_pillar,
                self,
            )
            if not pom_file_data:
                msg = self.get_desc_coords_string() + 'pom data cannot be loaded: ' + str(pom_file_data)
                logging.error(msg)
                self.add_step_log(
                    'is_pom_data_loaded',
                    False,
                    msg,
                )
                return False

            if self.is_ignorable_pom_file(
                repo_id,
                pom_rel_path,
                pom_file_data,
                artifact_descriptor,
                artifact_key,
            ):
                return False

            # Generate effective pom file.
            pom_file_data = get_effective_pom_file_data(
                repo_id,
                pom_file_data,
                output_pom_data_dir,
            )

            # Load effective pom XML data.
            single_effective_pom_data = load_xml_file(
                pom_file_data['effective_absolute_path'],
            )

            # Get Maven Coordinates.
            maven_coords = get_single_pom_maven_coordinates(
                single_effective_pom_data,
            )
            # Record Maven Coordinates as a list to adapt fror processing.
            pom_file_data['maven_coordinates'] = [ maven_coords ]

            # Record data loaded from pom into artifact descriptor.
            artifact_descriptor['pom_data'] = pom_file_data

        return True

    #--------------------------------------------------------------------------
    #

    def get_verified(
        self,
    ):

        artifact_descriptor = self.data_item
        artifact_key = self.desc_coords['artifact_key']
        report_data = self.report_data

        if not artifact_descriptor['used']:
            logging.debug('Skip unused artifact: ' + str(artifact_key))
            return True

        # Only internal artifacts are supposed to have
        # `repository_id` and `pom_relative_path` keys
        # (artifacts which are built from sources in project repositories).
        # TODO: Add reference to docs.
        if artifact_descriptor['source_type'] in [
            'available-closed',
            'modified-open',
        ]:

            repo_id = artifact_descriptor['repository_id']
            pom_rel_path = artifact_descriptor['pom_relative_path']

            if repo_id not in report_data['pom_files']:
                msg = self.get_desc_coords_string() + 'artifact ' + artifact_key + '` refers to non-existing repository id `' + repo_id + '`'
                logging.error(msg)
                self.add_step_log(
                    'is_repo_id_valid',
                    False,
                    msg,
                )
                return False

            if pom_rel_path not in report_data['pom_files'][repo_id]:
                msg = self.get_desc_coords_string() + 'artifact ' + artifact_key + '` refers to non-existing pom file `' + pom_rel_path + '` in `' + repo_id + '` repository'
                logging.error(msg)
                self.add_step_log(
                    'is_pom_file_available',
                    False,
                    msg,
                )
                return False

            # NOTE: There are two pom file information:
            #       - one is loaded from pom files searched automatically
            #       - one is loaded from pom files declared in artifact descriptor
            #       The following verification is done against
            #       the former one (the one searched automatically).
            pom_file_data = report_data['pom_files'][repo_id][pom_rel_path]
            if 'is_inited' not in pom_file_data or not pom_file_data['is_inited']:
                msg = self.get_desc_coords_string() + 'pom_file ' + str(repo_id) + '-' + str(pom_rel_path) + ' is not yet inited'
                logging.error(msg)
                self.add_step_log(
                    'is_pom_file_`' + str(repo_id) + '-' + str(pom_rel_path) + '`_inited',
                    False,
                    msg,
                )
                return

            # Increment reference counter.
            if 'reference_counter' not in pom_file_data:
                pom_file_data['reference_counter'] = 0
            pom_file_data['reference_counter'] += 1

            # Verify Maven Coordinates
            self.verify_artifact_maven_coordinates(
                artifact_key,
                artifact_descriptor['maven_coordinates'],
                'artifact_descriptors',
                artifact_descriptor['pom_data']['maven_coordinates'],
                'pom file of artifact_descriptors',
            )

        return True

    #--------------------------------------------------------------------------
    #

#------------------------------------------------------------------------------
#

class PomDescriptor(ItemDescriptor):

    #--------------------------------------------------------------------------
    #

    def __init__(
        self,
        salt_pillar,
        output_pom_data_dir,
        report_data,
        repo_id,
        pom_rel_path,
        pom_file,
    ):

        logging.debug('pom_file: ' + str(pom_file))

        ItemDescriptor.__init__(
            self,
            salt_pillar,
            output_pom_data_dir,
            report_data,
            data_item = pom_file,
        )

        self.desc_coords_order = [
            'pom_files',
            'repo_id',
            'pom_rel_path',
        ]

        self.desc_coords = {
            'repo_id': repo_id,
            'pom_rel_path': pom_rel_path,
        }

    #--------------------------------------------------------------------------
    #

    def get_inited(
        self,
    ):

        func_result = True

        if not ItemDescriptor.get_inited(self):
            func_result = False

        # Verify existence of key fields.

        if 'relative_path' not in self.data_item:
            msg = self.get_desc_coords_string() + 'field `relative_path` is not present'
            logging.error(msg)
            self.add_step_log(
                'is_`relative_path`_field_present',
                False,
                msg,
            )
            func_result = False
        elif not isinstance(self.data_item['relative_path'], basestring):
            msg = self.get_desc_coords_string() + 'field `relative_path` is not present'
            logging.error(msg)
            self.add_step_log(
                'is_`relative_path`_field_string',
                False,
                msg,
            )
            func_result = False

        return False

    #--------------------------------------------------------------------------
    #

    def get_transferred(
        self,
    ):
        # TODO: Use `self` variables instead.
        #       These are just an adaptors for old code.
        repo_id = self.desc_coords['repo_id']
        pom_rel_path = self.desc_coords['pom_rel_path']
        pom_abs_path = self.data_item['absolute_path']

        if self.data_item['is_exception']:
            msg = self.get_desc_coords_string() + 'pom is exception: ' + pom_abs_path
            logging.warning(msg)
            self.add_step_log(
                'is_pom_excepted',
                # NOTE: When loading pom file, this is not a failure.
                #       Just note about known exception.
                True,
                msg,
            )
            return

        if not self.data_item['is_tracked']:
            msg = self.get_desc_coords_string() + 'pom is not tracked: ' + pom_abs_path
            logging.error(msg)
            self.add_step_log(
                'is_pom_tracked',
                False,
                msg,
            )
            return

        # Copy `pom.xml` file from original location to temporary one.
        pom_copy_rel_path = os.path.join(
            repo_id,
            pom_rel_path,
        )
        pom_copy_abs_path = os.path.join(
            self.output_pom_data_dir,
            pom_copy_rel_path,
        )
        try:
            os.makedirs(os.path.dirname(pom_copy_abs_path))
        except OSError, e:
            # 17: File exists.
            if e.errno != 17:
                raise
        shutil.copyfile(
            pom_abs_path,
            pom_copy_abs_path,
        )

        return True

    #--------------------------------------------------------------------------
    #

    def get_loaded(
        self,
    ):

        # TODO: Use `self` variables instead.
        #       These are just an adaptors for old code.
        salt_pillar = self.salt_pillar
        output_pom_data_dir = self.output_pom_data_dir
        report_data = self.report_data
        repo_id = self.desc_coords['repo_id']
        pom_rel_path = self.desc_coords['pom_rel_path']
        pom_descriptor = self.data_item

        pom_abs_path = pom_descriptor['absolute_path']

        if pom_descriptor['is_exception']:
            return

        if not pom_descriptor['is_tracked']:
            return

        # Generate effective pom file.
        pom_descriptor = get_effective_pom_file_data(
            repo_id,
            pom_descriptor,
            output_pom_data_dir,
        )

        # Load effective pom XML data.
        single_effective_pom_data = load_xml_file(
            pom_descriptor['effective_absolute_path'],
        )

        # Get Maven Coordinates.
        maven_coords = get_single_pom_maven_coordinates(
            single_effective_pom_data,
        )
        # Record Maven Coordinates as a list to adapt fror processing.
        pom_descriptor['maven_coordinates'] = maven_coords

        # Get all dependencies.
        single_pom_dependencies = get_single_pom_dependencies(
            single_effective_pom_data,
        )

        # Record data loaded from ar into artifact descriptor.
        pom_descriptor['xml_referenced_dependencies'] = single_pom_dependencies

        # Load dependency list data.
        dependency_items = load_dependency_list_data(
            salt_pillar,
            repo_id,
            pom_rel_path,
            output_pom_data_dir,
        )
        pom_descriptor['maven_dependency_list'] = dependency_items

        return report_data

    #--------------------------------------------------------------------------
    #

    def get_verified(
        self,
    ):

        # Sub-function for code used more than once.
        def populate_reference_data(
            report_data,
            artifact_key,
            dependency_item,
            key_source,
        ):

            derived_artifact_key = get_artifact_key(
                dependency_item,
            )
            assert(derived_artifact_key == artifact_key)

            # Check if artifact has descriptor.
            if artifact_key not in report_data['artifact_descriptors']:
                msg = self.get_desc_coords_string() + 'artifact ' + str(artifact_key) + ' is missing in `artifact_descriptors`'
                logging.error(msg)
                self.add_step_log(
                    'is_artifact_descriptor_`' + str(artifact_key) + '`_from_`' + key_source + '`_defined',
                    False,
                    msg,
                )
                return

            # Get artifact descriptor object.
            artifact_descriptor = report_data['artifact_descriptors'][artifact_key]
            if 'is_inited' not in artifact_descriptor or not artifact_descriptor['is_inited']:
                msg = self.get_desc_coords_string() + 'artifact ' + str(artifact_key) + ' is not yet inited'
                logging.error(msg)
                self.add_step_log(
                    'is_artifact_descriptor_`' + str(artifact_key) + '`_inited',
                    False,
                    msg,
                )
                return

            # NOTE: The counter includes both (not fair counter):
            #       - data generated from parsed XML
            #       - data generated from `dependency:list`
            # NOTE: We count references even if artifact may be not `used`.
            # Increment reference counter.
            if 'reference_counter' not in artifact_descriptor:
                artifact_descriptor['reference_counter'] = 0
            artifact_descriptor['reference_counter'] += 1

            # Ignore unused.
            if 'used' not in artifact_descriptor or not artifact_descriptor['used']:
                msg = self.get_desc_coords_string() + 'artifact ' + str(artifact_key) + ' is defined in `artifact_descriptors` but NOT declared as `used`'
                logging.error(msg)
                self.add_step_log(
                    'is_artifact_descriptor_`' + str(artifact_key) + '`_from_`' + key_source + '`_used',
                    False,
                    msg,
                )
                return

            # TODO: Be able to filter those `xml_referenced_dependencies`
            #       where version is not specified.
            #       At the moment script uses coarse-grained `True` for all
            #       cases when Maven coordinate does not specify version.
            #       It still does compare versions when they are specifed.
            if 'version' in dependency_item and dependency_item['version'] is not None:
                # No forced value - compare versions.
                force_result = None
            else:
                # Ignore missing `version`.
                force_result = True

            # Verify Maven Coordinates between `dependency_item` of pom file
            # `artifact_descriptor` specified by `artifact_key`
            self.verify_artifact_maven_coordinates(
                artifact_key = artifact_key,
                left_coords_list = [ dependency_item ],
                left_coords_src = 'pom_file',
                right_coords_list = artifact_descriptor['maven_coordinates'],
                right_coords_src = 'artifact_descriptor_maven_coordinates',
                force_result = force_result,
            )

        # Do not verify exceptions.
        if self.data_item['is_exception']:
            return

        # TODO: Use `self` variables instead.
        #       These are just an adaptors for old code.
        salt_pillar = self.salt_pillar
        output_pom_data_dir = self.output_pom_data_dir
        report_data = self.report_data
        repo_id = self.desc_coords['repo_id']
        pom_rel_path = self.desc_coords['pom_rel_path']
        pom_descriptor = self.data_item

        # Dependencies generated from parsed XML.
        key_source = 'xml_referenced_dependencies'
        for artifact_key in pom_descriptor[key_source].keys():

            logging.debug('artifact_key: ' + str(artifact_key))

            for xpath_key in pom_descriptor[key_source][artifact_key].keys():

                dependency_item = pom_descriptor[key_source][artifact_key][xpath_key]

                populate_reference_data(
                    report_data,
                    artifact_key,
                    dependency_item,
                    key_source + ':' + xpath_key,
                )

        # Dependencies generated from `dependency:list`.
        key_source = 'maven_dependency_list'
        for artifact_key in pom_descriptor[key_source].keys():

            logging.debug('artifact_key: ' + str(artifact_key))

            dependency_item = pom_descriptor[key_source][artifact_key]

            populate_reference_data(
                report_data,
                artifact_key,
                dependency_item,
                key_source,
            )

            # TODO: The problem with `dependency:list` is that output
            #       for parent pom.xml file gets overwrittent by the output
            #       of the last child defined in `modules`.
            #       In other words list of `artifact_key` from parent
            #       may not exists in `xml_referenced_dependencies` (even if
            #       it is listed as poper dependency in this pom.xml) because
            #       `maven_dependency_list` is for a child (not for
            #       this pom.xml).
            #       This is a temporary solution to ignore this case.
            #       TODO: This can be solved by generating output into
            #             files with non-absolute path. Then Maven itself
            #             splits things per pom.xml. However, this requires
            #             many changes.
            ignore_xml_ref_because_of_maven_bug = True

            # Make sure that each dependency from `dependency:list`
            # also exists in data from parsed XML.
            # NOTE: No need to check the other way around as parsed XML
            #       takes much more information (not true dependencies).
            # NOTE: At the moment only direct (not transitive)
            #       dependencies are included.
            if artifact_key not in pom_descriptor['xml_referenced_dependencies']:
                msg = self.get_desc_coords_string() + 'artifact ' + str(artifact_key) + ' is part of `maven_dependency_list` but not part of `xml_referenced_dependencies`'
                # TODO: Should we check if it is really a transitive
                #       dependency or error?
                logging.error(msg)
                self.add_step_log(
                    '`' + artifact_key + '`_is_in_maven_dependency_list',
                    ignore_xml_ref_because_of_maven_bug,
                    msg,
                )
            else:
                # Verify Maven Coordinates with each
                # XML entry corresponding to `artifact_key`.
                for xpath_key in pom_descriptor['xml_referenced_dependencies'][artifact_key].keys():
                    self.verify_artifact_maven_coordinates(
                        artifact_key,
                        [ dependency_item ],
                        'maven_dependency_list',
                        [ pom_descriptor['xml_referenced_dependencies'][artifact_key][xpath_key] ],
                        'xml_referenced_dependencies',
                        # TODO: This is too coarse-grained force of the result.
                        #       Figure out solution when comparision still fails
                        #       except when maven coordinates come from specific
                        #       tag (like `inclusion`). Currently, it will be
                        #       just a warning regrardless of the tag used.
                        force_result = True,
                    )

    #--------------------------------------------------------------------------
    #

###############################################################################
#

def associate_report_data_item_descriptors(
    salt_pillar,
    all_pom_files_per_repo,
    output_pom_data_dir,
    report_data,
):
    item_descriptors = []

    # Add missing `artifact_descriptors` from (updated) `salt_pillar`
    # into (stale) `report_data`.
    # This steps allows removing `artifact_descriptors` from report to
    # get them refreshed from Salt pillar.
    for artifact_key in salt_pillar['system_maven_artifacts']['artifact_descriptors'].keys():
        if artifact_key not in report_data['artifact_descriptors']:
            report_data['artifact_descriptors'][artifact_key] = salt_pillar['system_maven_artifacts']['artifact_descriptors'][artifact_key]

    # Run association loop for `artifact_descriptors`.
    for artifact_key in report_data['artifact_descriptors'].keys():
        logging.debug('artifact_key: ' + str(artifact_key))

        artifact_descriptor = report_data['artifact_descriptors'][artifact_key]

        item_descriptor = ArtifactDescriptor(
            salt_pillar,
            output_pom_data_dir,
            report_data,
            artifact_key,
            artifact_descriptor,
        )
        item_descriptors.append(item_descriptor)

        logging.debug(item_descriptor.get_desc_coords_string() + 'associated')

    # Add missing `pom_files` from (updated) `all_pom_files_per_repo`.
    # into (stale) `report_data`.
    # This steps allows removing `pom_files` from report to
    # get them refreshed from Salt pillar.

    for repo_id in all_pom_files_per_repo.keys():
        if repo_id not in report_data['pom_files']:
            report_data['pom_files'][repo_id] = {}

        pom_rel_paths = all_pom_files_per_repo[repo_id].keys()
        for pom_rel_path in pom_rel_paths:
            if pom_rel_path not in report_data['pom_files'][repo_id]:
                pom_file = all_pom_files_per_repo[repo_id][pom_rel_path]
                logging.debug('reload pom_file: ' + str(pom_file))
                report_data['pom_files'][repo_id][pom_rel_path] = pom_file

    # Loop through unprocessed `pom_files`.
    for repo_id in report_data['pom_files'].keys():
        logging.debug('repo_id: ' + str(repo_id))

        pom_rel_paths = report_data['pom_files'][repo_id].keys()
        logging.debug('pom_rel_paths: ' + str(pom_rel_paths))

        for pom_rel_path in pom_rel_paths:
            logging.debug('pom_rel_path: ' + str(pom_rel_path))

            pom_file = report_data['pom_files'][repo_id][pom_rel_path]

            # TODO: Rename `pom_file` into `pom_descriptor`.
            item_descriptor = PomDescriptor(
                salt_pillar,
                output_pom_data_dir,
                report_data,
                repo_id,
                pom_rel_path,
                pom_file,
            )
            item_descriptors.append(item_descriptor)

            logging.debug(item_descriptor.get_desc_coords_string() + 'associated')

    return item_descriptors

#------------------------------------------------------------------------------
#

def detect_progressed_descriptors(item_descriptors):

    for item_descriptor in item_descriptors:
        logging.debug(item_descriptor.get_desc_coords_string() + 'is_progressed = ' + str(item_descriptor.is_field_true('is_progressed')))
        if item_descriptor.is_field_true('is_progressed'):
            return True

    return False

###############################################################################
#

def get_incremental_report_wrapper(
    context,
):

    salt_pillar = load_yaml_file(
        context.input_salt_pillar_yaml_path,
    )

    all_pom_files_per_repo = load_yaml_file(
        context.input_all_pom_files_per_repo_yaml_path,
    )

    # If no report exists yet, create it.
    logging.debug('input_incremental_report_yaml_path: ' + str(context.input_incremental_report_yaml_path))
    if not os.path.exists(context.input_incremental_report_yaml_path):
        open(context.input_incremental_report_yaml_path, 'a').close()

    report_data = get_incremental_report(
        salt_pillar,
        all_pom_files_per_repo,
        context.output_pom_data_dir,
        context.input_incremental_report_yaml_path,
        context.output_incremental_report_yaml_path,
    )

    return report_data['overall_result']

#------------------------------------------------------------------------------
#

def get_incremental_report(
    salt_pillar,
    all_pom_files_per_repo,
    output_pom_data_dir,
    input_incremental_report_yaml_path,
    output_incremental_report_yaml_path,
):

    # Root directory for effective pom files (in current dir).
    output_pom_data_dir = output_pom_data_dir
    if not os.path.isabs(output_pom_data_dir):
        output_pom_data_dir = os.path.join(
            os.getcwd(),
            output_pom_data_dir,
        )

    # NOTE: Make sure output directory is absolute to avoid Maven
    #       writting output files files into subdirectories
    #       of original ones.
    assert(os.path.isabs(output_pom_data_dir))
    logging.debug('output_pom_data_dir: ' + str(output_pom_data_dir))

    # Create output directory.
    if not os.path.exists(output_pom_data_dir):
        os.makedirs(output_pom_data_dir)

    # Load initial report.
    report_data = load_yaml_file(
        input_incremental_report_yaml_path,
    )

    # Initialize `report_data` object.
    if not isinstance(report_data, dict):
        # Overwrite whatever is in `report_data` unless it is a dict.
        report_data = {}

    # Initialize top-level keys in `report_data`.
    if 'pom_files' not in report_data:
        # Initial data was captured during pom files search.
        report_data['pom_files'] = all_pom_files_per_repo
    if 'artifact_descriptors' not in report_data:
        # Initial data is loaded directly from pillar.
        report_data['artifact_descriptors'] = salt_pillar['system_maven_artifacts']['artifact_descriptors']
    # Set initial `overall_result` is true
    # (regardless of result in previous iteration)
    # because it is about to be recomputed.
    report_data['overall_result'] = True

    # Reduce size of the report by removing duplicate `step_messages`.
    for message_list in get_key_values('step_messages', report_data):
        assert(isinstance(message_list, list))
        init_count = len(message_list)
        message_list = list(set(message_list))
        reduced_count = len(message_list)
        logging.debug('init_count: ' + str(init_count) + ' ' + 'reduced_count: ' + str(reduced_count))

    # Associate specific descriptors
    # (either `pom_file` or `artifact_descriptor`).
    item_descriptors = associate_report_data_item_descriptors(
        salt_pillar,
        all_pom_files_per_repo,
        output_pom_data_dir,
        report_data,
    )

    # Save initial report.
    save_yaml_file(
        report_data,
        output_incremental_report_yaml_path,
    )

    # Loop while there are no more progress detected
    # (either `pom_file` or `artifact_descriptor`).
    progress_detected = True
    run_counter = 0
    while progress_detected:

        run_counter += 1

        # Process each `item_descriptor` incrementally saving data.
        total_descriptor_counter = len(item_descriptors)
        descriptor_counter = 0

        try:

            # Shuffle descriptors to avoid running the same long list every time.
            # The descriptors are already out of order anyway because they are
            # loaded using lists of keys in a dictionary.
            random.shuffle(item_descriptors)

            for item_descriptor in item_descriptors:
                descriptor_counter += 1

                # Debug only: process selected descriptors only.
                if False:
                    selected = False
                    selector = item_descriptor.desc_coords
                    if isinstance(item_descriptor, ArtifactDescriptor):
                        if selector['artifact_key'] == 'com.thalesgroup.border.cde:cde-dao':
                            selected = True
                    if isinstance(item_descriptor, PomDescriptor):
                        if selector['repo_id'] == 'cde' and selector['pom_rel_path'] == 'cde-dao/pom.xml':
                            selected = True
                    if not selected:
                        # Indicate no progress to have a chance to exit the loop.
                        item_descriptor.set_field('is_progressed', False)
                        continue

                item_descriptor.process_all_stages()
                logging.info('DONE: RUN #' + str(run_counter) + ': DESCRIPTOR #' + str(descriptor_counter) + ' of ' + str(total_descriptor_counter) + ': ' + item_descriptor.get_desc_coords_string())
                logging.debug('NEXT...')
        finally:

            save_yaml_file(
                report_data,
                output_incremental_report_yaml_path,
            )

        # Check if there is any progress to start again.
        progress_detected = detect_progressed_descriptors(item_descriptors)

    # TODO: Additonal verifications.
    #
    #--------------------------------------------------------------------------
    #
    # -
    # Verify that pom file is part of repository it is claimed to be.
    # For example, avoid searching top level repository result in list
    # of pom files pertaining to its submodules.
    #
    #--------------------------------------------------------------------------
    #
    # -
    # Add list of transitive dependencies (default for `depenencies:list`).
    # At the moment transitive dependencies are exluded for XML references
    # to be able to match all (non-transitive) dependencies.
    # However, it is good to have list of all dependencies for pom file
    # inside `artifact_descriptors`.
    #
    #--------------------------------------------------------------------------
    # One-to-one pom-artifact match for internal components
    #
    # -
    # Verify that every internal artifact from `artifact_descriptors`
    # has exactly one pom file in `pom_files` which builds this artifact.
    # Otherwise, keeping this record in component registry is useless.
    # -
    # Verify that every (non-excluded) pom file from `pom_files`
    # has corresponding artifact which it builds in `artifact_descriptors`.
    # Otherwise, our component registry is incomplete.
    #
    #--------------------------------------------------------------------------
    # Reactor build group
    #
    # -
    # Verify that all internal components are part of reactor build
    # (except, possibly, some component explicitly excluded from the build).
    # Otherwise, the component cannot be considered internal if it is not
    # produced during the build.
    # NOTE: There is no known precise and reliable way to ask Maven
    #       about all artifacts which are part of reactor build.
    #       Instead, running maven reactor build specifically for
    #       the artifact in question verifies that it is part of the build.
    # -
    # Verify that no two pom files from `pom_files` produce the same
    # artifact id (even if group id is different).
    # Otherwise, it is confusing.
    # -
    # Verify that every (non-excluded) pom file from `pom_files`
    # is part of reactor build.
    # NOTE: There is no known precise and reliable way to ask Maven
    #       about all pom files triggered by reactor build.
    #       Instead, running maven reactor build specifically for
    #       the artifact produced by the pom file together with
    #       verification that no other pom files build the same
    #       maven coordinates verifies that pom is part of the build.
    #
    #--------------------------------------------------------------------------
    #
    # -
    # Verify that all internal components that are exluded from the build
    # are not dependency of any other component.
    # Otherwise, the dependency is not being updated during the build.
    #
    #--------------------------------------------------------------------------
    #
    # -
    # Verify that all external artifacts in `artifact_descriptors` use
    # non-SNAPSHOT versions.
    #
    #--------------------------------------------------------------------------

    # Compute overall result.
    report_data['overall_result'] = get_overall_result(
        report_data,
    )
    logging.info('COMPLETED: overall_result: ' + str(report_data['overall_result']))

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

