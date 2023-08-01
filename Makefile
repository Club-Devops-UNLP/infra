#### Ansible

prepare:
	ansible-playbook -i ansible/inventory ansible/playbooks/prepare.yml

#### Terraform

change_dir:
	cd terraform

init:
	make change_dir && make init

upgrade:
	make change_dir && make upgrade

plan:
	make change_dir && make plan

apply:
	make change_dir && make apply

get:
	make change_dir && make get

clean:
	make change_dir && make clean

destroy:
	make change_dir && make destroy