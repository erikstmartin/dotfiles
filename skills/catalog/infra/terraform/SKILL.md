---
name: terraform
description: Use when writing, reviewing, or refactoring Terraform HCL — covers project setup, resource authoring, module development, and pre-commit validation.
---

# Terraform

## 1. Project Setup

### File Organization

| File | Purpose |
|------|---------|
| `terraform.tf` | Terraform version + required providers |
| `providers.tf` | Provider configurations |
| `main.tf` | Primary resources and data sources |
| `variables.tf` | Input variable declarations (alphabetical) |
| `outputs.tf` | Output value declarations (alphabetical) |
| `locals.tf` | Computed/shared local values |

### Version Pinning

Always pin both the Terraform CLI version and provider versions:

```hcl
# terraform.tf
terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # allows patch/minor, blocks major
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# providers.tf
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
```

## 2. Write Infrastructure

### Naming Conventions
- **lowercase_underscore** for all resource names, variables, outputs, locals
- **Singular nouns** — `aws_instance.web_api`, not `web_apis`
- Use `main` when only one instance of a resource type exists and no better name applies

### Variable Rules
Every variable requires `type` and `description`. Add `validation` for constrained inputs:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "database_password" {
  description = "RDS admin password"
  type        = string
  sensitive   = true
}
```

### prefer `for_each` over `count` for Multiple Resources

```hcl
# BAD — count produces indexed resources; removing middle item shifts indices
resource "aws_instance" "web" {
  count         = var.instance_count
  instance_type = "t3.micro"
  ami           = data.aws_ami.ubuntu.id
  tags          = { Name = "web-${count.index}" }
}

# GOOD — for_each keys are stable; safe to add/remove individual items
resource "aws_instance" "web" {
  for_each      = toset(var.instance_names)
  instance_type = "t3.micro"
  ami           = data.aws_ami.ubuntu.id
  tags          = { Name = each.key }
}
```

Use `count = var.enable_x ? 1 : 0` only for conditional single-resource creation.

### Security Defaults
- Encryption at rest: always enabled (KMS where possible)
- Private networking: resources in private subnets by default
- Least privilege: security groups deny by default, open only required ports
- Never hardcode credentials; use `sensitive = true` on secret outputs

## 3. Module Development

### Standard Module Layout

```
module-name/
├── main.tf        # Resources
├── variables.tf   # Inputs
├── outputs.tf     # Outputs
├── versions.tf    # Provider version constraints
├── README.md
└── examples/
    └── complete/
        └── main.tf
```

### Input Validation & Outputs

Validate inputs; output all attributes callers will need for composition:

```hcl
# variables.tf
variable "cidr_block" {
  description = "VPC CIDR block"
  type        = string
  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "Must be a valid IPv4 CIDR."
  }
}

# outputs.tf — expose what consuming modules need
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.private[*].id
}
```

### Composition Pattern

```hcl
module "vpc" {
  source             = "../../modules/aws/vpc"
  name               = "production"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "rds" {
  source     = "../../modules/aws/rds"
  vpc_id     = module.vpc.vpc_id       # consumed from vpc module output
  subnet_ids = module.vpc.private_subnet_ids
}
```

## 4. Validate & Ship

```bash
terraform fmt -recursive    # auto-format all .tf files
terraform validate          # check syntax and internal consistency
tflint                      # lint for best practices
tfsec .                     # security scanning (or: checkov -d .)
```

### Pre-Commit Checklist

- [ ] `terraform fmt` applied — no diff
- [ ] `terraform validate` passes
- [ ] All variables have `type` and `description`
- [ ] All outputs have `description`
- [ ] Provider and Terraform versions pinned
- [ ] No hardcoded credentials or region literals
- [ ] Sensitive values marked `sensitive = true`
- [ ] `.tfstate` and `.terraform/` in `.gitignore`

## 5. Common Pitfalls

1. **`count` vs `for_each` for collections** — `count` creates indexed resources (`web[0]`, `web[1]`). Removing `web[1]` forces recreation of all higher-indexed resources. Use `for_each` with a `set(string)` or `map` key for stable addressing.

2. **Missing version pins** — Unpinned providers (`version = ">= 5.0"`) will pull the latest major on `terraform init`, potentially breaking configs silently. Use `~> X.Y` to allow only patch/minor updates.

3. **Hardcoded credentials** — Never put access keys, passwords, or tokens directly in `.tf` files. Use environment variables, AWS IAM roles, Vault, or `sensitive` variables fed via CI secrets.

4. **Sensitive outputs without `sensitive = true`** — Terraform will print the value in plan/apply output and store it in state in plaintext. Always mark passwords, tokens, and keys as `sensitive = true`.

5. **Committing `.tfstate`** — State files contain plaintext secrets. Always add `*.tfstate`, `*.tfstate.backup`, and `.terraform/` to `.gitignore`. Use remote state (S3 + DynamoDB locking, Terraform Cloud, etc.) for team workflows.
