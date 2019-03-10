.PHONY: init init_base init_bastion init_database init_webserver \
clean clean_base clean_bastion clean_database clean_webserver \
apply destroy apply_base apply_bastion apply_database apply_webserver \
destroy_webserver destroy_database destroy_bastion destroy_base

init: init_base init_bastion init_database init_webserver
clean: clean_base clean_bastion clean_database clean_webserver
apply: apply_base apply_bastion apply_database apply_webserver
destroy: destroy_webserver destroy_database destroy_bastion destroy_base

init_base:
	cd 00-base; terraform init \
	-backend-config="bucket=${TF_VAR_bucket}" \
	-backend-config="key=${TF_VAR_dev_base_key}" \
	-backend-config="region=${TF_VAR_region}"

init_bastion:
	cd 01-bastion; terraform init \
	-backend-config="bucket=${TF_VAR_bucket}" \
	-backend-config="key=${TF_VAR_dev_bastion_key}" \
	-backend-config="region=${TF_VAR_region}"

init_database:
	cd 02-database; terraform init \
	-backend-config="bucket=${TF_VAR_bucket}" \
	-backend-config="key=${TF_VAR_dev_database_key}" \
	-backend-config="region=${TF_VAR_region}"

init_webserver:
	cd 03-webserver; terraform init \
	-backend-config="bucket=${TF_VAR_bucket}" \
	-backend-config="key=${TF_VAR_dev_webserver_key}" \
	-backend-config="region=${TF_VAR_region}"

clean_base:
	rm -rf 00-base/.terraform

clean_bastion:
	rm -rf 01-bastion/.terraform

clean_database:
	rm -rf 02-database/.terraform

clean_webserver:
	rm -rf 03-webserver/.terraform

apply_base:
	cd 00-base; terraform apply -auto-approve

apply_bastion:
	cd 01-bastion; terraform apply -auto-approve

apply_database:
	cd 02-database; terraform apply -auto-approve

apply_webserver:
	cd 03-webserver; terraform apply -auto-approve

destroy_webserver:
	cd 03-webserver; terraform destroy -auto-approve

destroy_database:
	cd 02-database; terraform destroy -auto-approve

destroy_bastion:
	cd 01-bastion; terraform destroy -auto-approve

destroy_base:
	cd 00-base; terraform destroy -auto-approve
