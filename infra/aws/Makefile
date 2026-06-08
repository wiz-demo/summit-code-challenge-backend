SHELL  := /bin/bash
TF     := terraform
TFVARS := $(CURDIR)/terraform.tfvars

.PHONY: help init fmt validate require-env workspace plan apply destroy outputs smoke

help:
	@echo "Targets (state-touching targets require ENV=prod|dev):"
	@echo "  init        - terraform init"
	@echo "  fmt         - terraform fmt"
	@echo "  validate    - terraform validate"
	@echo "  plan        - terraform plan      (e.g. make plan ENV=dev)"
	@echo "  apply       - terraform apply     (e.g. make apply ENV=dev)"
	@echo "  destroy     - terraform destroy   (e.g. make destroy ENV=dev)"
	@echo "  outputs     - refresh state and print outputs (ENV required)"
	@echo "  smoke       - hit the deployed endpoint with benign + exploit payloads (ENV required)"
	@echo ""
	@echo "Requires SSO: aws sso login --profile dev-product-cto-play"

init:
	$(TF) init -input=false

fmt:
	$(TF) fmt

validate:
	$(TF) validate

require-env:
	@if [ -z "$(ENV)" ]; then \
	  echo "ERROR: ENV is required. Use ENV=prod or ENV=dev (e.g. make apply ENV=dev)"; exit 1; fi
	@if [ "$(ENV)" != "prod" ] && [ "$(ENV)" != "dev" ]; then \
	  echo "ERROR: ENV must be prod or dev (got '$(ENV)')"; exit 1; fi

workspace: require-env
	@$(TF) workspace select $(ENV) 2>/dev/null || $(TF) workspace new $(ENV)

plan: workspace
	$(TF) plan -var-file=$(TFVARS) -var="environment=$(ENV)"

apply: workspace
	$(TF) apply -var-file=$(TFVARS) -var="environment=$(ENV)"

destroy: workspace
	$(TF) destroy -var-file=$(TFVARS) -var="environment=$(ENV)"

outputs: workspace
	@$(TF) refresh -var-file=$(TFVARS) -var="environment=$(ENV)" > /dev/null
	@$(TF) output

smoke: workspace
	@$(TF) refresh -var-file=$(TFVARS) -var="environment=$(ENV)" > /dev/null
	@eval "$$($(TF) output -raw smoke_test_commands)"
