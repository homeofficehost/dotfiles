# grep -s -q "localhost" inventory.yml || \
# echo '
# all:
#   hosts:
#     localhost' > inventory.yml
# ansible-playbook local.yml --inventory inventory.yml --ask-become-pass

ansible-playbook -i "localhost," -c local local.yml --vault-id ansible/workstation/tg@gopass-client.py --ask-become-pass