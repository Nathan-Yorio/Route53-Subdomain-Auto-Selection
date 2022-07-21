# Run the Python Terraform Var Generation Script and Grab some information to use for variables

python main.py

terraform init

terraform validate

terraform apply -var-file="default.tfvars"

Read-Host -Prompt "Press Enter to exit"