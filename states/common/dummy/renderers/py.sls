#!py

# This is just a test for this issue:
#   https://github.com/saltstack/salt/issues/23119
# So far, it works for `salt-call` but doesn't for `salt`.

def run():

    config = {}

    config['lkjhgfdsa'] = {
        'cmd.run': [
            { 'name': 'echo test' },
        ]
    }

    return config

