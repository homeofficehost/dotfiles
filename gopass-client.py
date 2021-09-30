#!/usr/bin/env python

import sys
from subprocess import run, PIPE, STDOUT

VAULT_PASSWORD_LOCATION='ansible/tgworkstation'


def main():
    if len(sys.argv) != 3 or sys.argv[1] != "--vault-id":
        print('Necessary argument "--vault-id" missing')
        sys.exit(1)
    result = run(
        ["gopass", VAULT_PASSWORD_LOCATION + sys.argv[2]],
        text=True,
        stderr=STDOUT,
        stdout=PIPE,
    )
    if result.returncode != 0:
        print(result.stdout)
        sys.exit(result.returncode)
    else:
        sys.stdout.write(result.stdout)
        sys.exit(0)


if __name__ == "__main__":
    main()
