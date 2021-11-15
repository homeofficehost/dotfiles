
# ansible-playbook -c local local.yml --vault-id ansible/workstation/tg@gopass-client.py --ask-vault-pass --limit $(cat /etc/hostname).local
sudo ansible-playbook -c local local.yml --vault-id ansible/workstation/tg@gopass-client.py --limit $(cat /etc/hostname).local