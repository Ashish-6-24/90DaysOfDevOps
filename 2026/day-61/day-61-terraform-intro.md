# Day 61 — Terraform Fundamentals and AWS Resource Lifecycle

A hands-on record of defining cloud resources in Terraform, checking planned changes, reviewing state, updating an EC2 tag, and removing the lab environment.

**Working environment:** Ubuntu on an EC2 host; AWS Region `ap-southeast-2` (Sydney); Terraform AWS provider `~> 6.0`.

**Progress note:** This document describes the workflow and expected checks. Add command output and screenshots only after confirming each operation in your AWS account. Earlier S3 access was blocked by an Organizations SCP, and the first EC2 attempt using `t2.micro` was rejected by the account's Free Tier eligibility check.

> **AMI and instance selection:** The exercise originally specifies an Amazon Linux 2 image for `ap-south-1`. The current lab is configured for Sydney, so that image ID must not be reused there. Amazon Linux 2 also reached end of support on June 30, 2026. The configuration below reads the current Amazon Linux 2023 x86_64 image for the selected region. The AWS CLI query in this session listed `t3.micro` as eligible in `ap-southeast-2`; account credits, usage limits, and other charges still need to be checked. [Amazon Linux 2 notice](https://aws.amazon.com/amazon-linux-2/) · [Find an AMI through Systems Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami-parameter-store.html)

## 1. Infrastructure as Code concepts

### Meaning and value in a delivery workflow

- Infrastructure as Code (IaC) expresses cloud components in configuration files rather than relying on repeated console setup.
- A Terraform file can describe an object such as an S3 bucket or EC2 instance, including settings and tags.
- In a DevOps workflow, saved configuration can be reviewed, shared, versioned, and applied consistently across environments.
- It reduces repeated manual steps and makes proposed infrastructure changes easier to inspect before execution.

**Small example:**

```hcl
resource "aws_s3_bucket" "audit" {
  bucket = "example-audit-storage-unique-name"
}
```

### Declarative configuration and provider flexibility

- **Declarative approach:** The configuration states the intended result. Terraform works out the operations required to move managed infrastructure toward that result.
- **Provider-based portability:** Terraform has providers for multiple platforms, including AWS, Azure, and Google Cloud. The workflow is similar, but each provider has its own resource types and arguments; an AWS instance definition is not directly interchangeable with an Azure virtual machine definition.

Reference: [HashiCorp — Infrastructure as Code](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code)

### Comparison of infrastructure tools

| Tool | Common role | Configuration approach |
| --- | --- | --- |
| Terraform | Creates and manages infrastructure across supported providers | HCL configuration and a state mapping |
| AWS CloudFormation | Provisions AWS resources as stacks | JSON or YAML templates managed by AWS |
| Ansible | Configures operating systems, installs packages, and deploys applications; it can also call cloud APIs | YAML playbooks containing tasks and modules |
| Pulumi | Defines and maintains infrastructure using programming languages | Python, TypeScript, Go, and other supported languages, with Pulumi state management |

References: [CloudFormation documentation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/) · [Ansible documentation](https://docs.ansible.com/projects/ansible/latest/getting_started/introduction.html) · [Pulumi concepts](https://www.pulumi.com/docs/iac/concepts/)

## 2. Prepare Terraform and AWS access

If the commands `terraform -version` and `aws --version` already return version details, the corresponding installation can be skipped.

### Install Terraform on Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y curl gnupg lsb-release unzip

curl -fsSL https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install -y terraform
terraform -version
```

For other operating systems, use the vendor's installation guide rather than mixing package-manager commands:

- macOS: `brew tap hashicorp/tap` followed by `brew install hashicorp/tap/terraform`.
- Windows with Chocolatey: `choco install terraform` in an elevated terminal.

Reference: [HashiCorp CLI installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Install or check the AWS CLI

For an Ubuntu machine using x86_64:

```bash
uname -m
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

For ARM64 (`aarch64`), download the matching package instead:

```bash
curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip
```

Then run the same extraction and installation steps.

Reference: [AWS CLI v2 installation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Confirm the AWS identity

- When Terraform runs on an EC2 machine with an appropriate instance profile, the AWS provider can obtain temporary credentials from that role.
- For an IAM-user-based lab, configure credentials locally with `aws configure`; do not paste keys into Terraform files or commit them.
- For IAM Identity Center, configure an SSO profile and sign in with the approved workflow.

```bash
aws sts get-caller-identity
aws configure list
```

The identity response contains the account number, principal ARN, and user identifier. A successful identity lookup proves authentication only; the principal must separately be allowed to perform the requested S3, EC2, and Systems Manager read operations.

Reference: [AWS provider authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

**Cost and access note:** This exercise calls real AWS APIs. Check current account credits and billing, and resolve any applicable organizational restrictions before provisioning. An explicit Deny in an AWS Organizations SCP cannot be cancelled by attaching another IAM Allow policy.

## 3. Define and create the S3 bucket

Work in the real-AWS project directory. Keep the LocalStack experiment in a separate folder and do not combine its `.tf` files or state with this project.

```bash
mkdir -p ~/terraform-basics
cd ~/terraform-basics
```

Create or update `main.tf` with the provider and existing bucket resource. The bucket name below matches the name previously shown in the project; retain it only if it is the bucket tracked by this project's state and exists in the selected AWS account.

```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_s3_bucket" "day61" {
  bucket = "ashish-day61-bucket"

  tags = {
    Name    = "Terraform-Day61"
    Project = "90DaysOfDevOps"
  }
}

output "bucket_name" {
  description = "Name of the lab bucket"
  value       = aws_s3_bucket.day61.bucket
}
```

- The `bucket` argument names the intended S3 bucket. S3 names are globally unique, so this value must not already belong to another account.
- The Terraform address `aws_s3_bucket.day61` is made from the resource type and the local label. It is not the same thing as the bucket's globally visible name.
- If the bucket was created outside this state, do not assume Terraform already manages it. Confirm the state mapping or import the existing bucket before applying.

Prepare and review the project:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

For a brand-new bucket in an empty state, the plan should show one addition. Create it only after inspecting the proposed action:

```bash
terraform apply
terraform output -raw bucket_name
```

Check the real bucket in the S3 console or through the AWS CLI. If the organization's SCP still denies `s3:CreateBucket`, an organization administrator must address that restriction before the operation can succeed.

### Files created during initialization

- `terraform init` obtains the AWS provider plugin version allowed by the provider constraint and prepares the configured backend. It does not create an S3 bucket or EC2 instance.
- `.terraform/` contains working data such as provider binaries, downloaded modules where used, and backend initialization metadata.
- `.terraform.lock.hcl` records the selected provider version and checksums. Keep this file under version control.
- `terraform.tfstate` records Terraform's resource mappings and attributes when local state is used. Treat it as private data.

References: [AWS S3 bucket resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) · [Terraform init command](https://developer.hashicorp.com/terraform/cli/commands/init)

## 4. Add the EC2 compute resource

The configured region for this lab is Sydney (`ap-southeast-2`). Image identifiers are regional, so the assignment's Mumbai AMI ID must not be copied into this configuration.

### Check the network prerequisites

The simple instance definition below assumes a default VPC and default subnet are available in the selected region. Inspect them first:

```bash
aws ec2 describe-vpcs \
  --region ap-southeast-2 \
  --filters Name=is-default,Values=true \
  --query 'Vpcs[].VpcId' \
  --output table

aws ec2 describe-subnets \
  --region ap-southeast-2 \
  --filters Name=default-for-az,Values=true \
  --query 'Subnets[].[SubnetId,VpcId,AvailabilityZone]' \
  --output table
```

If no suitable default network is present, choose an existing subnet and security group in Sydney and provide their IDs in the instance configuration. Do not invent subnet or security-group identifiers.

### Retrieve a regional Amazon Linux image

Amazon Linux 2 is past its published support end date. This lab instead reads the current Amazon Linux 2023 x86_64 image parameter for Sydney:

```bash
aws ssm get-parameter \
  --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --region ap-southeast-2 \
  --query 'Parameter.Value' \
  --output text
```

The AWS CLI result in this practice session listed `t3.micro` among the instance types returned by the `free-tier-eligible=true` filter in `ap-southeast-2`. This is an eligibility indicator, not a promise that every account, time period, or ancillary resource will be free.

To repeat the eligibility lookup:

```bash
aws ec2 describe-instance-types \
  --region ap-southeast-2 \
  --filters Name=free-tier-eligible,Values=true \
  --query 'InstanceTypes[*].[InstanceType]' \
  --output text
```

### Add the image lookup and EC2 resource

Append these blocks to the same `main.tf`; do not add a second default AWS provider or redeclare the S3 resource/output.

```hcl
data "aws_ssm_parameter" "al2023" {
  name            = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  with_decryption = false
}

resource "aws_instance" "day61" {
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = "t3.micro"

  tags = {
    Name    = "TerraWeek-Day1"
    Project = "90DaysOfDevOps"
  }
}

output "ec2_instance_id" {
  description = "Identifier assigned to the EC2 instance"
  value       = aws_instance.day61.id
}
```

- The SSM data block reads an AWS-maintained parameter; Terraform does not create or own that parameter.
- The selected image is x86_64, which is compatible with the `t3.micro` instance family.
- The instance type is `t3.micro` because the earlier `t2.micro` launch attempt returned `InvalidParameterCombination`, and the region eligibility query listed `t3.micro`.
- The principal running Terraform needs permission to read the public parameter (`ssm:GetParameter`) as well as the required EC2 operations.

Run the checks and inspect the plan:

```bash
terraform fmt
terraform validate
terraform plan
```

If the S3 bucket is already tracked in this same real-AWS state and does not need modification, the expected summary for this change is:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Apply only after confirming that the plan creates the EC2 instance and does not replace or delete the bucket:

```bash
terraform apply
terraform output
```

Use the reported instance ID to verify the instance in the Sydney EC2 console. Check its state and the `TerraWeek-Day1` tag. The resource must be visible in the real AWS console; a LocalStack resource is not evidence of an AWS EC2 launch.

### Why Terraform leaves the bucket alone

- Terraform state records the association between the local address `aws_s3_bucket.day61` and the real S3 bucket identifier.
- During planning, Terraform reads the configuration, refreshes the tracked object through the provider, and compares the observed values with the desired settings.
- If the bucket is still present and its configuration has not changed, Terraform has no bucket operation to propose.
- The newly declared `aws_instance.day61` has no matching managed instance in the state, so Terraform proposes its creation.

Reference: [Terraform state purpose](https://developer.hashicorp.com/terraform/language/state/purpose) · [AWS public AMI parameters](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/finding-an-ami-parameter-store.html) · [EC2 resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

**Repeatability note:** The public AMI parameter can point to a newer image over time. Once a known-good AMI has been selected, pin its resolved ID if a stable repeatable configuration is required. Review any plan that proposes replacing an instance.

## 5. Examine Terraform state

Read `terraform.tfstate` for learning purposes, but do not change its contents directly.

- Top-level fields can include Terraform version information, a serial value, lineage, outputs, and resource records.
- Resource records identify the resource type, local name, provider, and computed attributes.
- Attributes can include provider-assigned values such as AWS IDs, ARNs, image identifiers, addresses, and tags.
- State also preserves information Terraform uses to understand resource dependencies and associations.

### Commands for inspecting state

| Command | Information displayed |
| --- | --- |
| `terraform show` | Readable representation of the current state snapshot |
| `terraform state list` | Addresses of objects Terraform currently tracks |
| `terraform state show aws_s3_bucket.day61` | Stored details for the bucket resource |
| `terraform state show aws_instance.day61` | Stored details for the EC2 resource |

After both resources have been created, the state listing should include entries similar to:

```text
data.aws_ssm_parameter.al2023
aws_instance.day61
aws_s3_bucket.day61
```

The `terraform state` inspection commands display the stored state; they do not independently perform a full refresh against AWS.

### Reasons to protect the state file

- **Avoid hand-editing:** Terraform depends on accurate resource addresses, IDs, and metadata. An accidental change can break the link to a live AWS object and lead to an incorrect plan. Use supported state commands or import procedures for state maintenance.
- **Keep it out of Git:** State may contain secret values and internal infrastructure details in readable form. Marking an output or variable as sensitive does not encrypt its value inside the state file.
- **Use protected shared storage for team workflows:** A remote backend with appropriate access controls, encryption, versioning, and locking is a safer collaboration pattern than sharing a local state file through Git.

Create `.gitignore` in the project directory:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
crash.*.log
*.tfvars
*.tfvars.json
.env
.env.*
!.env.example
```

Keep `main.tf`, `.gitignore`, `.terraform.lock.hcl`, and this Markdown document in Git. Do not commit the state, credentials, or saved plan files. If a state file was already added to Git, adding an ignore pattern alone does not remove it from the repository's history.

References: [Terraform state](https://developer.hashicorp.com/terraform/language/state/purpose) · [Sensitive values](https://developer.hashicorp.com/terraform/language/manage-sensitive-data) · [State command tutorial](https://developer.hashicorp.com/terraform/tutorials/state/state-cli)

## 6. Change the EC2 tag and remove the lab

### Update the instance label

In the EC2 resource, replace the current Name tag with:

```hcl
Name = "TerraWeek-Modified"
```

Reformat and preview the proposed update:

```bash
terraform fmt
terraform plan
```

### Read the plan symbols

| Symbol | Action represented |
| --- | --- |
| `+` | Add an object |
| `~` | Modify an existing object without replacing it |
| `-` | Remove an object |
| `-/+` | Remove the old object, then create its replacement |
| `+/-` | Create the replacement before removing the old object |

For a Name-tag-only edit, with no unrelated drift or image change, the expected result is one in-place modification:

```text
Plan: 0 to add, 1 to change, 0 to destroy.
```

Apply after reviewing the plan:

```bash
terraform apply
```

Check the updated tag in the EC2 console or with the AWS CLI. The instance ID should remain the same for a tag-only update.

### Remove the lab resources

From the same project directory, inspect the deletion plan first:

```bash
terraform plan -destroy
```

Confirm that the plan refers only to the bucket and instance managed by this lab. Then run:

```bash
terraform destroy
```

Enter `yes` after checking the proposed removals. If both resources are still managed and successfully deleted, the expected summary is:

```text
Destroy complete! Resources: 2 destroyed.
```

The SSM parameter was only read and is not removed. Existing networking resources not declared as managed resources in this project are also outside this cleanup.

### Confirm cleanup

- S3: verify the lab bucket is absent.
- EC2: confirm the instance has reached the `terminated` state; its console record can remain visible for a period.
- Terraform: inspect `terraform state list` and confirm that the managed S3 and EC2 entries are gone.
- EBS: confirm the root volume was deleted according to the instance's termination settings.
- If S3 refuses deletion because objects remain, inspect only this lab bucket and remove its contents (including old versions if bucket versioning was enabled) before retrying.
- Retain the configuration and state until the cleanup has been checked.

References: [Terraform plan](https://developer.hashicorp.com/terraform/tutorials/cli/plan) · [Terraform destroy](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-destroy)

## Evidence and results to record

- [ ] Terraform CLI version captured.
- [ ] AWS CLI version captured.
- [ ] Active AWS identity checked; account secrets omitted from evidence.
- [ ] S3 bucket creation confirmed in the AWS console.
- [ ] EC2 instance shown in the Sydney console with its first Name tag.
- [ ] State inspection commands executed.
- [ ] Tag update checked while retaining the same instance ID.
- [ ] Terraform deletion completed and cloud resources checked afterward.

| Result item | Recorded value |
| --- | --- |
| Terraform release | Add the value from `terraform -version` |
| AWS CLI release | Add the value from `aws --version` |
| AWS region | `ap-southeast-2` |
| S3 bucket | `ashish-day61-bucket` (confirm against state and AWS) |
| EC2 type | `t3.micro` |
| EC2 identifier | Add the output from Terraform |
| Updated Name tag | `TerraWeek-Modified` (after applying the tag change) |
| Cleanup | Record the actual destroy result |

## Troubleshooting notes

| Message or symptom | What to inspect |
| --- | --- |
| `No valid credential sources found` | Check the active role/profile and run `aws sts get-caller-identity`. |
| `AccessDenied` with an explicit SCP Deny | Ask the AWS Organizations administrator to review the applicable policy; an IAM Allow cannot override the Deny. |
| `AccessDenied` for an IAM action | Identify the denied API operation and request the required permission for the identity running Terraform. |
| Duplicate provider or resource declaration | Terraform loads every `.tf` file in the directory; move LocalStack configuration out of the real-AWS project or remove duplicate declarations. |
| S3 bucket is not in state | Confirm whether it exists in AWS; if it was made outside this state, use the appropriate import workflow rather than assuming Terraform knows it. |
| `InvalidParameterCombination` for `t2.micro` | Check the region's `free-tier-eligible` instance-type filter and the account's remaining Free Tier benefits; this lab selected `t3.micro` from the returned list. |
| Image ID is not available | Check the selected region and CPU architecture; resolve the regional Amazon Linux 2023 public parameter. |
| No default subnet or VPC | Choose an existing subnet and compatible security group in the same region, then set their IDs explicitly. |
| Terraform proposes an unexpected EC2 replacement | Review the attributes marked for replacement; a changed AMI resolved from a moving public parameter is one possible cause. |
| `BucketNotEmpty` during cleanup | Remove only the lab bucket's remaining objects and versions, then retry deletion. |
