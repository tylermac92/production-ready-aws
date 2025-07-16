ENV ?= dev
TF_DIR = environments/$(ENV)

init:
	cd $(TF_DIR) && terraform init

plan:
	cd $(TF_DIR) && terraform workspace select $(ENV) || terraform workspace new $(ENV)
	cd $(TF_DIR) && terraform plan -out=plan.tfplan

apply:
	cd $(TF_DIR) && terraform workspace select $(ENV) || terraform workspace new $(ENV)
	cd $(TF_DIR) && terraform apply -auto-approve

destroy:
	cd $(TF_DIR) && terraform workspace select $(ENV) || terraform workspace new $(ENV)
	cd $(TF_DIR) && terraform destroy -auto-approve

output:
	cd $(TF_DIR) && terraform output

format:
	terraform fmt -recursive

validate:
	cd $(TF_DIR) && terraform validate