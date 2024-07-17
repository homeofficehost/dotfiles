#!/usr/bin/env python
#
# Assuming you have a working gopass installation. I personally use multiple mounts and I store all the passwords under a
# single directory.
#
# Add the following section to your `ansible.cfg`
#
# [vault]
# mount='store-X' # replace `store-x` with your actual store, if using the root set to an empty string
# directory='ansible' # replace `ansible` with the folder, or folder structure to your storage
#
# To use this script, make sure it is is readable by ansible. I assume going foward it is in the `scripts` folder in the 
# root directory of your ansible playbooks. The file is assumed to be saved as gopass-client.py. The only condition on the name
# is that it MUST end with `-client.py` or else it is never passed the `--vault-id` parameter.
#
# If your file is not stored in the scripts directory one level down from the root you will need to update the following:
#
# config.read(os.path.join(curdir, "../ansible.cfg"))
#
# make sure the path is pointing the the ansible.cfg or some other ini file you want to store the settings in.
#
# To manually specify vault ids to add, simply add `--vault-id password-name@scripts/gopass-client.py`.
# You can add as many of these as you need. But this quickly becomes unweildly.
#
# In your `ansible.cfg` make sure your default section has the following line
#
# [defaults]
# vault_identity_list=dev@scripts/gopass-client.py, staging@scripts/gopass-client.py
#
# vault_identity_list is a comma seperated list. replace dev and staging and add as many more as you need to fit your needs.
#
# In a production situation, you may be sharing the ansible code with many users and all may not have the same permissions to
# read the password from the gopass store. 
#
# By default this client will error if it can't decrypt the password. Unfortunately, on initialization ansible tries to load
# all the vault ids you specify even if they aren't needed. Therefore if a user doesn't have access to one of the passwords
# all ansible commands will just error if you use the `vault_identity_list` fields. 
#
# By adding the following to the vault configuration if a password is unabled to be determined, random data will be returned
#
# [vault]
# suppress_gopass_errors = True
#
# This is a double edged sword, this gets around errors running playbooks when a user might not be able to decrypt the
# password. But using `ansible-vault encrypt --encrypt-vault-id X ....` when you don't have access to X will result in a random 
# password being used. Since it is random and not saved, you won't be able to decrypt the information again. 
#
# Use this option at your own discression, but I think the advantages outweigh the costs. 
#
# If someone knows how to make config manager work like in the example client in the ansible directory let me know and I will
# happily make the adjustments.
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
An improved script for managing Ansible Vault passwords using pass (https://www.passwordstore.org)
or gopass (https://www.gopass.pw) password managers.
"""

import argparse
import configparser
import os
import subprocess
import sys

# Default password manager (can be 'pass' or 'gopass')
DEFAULT_PASS_COMMAND = 'gopass'

def get_ansible_config_file():
    """Determine the Ansible config file location."""
    try:
        import ansible.constants as C
        return C.CONFIG_FILE
    except ImportError:
        config_paths = [
            os.environ.get('ANSIBLE_CONFIG'),
            os.path.join(os.getcwd(), 'ansible.cfg'),
            os.path.expanduser('~/.ansible.cfg'),
            '/etc/ansible/ansible.cfg'
        ]
        return next((path for path in config_paths if path and os.path.isfile(path)), None)

def get_config_passwordstore(config_file):
    """Get passwordstore name from Ansible config file."""
    if config_file:
        config = configparser.ConfigParser()
        config.read(config_file)
        try:
            return config.get('vault', 'passwordstore', fallback='').strip()
        except (configparser.NoSectionError, configparser.NoOptionError):
            pass
    return None

def get_password_from_store(passwordstore, pass_command):
    """Retrieve password from the password store."""
    try:
        result = subprocess.run([pass_command, passwordstore], 
                                capture_output=True, text=True, check=True)
        return result.stdout.strip().split("\n")[0]
    except subprocess.CalledProcessError as e:
        sys.stderr.write(f"Error accessing password store: {e.stderr}\n")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(
        description='Get a vault password from a password store',
        epilog='Please read the README.md file for more information.'
    )
    parser.add_argument('--vault-id', default='default',
                        help='passwordstore containing the vault password')
    parser.add_argument('--pass-command', default=DEFAULT_PASS_COMMAND,
                        choices=['pass', 'gopass'],
                        help='password manager to use (default: %(default)s)')
    args = parser.parse_args()

    ansible_config_file = get_ansible_config_file()
    
    if args.vault_id != 'default':
        passwordstore = args.vault_id
    else:
        passwordstore = get_config_passwordstore(ansible_config_file)

    if not passwordstore:
        sys.stderr.write("Couldn't get passwordstore settings from Ansible config "
                         "file or --vault-id option!\nPlease read the README.md "
                         "file for more info about script settings.\n")
        sys.exit(1)

    password = get_password_from_store(passwordstore, args.pass_command)
    sys.stdout.write(password)

if __name__ == '__main__':
    main()
    