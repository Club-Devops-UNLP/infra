init:
	terraform init

upgrade:
	terraform init -upgrade

plan:
	terraform plan -var-file="secret.tfvars"

apply:
	terraform apply -auto-approve -var-file="secret.tfvars"

get:
	terraform get

clean:
	rm terraform.tfstate
	rm terraform.tfstate.backup
	rm -rf .terraform
	rm .terraform.lock.hcl

destroy:
	terraform destroy -auto-approve