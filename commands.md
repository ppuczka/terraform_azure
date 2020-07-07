############ TERRAFORM COMMANDS ############

terraform init
terrafrom init -upgrade  
terraform plan [-out newfile]
terraform plan -target module.base
terraform apply 
terraform show 
terraform plan destroy => execution plan for destroying 
terraform destroy  => remove resource group 
terraform output ip 


terraform apply -var-file='secret.tfvars' -var-file='azure.tfvars'
terraform plan -destroy -var-file='secret.tfvars' -var-file='azure.tfvars'