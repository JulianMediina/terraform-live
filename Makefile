.PHONY: init plan apply drift destroy

init:
	cd live && terraform init -backend-config=$(ENV).s3.tfbackend -reconfigure

plan: init
	cd live && terraform plan -var-file=$(ENV).tfvars

apply: init
	cd live && terraform apply -var-file=$(ENV).tfvars

drift: init
	cd live && terraform plan -var-file=$(ENV).tfvars -detailed-exitcode

destroy: init
	cd live && terraform destroy -var-file=$(ENV).tfvars
