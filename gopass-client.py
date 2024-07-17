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
import sys
import argparse
import subprocess
import os
import configparser
import random
import string
import logging

# Set up logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def build_arg_parser():
    parser = argparse.ArgumentParser(description='Get a vault password from user keyring')
    parser.add_argument('--vault-id', action='store', default=None,
                        dest='vault_id',
                        help='name of the vault secret to get from keyring')
    parser.add_argument('--user', action='store', default='tg',
                        dest='user',
                        help='user to run gopass as')
    return parser

def main():
    curdir = os.path.dirname(__file__)
    logger.debug(f"Current directory: {curdir}")

    config = configparser.ConfigParser()
    config.read(os.path.join(curdir, "../ansible.cfg"))
    logger.debug(f"Config sections: {config.sections()}")

    mount = config['vault']['mount']
    logger.debug(f"Mount: {mount}")
    if mount is None:
      logger.error("Mount is None, exiting")
      sys.exit(1)

    directory = config['vault']['directory']
    logger.debug(f"Directory: {directory}")
    if directory is None:
      logger.error("Directory is None, exiting")
      sys.exit(1)

    suppress_gopass_errors = config['vault'].getboolean('suppress_gopass_errors')
    logger.debug(f"Suppress gopass errors: {suppress_gopass_errors}")

    arg_parser = build_arg_parser()
    args = arg_parser.parse_args()
    logger.debug(f"Command line arguments: {args}")

    keyname = args.vault_id
    user = args.user
    logger.debug(f"Keyname: {keyname}, User: {user}")

    if user:
        cmd = ["sudo", "-u", user, "gopass", "show", f"{mount}/{directory}/{keyname}"]
    else:
        cmd = ["gopass", "show", f"{mount}/{directory}/{keyname}"]
    logger.debug(f"Command to be executed: {cmd}")

    result = subprocess.run(cmd, capture_output=True, text=True)
    logger.debug(f"Subprocess return code: {result.returncode}")

    if result.returncode != 0 and not suppress_gopass_errors:
      logger.error(f"Error occurred: {result.stderr}")
      sys.stderr.write(result.stderr)
      sys.exit(result.returncode)
    elif suppress_gopass_errors:
      random_string = ''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(20))
      logger.debug(f"Generated random string due to error suppression")
      sys.stdout.write(random_string + '\n')
    else:
      logger.debug("Writing subprocess output to stdout")
      sys.stdout.write(f'{result.stdout}\n')

    logger.debug("Exiting with code 0")
    sys.exit(0)

if __name__ == '__main__':
    main()