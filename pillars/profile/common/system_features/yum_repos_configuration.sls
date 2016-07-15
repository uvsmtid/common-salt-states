
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% if 'use_local_yum_mirrors' in props %}
{% set use_local_yum_mirrors = props['use_local_yum_mirrors'] %}
{% else %}
{% set use_local_yum_mirrors = False %}
{% endif %}

# Map `os_platform` to relese verion number.
{% set os_platform_to_release_ver = {
        'fc21': 21,
        'fc22': 22,
        'fc23': 23,
        'fc24': 24,
        'rhel5': 5,
        'rhel7': 7,
    }
%}

system_features:

    yum_repos_configuration:

        feature_enabled: True

        # NOTE: URL is not specified.
        #       Instead, access to the repositories is done via root path
        #       of hostname associated with `local_yum_mirrors_role`, e.g.:
        #           http://local_yum_mirrors_role/
        # NOTE: Due to big content size, this directory is
        #       actually be a symlink to special storage location
        #       identified by `local_yum_mirrors_role_content_dir`.
        local_yum_mirrors_role_content_symlink: '/var/www/html/local_yum_mirrors_role/content'

        # Default location for local YUM repositories (on `local_yum_mirrors_role`).
        local_yum_mirrors_role_content_dir: '/home/local_yum_mirrors'

        yum_repositories:

            # Default OS repositories.
            base:
                # Installation type:
                # - conf_template
                #       Configuration using template file.
                installation_type: conf_template

                os_platform_configs:

                    {% for system_platform_id in [
                            'fc21',
                            'fc22',
                            'fc23',
                            'fc24',
                        ]
                    %}
                    # NOTE: Reusing the same config for `fc21` by `fc22`.
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/releases/{{ os_platform_to_release_ver[system_platform_id] }}/Everything/x86_64/os/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-{{ os_platform_to_release_ver[system_platform_id] }}-x86_64'

                        # NOTE: Repo key for Fedora is not managed because
                        #       it is fast moving platform and not used for
                        #       primary deployments.
                        #key_file_resource_id
                        #key_file_path

                        # NOTE: Sync only the latest Fedora release.
                        {% if system_platform_id == 'fc24' %}

                        # NOTE: At the moment Fedora 24 had `dnf` with
                        #       the bug which makes it impossible to
                        #       avoid using proxy per repository.
                        #       See details:
                        #           https://bugzilla.redhat.com/show_bug.cgi?id=1319786
                        {% if system_platform_id == 'fc24' %}
                        # TODO: It is set back to `TRUE` -
                        #       it seems the issue is resolved.
                        #       This `if` remains until testing confirms
                        #       there is no issues.
                        use_local_yum_mirrors: True
                        {% else %}
                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        {% endif %}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::fedora/linux/releases/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/Everything/x86_64/os/'
                        rsync_mirror_local_destination_path_prefix: 'fedora/linux/releases/'

                        {% endif %}

                    {% endfor %}

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/os/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        key_file_resource_id: rhel7_centos7_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/os/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/os/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/os/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        key_file_resource_id: rhel5_centos5_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/os/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

            # Default repositories with updates.
            updates:
                installation_type: conf_template

                os_platform_configs:

                    {% for system_platform_id in [
                            'fc21',
                            'fc22',
                            'fc23',
                            'fc24',
                        ]
                    %}
                    # NOTE: Reusing the same config for `fc21` by `fc22`.
                    {{ system_platform_id }}:
                        # Default is enabled.
                        # Keep it enabled for all updates.
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/updates/$releasever/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/fedora/linux/updates/{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-{{ os_platform_to_release_ver[system_platform_id] }}-x86_64'

                        # NOTE: Repo key for Fedora is not managed because
                        #       it is fast moving platform and not used for
                        #       primary deployments.
                        #key_file_resource_id
                        #key_file_path

                        # NOTE: Sync only the latest Fedora release.
                        {% if system_platform_id == 'fc24' %}

                        # NOTE: At the moment Fedora 24 had `dnf` with
                        #       the bug which makes it impossible to
                        #       avoid using proxy per repository.
                        #       See details:
                        #           https://bugzilla.redhat.com/show_bug.cgi?id=1319786
                        {% if system_platform_id == 'fc24' %}
                        # TODO: It is set back to `TRUE` -
                        #       it seems the issue is resolved.
                        #       This `if` remains until testing confirms
                        #       there is no issues.
                        use_local_yum_mirrors: True
                        {% else %}
                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        {% endif %}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::fedora/linux/updates/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'fedora/linux/updates/'

                        {% endif %}

                    {% endfor %}

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        # NOTE: Disable updates repo - use relase-time one.
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/updates/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        key_file_resource_id: rhel7_centos7_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/updates/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        # NOTE: Disable updates repo - use relase-time one.
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/updates/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/updates/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        key_file_resource_id: rhel5_centos5_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/updates/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

            addons:
                installation_type: conf_template

                os_platform_configs:

                    # NOTE: `addons` repo is not configured on default rhel7.
                    {% if False %}
                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/addons/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/addons/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        key_file_resource_id: rhel7_centos7_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/addons/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

                    {% endif %}

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/addons/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/addons/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        key_file_resource_id: rhel5_centos5_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/addons/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

            extras:
                installation_type: conf_template

                os_platform_configs:

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/extras/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/extras/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        key_file_resource_id: rhel7_centos7_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/extras/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        # Default is enabled.
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/extras/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/extras/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        key_file_resource_id: rhel5_centos5_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/extras/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

            centosplus:
                installation_type: conf_template

                os_platform_configs:

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        # Default is disabled.
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/centosplus/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/centosplus/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        key_file_resource_id: rhel7_centos7_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/centosplus/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        # Default is disabled.
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/centosplus/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/centosplus/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        key_file_resource_id: rhel5_centos5_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/centosplus/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

            contrib:
                installation_type: conf_template

                os_platform_configs:

                    # NOTE: `contrib` repo is not configured on default rhel7.
                    {% if False %}
                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/contrib/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/contrib/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        key_file_resource_id: rhel7_centos7_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/contrib/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

                    {% endif %}

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        # Default is disabled.
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/$releasever/contrib/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://mirror.centos.org/centos/{{ os_platform_to_release_ver[system_platform_id] }}/contrib/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        key_file_resource_id: rhel5_centos5_base_updates_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'mirror.0x.sg::centos/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/contrib/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'centos/'

            # EPEL repository for RHEL.
            epel:
                installation_type: conf_template

                os_platform_configs:

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/7/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/7/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'

                        key_file_resource_id: rhel5_epel7_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'linux.mirrors.es.net::fedora-epel/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'epel/'

                    {% set system_platform_id = 'rhel5' %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/5/$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://download.fedoraproject.org/pub/epel/5/x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5'

                        key_file_resource_id: rhel5_epel5_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-5'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'linux.mirrors.es.net::fedora-epel/'
                        rsync_mirror_internet_source_rel_path: '{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'epel/'

            # PostgreSQL 9.3.
            # See list of available repositories:
            #   http://yum.postgresql.org/repopackages.php
            postgresql:
                installation_type: conf_template

                os_platform_configs:

                    # TODO: The loop can possibly include `rhel7`.
                    #       However, it was only tested for
                    #       `key_file_resource_id: rhel5_postgresql_yum_repository_rpm_verification_key`.
                    {% for system_platform_id in [
                            'rhel5',
                        ]
                    %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://yum.postgresql.org/9.3/redhat/rhel-$releasever-$basearch/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-93'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://yum.postgresql.org/9.3/redhat/rhel-{{ os_platform_to_release_ver[system_platform_id] }}-x86_64/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-93'

                        key_file_resource_id: rhel5_postgresql_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-93'

                        use_local_yum_mirrors: {{ use_local_yum_mirrors }}

                        rsync_mirror_internet_source_base_url: 'yum.postgresql.org::pgrpm-93/redhat/'
                        # TODO: This repository has sub-repos per target OS.
                        rsync_mirror_internet_source_rel_path: 'rhel-{{ os_platform_to_release_ver[system_platform_id] }}-x86_64/'
                        rsync_mirror_local_destination_path_prefix: 'postgresql/pgrpm-93/redhat/'

                    {% endfor %}

            # Repository for OpenStack command line utils.
            # URL for installation RPM:
            #   https://repos.fedorapeople.org/repos/openstack/openstack-juno/rdo-release-juno-1.noarch.rpm
            openstack-juno:
                installation_type: conf_template

                # NOTE: This repository does not work well behind proxies.
                #       Because it does not allow insecure `http` access,
                #       it may require private mirror (for `http`).

                os_platform_configs:

                    {% for system_platform_id in [
                            'fc21',
                            'fc22',
                            'fc23',
                            'fc24',
                        ]
                    %}
                    # NOTE: Reusing the same config for `fc21` by `fc22`.
                    {{ system_platform_id }}:
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'https://repos.fedorapeople.org/repos/openstack/openstack-juno/fedora-$releasever/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'https://repos.fedorapeople.org/repos/openstack/openstack-juno/fedora-{{ os_platform_to_release_ver[system_platform_id] }}/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'

                        # NOTE: Fedora and RHEL7 keys are the same.

                        key_file_resource_id: openstack_juno_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'

                        # TODO: Use global `use_local_yum_mirrors` switch
                        #       when rsync-able URL parts are define.
                        #use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        use_local_yum_mirrors: False

                        # TODO: Define rsync-able URL parts.
                        #rsync_mirror_internet_source_base_url: ''
                        #rsync_mirror_internet_source_rel_path: ''
                        #rsync_mirror_local_destination_path_prefix: 'openstack-juno/'

                    {% endfor %}

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        repo_enabled: False
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://repos.fedorapeople.org/repos/openstack/openstack-juno/epel-7/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://repos.fedorapeople.org/repos/openstack/openstack-juno/epel-7/'
                        yum_repo_key_url: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'

                        key_file_resource_id: openstack_juno_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-Juno'

                        # TODO: Use global `use_local_yum_mirrors` switch
                        #       when rsync-able URL parts are define.
                        #use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        use_local_yum_mirrors: False

                        # TODO: Define rsync-able URL parts.
                        #rsync_mirror_internet_source_base_url: ''
                        #rsync_mirror_internet_source_rel_path: ''
                        #rsync_mirror_local_destination_path_prefix: 'openstack-juno/'

            # Jenkins.
            # See installation instructions:
            #   http://pkg.jenkins-ci.org/redhat/
            # Installation RPM: jenkins
            jenkins:
                installation_type: conf_template

                # NOTE: This repository could probably be used on rhel5
                #       as well. There is just one problem - key cannot be
                #       imported in default state.
                #       See: http://dan.carley.co/blog/2012/05/22/yum-gpg-keys-for-jenkins/

                os_platform_configs:

                    {% for system_platform_id in [
                            'fc21',
                            'fc22',
                            'fc23',
                            'fc24',
                        ]
                    %}
                    # NOTE: Reusing the same config for `fc21` by `fc22`.
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat/'
                        yum_repo_key_url: 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat/'
                        yum_repo_key_url: 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'

                        # NOTE: Fedora and RHEL7 keys are the same.

                        key_file_resource_id: jenkins_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins'

                        # TODO: Use global `use_local_yum_mirrors` switch
                        #       when rsync-able URL parts are define.
                        #use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        use_local_yum_mirrors: False

                        # TODO: Define rsync-able URL parts.
                        #rsync_mirror_internet_source_base_url: ''
                        #rsync_mirror_internet_source_rel_path: ''
                        #rsync_mirror_local_destination_path_prefix: 'jenkins/'

                    {% endfor %}

                    {% set system_platform_id = 'rhel7' %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat/'
                        yum_repo_key_url: 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://pkg.jenkins-ci.org/redhat/'
                        yum_repo_key_url: 'http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'

                        key_file_resource_id: jenkins_yum_repository_rpm_verification_key
                        key_file_path: '/etc/pki/rpm-gpg/RPM-GPG-KEY-jenkins'

                        # TODO: Use global `use_local_yum_mirrors` switch
                        #       when rsync-able URL parts are define.
                        #use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        use_local_yum_mirrors: False

                        # TODO: Define rsync-able URL parts.
                        #rsync_mirror_internet_source_base_url: ''
                        #rsync_mirror_internet_source_rel_path: ''
                        #rsync_mirror_local_destination_path_prefix: 'jenkins/'

            # Saltstack repository for RHEL5.
            # Apparently, Fedora (and EPEL) copr repositories are discontinued:
            #     https://copr.fedorainfracloud.org/coprs/saltstack/salt/
            # Instead, there is official Saltstack repository for RHEL:
            #     https://repo.saltstack.com/yum/redhat/5/x86_64/2015.5/
            # All official configuration options for RHEL:
            #     https://repo.saltstack.com/#rhel
            # At the moment, Fedora support lacks recent updates:
            #     https://github.com/saltstack/salt/issues/28142#issuecomment-230115486
            saltstack:
                installation_type: conf_template

                os_platform_configs:

                    {% for system_platform_id in [
                            'rhel5',
                            'rhel7',
                        ]
                    %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        # NOTE: Why fixed on release 2015.5?
                        #       Current Salt master used on Fedora is
                        #       only updated 2015.5.10.

                        # These are URLs for official
                        # repsositories supporting RHEL only.
                        #{#
                        yum_repo_baseurl: 'https://repo.saltstack.com/yum/redhat/5/x86_64/2015.5/'
                        yum_repo_key_url: 'https://repo.saltstack.com/yum/redhat/5/x86_64/2015.5/SALTSTACK-EL5-GPG-KEY.pub'
                        yum_repo_baseurl: 'https://repo.saltstack.com/yum/redhat/7/x86_64/2015.5/'
                        yum_repo_key_url: 'https://repo.saltstack.com/yum/redhat/7/x86_64/2015.5/SALTSTACK-GPG-KEY.pub'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'https://repo.saltstack.com/yum/redhat/{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/2015.5/'
                        {% if False %}
                        {% elif system_platform_id  == 'rhel5' %}
                        yum_repo_key_url: 'https://repo.saltstack.com/yum/redhat/{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/2015.5/SALTSTACK-EL5-GPG-KEY.pub'
                        {% elif system_platform_id  == 'rhel7' %}
                        yum_repo_key_url: 'https://repo.saltstack.com/yum/redhat/{{ os_platform_to_release_ver[system_platform_id] }}/x86_64/2015.5/SALTSTACK-GPG-KEY.pub'
                        {% endif %}

                        # TODO: Use global `use_local_yum_mirrors` switch
                        #       when rsync-able URL parts are defined.
                        # NOTE: Official repositories listed above do not
                        #       support rsync protocol yet:
                        #           https://github.com/saltstack/salt/issues/29222
                        #use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        use_local_yum_mirrors: False

                        # TODO: Define rsync-able URL parts.
                        #rsync_mirror_internet_source_base_url: ''
                        #rsync_mirror_internet_source_rel_path: ''
                        #rsync_mirror_local_destination_path_prefix: 'saltstack/'

                    {% endfor %}

            # SonarQube
            sonar_qube:
                installation_type: conf_template

                os_platform_configs:

                    {% for system_platform_id in [
                            'fc21',
                            'fc22',
                            'fc23',
                            'fc24',
                        ]
                    %}
                    {{ system_platform_id }}:
                        repo_enabled: True
                        skip_if_unavailable: True

                        #{# Original:
                        yum_repo_baseurl: 'http://downloads.sourceforge.net/project/sonar-pkg/rpm/'
                        #}#
                        # URLs renderred exactly (based on template params):
                        yum_repo_baseurl: 'http://downloads.sourceforge.net/project/sonar-pkg/rpm/'

                        yum_repo_gpgcheck: False

                        # TODO: Use global `use_local_yum_mirrors` switch
                        #       when rsync-able URL parts are define.
                        #use_local_yum_mirrors: {{ use_local_yum_mirrors }}
                        use_local_yum_mirrors: False

                        # TODO: Define rsync-able URL parts.
                        #rsync_mirror_internet_source_base_url: ''
                        #rsync_mirror_internet_source_rel_path: ''
                        #rsync_mirror_local_destination_path_prefix: 'sonar/'

                    {% endfor %}


###############################################################################
# EOF
###############################################################################

