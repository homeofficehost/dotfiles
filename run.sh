ansible-playbook -c local local.yml --vault-id "${USER}@gopass-client.py" --limit $(cat /etc/hostname).local $@
