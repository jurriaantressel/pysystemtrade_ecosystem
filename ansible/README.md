## Playbook Order
ansible-playbook -i hosts test.yml -K
ansible-playbook -i hosts mount_shares.yml -K
ansible-playbook -i hosts install_docker.yml -K
ansible-playbook -i hosts install_vault.yml -K
ansible-playbook -i hosts init_vault.yml -K
ansible-playbook -i hosts clone_repositories.yml -K


## Helpers
ssh-copy-id makutaku@192.168.1.176
lsb_release -cs
. /etc/os-release && echo $VERSION_CODENAME


