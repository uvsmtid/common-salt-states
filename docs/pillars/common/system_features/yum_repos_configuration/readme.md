
Key `yum_repos_configuration` is the root for YUM repository configuration
based on host's OS platform.

The idea is that there can be multiple platforms a repository may
be applicable for. For example, EPEL repoistory is applicable for
RHEL5 and RHEL7. So, each repository lists platform-specific configuration
while state will pick only one based on host's OS platform.

