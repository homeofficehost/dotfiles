sudo ansible-playbook -c local local.yml --vault-id "ansible/workstation/${USER}@gopass-client.py" --limit $(cat /etc/hostname).local --ask-become-pass
