# Wiz Connectors (Terraform)

Provisions Wiz connectors via the `wiz-v2` Terraform provider:

- **AWS** connector targeting account `800618367342`, plus the IAM role Wiz
  assumes to scan it (two-stage apply: IAM role first, then connector).
- **GitHub** connector (GitHub App auth against github.com). Self-contained —
  no IAM dependency; provisioned with the root module.

Adapted from the `terraform-test` reference repo.

## Prerequisites

- Terraform `>= 1.10.0`
- AWS CLI v2 with SSO configured for profile `dev-product-cto-play`
- A Wiz service account (Wiz Console → Settings → Service Accounts) with at
  least `create:connectors` and `read:tenant` scopes
- Access to the Wiz private Terraform registry at `tf.app.wiz.io`
  (`terraform login tf.app.wiz.io` if `terraform init` prompts)

## First-time setup

```bash
cd infra/wiz

# Fill in your Wiz secrets locally (file is gitignored — secrets won't be committed)
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars

# Save the GitHub App private key (gitignored). Set github_app_id in
# terraform.tfvars; keep the default path or override github_app_private_key_path.
cp /path/to/your-downloaded-key.pem github-app.pem

# AWS SSO
aws sso login --profile dev-product-cto-play
```

## Apply

```bash
make init    # init both sub-projects
make plan    # plan both
make apply   # IAM first, then connector
```

After apply, check the Wiz UI under Settings → Connectors. Both
`TF-AWS-Connector-CodeChallange` and `TF-GitHub-Connector-CodeChallange`
should appear and start their first scan within a few minutes.

## Tear down

```bash
make destroy   # destroys connector first, then IAM role
```

## Layout

```
infra/wiz/
├── versions.tf, providers.tf, variables.tf      Root module
├── connector_aws.tf                             wiz-v2_generic_connector resource
├── connector_github.tf                          wiz-v2_generic_connector (github)
├── terraform.tfvars.example                     Reference values (no secrets)
├── terraform.tfvars                             Local-only, gitignored
├── Makefile                                     init / plan / apply / destroy
└── wiz-iam/
    ├── versions.tf, providers.tf, variables.tf  Sub-module
    ├── main.tf                                  Wiz's published IAM module
    └── outputs.tf                               Exposes role_arn
```

The root module reads the IAM role ARN from `wiz-iam/terraform.tfstate` via
`terraform_remote_state`. This is a deliberate workaround for a `wiz-v2`
provider bug where `customerRoleARN` referencing an unknown-after-apply value
triggers an `auth_params_hash__` inconsistency error.

## Things this won't do

- Does NOT scan account `432513806796` (the `cto-experts` profile's account)
- Does NOT modify the ECS-on-EC2 deployment from `infra/aws/`
- Does NOT configure Bedrock, DocumentDB, or any other supporting service
