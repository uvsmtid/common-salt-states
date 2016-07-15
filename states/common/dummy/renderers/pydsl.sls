#!pydsl

# This is just a test for this issue:
#   https://github.com/saltstack/salt/issues/23119
# So far, it works for `salt-call` but doesn't for `salt`.
state('asdfghjkl').cmd.run('echo test')

