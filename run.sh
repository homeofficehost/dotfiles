
ansible-playbook -c local local.yml --vault-id ansible/workstation/tg@gopass-client.py --limit $(cat /etc/hostname).local