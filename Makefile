#### Ansible

prepare:
	ansible-playbook -i ansible/inventory ansible/playbooks/prepare.yml

#### Terraform

init:
	cd terraform && make init

upgrade:
	cd terraform && make upgrade

plan:
	cd terraform && make plan

apply:
	cd terraform && make apply

get:
	cd terraform && make get

clean:
	cd terraform && make clean

destroy:
	cd terraform && make destroy

#### Azure

login:
	az login

logout:
	az logout