# grep -s -q "localhost" inventory.yml || \
# echo '
# all:
#   hosts:
#     localhost' > inventory.yml
# ansible-playbook local.yml --inventory inventory.yml --ask-become-pass

ansible-playbook local.yml --ask-become-pass