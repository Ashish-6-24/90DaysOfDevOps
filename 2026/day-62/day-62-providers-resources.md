# Day 62 - Terraform AWS Infrastructure: Providers, Resources, Dependencies, and Lifecycle

## Overview

Day 62 puts Terraform concepts into practice by defining a connected AWS environment as code. The work covers provider configuration, VPC networking, EC2 compute, SSH key-pair registration, S3 storage, dependency ordering, lifecycle behavior, and infrastructure cleanup.

The main goal is to understand how Terraform builds a resource graph and uses it to create, update, replace, and remove cloud infrastructure in a predictable order.

## Objectives

- Configure the HashiCorp AWS provider and control its version range.
- Initialize a Terraform working directory and inspect `.terraform.lock.hcl`.
- Provision an AWS VPC, public subnet, Internet Gateway, route table, and route table association.
- Configure a security group for SSH and HTTP traffic.
- Register a locally generated SSH public key as an AWS EC2 key pair.
- Launch an EC2 instance in the public subnet.
- Use implicit references and `depends_on` to express resource ordering.
- Inspect the Terraform dependency graph.
- Understand `create_before_destroy`, `prevent_destroy`, and `ignore_changes`.
- Review infrastructure changes and remove lab resources safely.

---

## Task 1: Configure the AWS Provider

The AWS provider is Terraform's interface to the AWS API. It translates Terraform resource operations into AWS requests for services such as VPC, EC2, and S3.

### Provider Configuration

Example `providers.tf`:

```hcl
terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}
```

- `required_version` sets the supported Terraform CLI version range.
- `source` identifies the provider package maintained by HashiCorp.
- `version` restricts which AWS provider releases Terraform may select.
- `region` determines the AWS region in which regional resources are managed.
- AWS credentials should be supplied through a supported credentials profile, environment variables, or an attached instance role—not hard-coded in Terraform files.

### Provider Version Constraints

| Constraint | Meaning |
|---|---|
| `~> 5.0` | Accepts compatible 5.x releases and excludes 6.0.0 or later. |
| `>= 5.0` | Accepts 5.0.0 and later releases, including later major versions. |
| `= 5.0.0` | Pins the provider to exactly version 5.0.0. |

### Initialize the Working Directory

```bash
terraform init
```

- Downloads the provider package required by the configuration.
- Creates the local `.terraform/` working directory.
- Writes or updates `.terraform.lock.hcl` with the selected provider version and package checksums.

### Why the Lock File Matters

- Keeps provider selection consistent between local machines and CI/CD runners.
- Records the exact provider release Terraform selected.
- Stores checksums that help verify the downloaded provider package.
- Should normally be committed to version control so collaborators use the same provider selection.
- The `.terraform/` directory is local initialization data and should not be committed.

**Key takeaway:** Version constraints describe the acceptable provider releases; the lock file records the release selected for this working directory.

---

## Task 2: Build the AWS VPC Network

A Virtual Private Cloud (VPC) is an isolated AWS network where resources can communicate using defined IP ranges, routes, and security controls.

### Networking Resources

| Terraform resource | Configuration purpose |
|---|---|
| `aws_vpc` | Creates the network with CIDR range `10.0.0.0/16`. |
| `aws_subnet` | Creates the public subnet with CIDR range `10.0.1.0/24`. |
| `aws_internet_gateway` | Connects the VPC to the internet when routing and addressing are configured correctly. |
| `aws_route_table` | Adds the default route `0.0.0.0/0` through the Internet Gateway. |
| `aws_route_table_association` | Connects the route table to the public subnet. |

### Public Subnet Requirements

- Set `vpc_id` to the VPC resource ID.
- Use the subnet CIDR `10.0.1.0/24`.
- Set `map_public_ip_on_launch = true` to enable automatic public IPv4 assignment for eligible instance launches.
- Associate the subnet with the route table containing the Internet Gateway route.

### Validate the Network

Run Terraform checks before provisioning:

```bash
terraform fmt
terraform validate
terraform plan
```

After applying the reviewed plan, confirm the following in the AWS console or with AWS CLI:

- VPC exists with CIDR `10.0.0.0/16`.
- Public subnet exists with CIDR `10.0.1.0/24`.
- Internet Gateway is attached to the VPC.
- Route table contains `0.0.0.0/0` pointing to the Internet Gateway.
- Route table association connects the route table to the intended subnet.

**Key takeaway:** A public subnet needs an Internet Gateway route and suitable public IP addressing. Enabling public IP assignment by itself does not create an internet route.

---

## Task 3: Understand Implicit Resource Dependencies

Terraform infers an implicit dependency when one resource configuration uses an attribute from another resource. Terraform then uses those references to determine a valid operation order.

### Dependency Relationships

- **Subnet → VPC:** `aws_subnet.public_subnet` reads `aws_vpc.vpc.id`.
- **Internet Gateway → VPC:** `aws_internet_gateway.igw` uses the VPC ID.
- **Route Table → VPC:** `aws_route_table.public_rt` is created inside the VPC.
- **Default Route → Internet Gateway:** The route uses the Internet Gateway ID as its target.
- **Route Table Association → Subnet:** The association uses the subnet ID.
- **Route Table Association → Route Table:** The association uses the route table ID.
- **Security Group → VPC:** The security group is created in the VPC.
- **EC2 Instance → Subnet:** The instance uses the subnet ID.
- **EC2 Instance → Security Group:** The instance attaches the security group ID.
- **EC2 Instance → Key Pair:** The instance reads the key-pair name from the `aws_key_pair` resource.

### How Terraform Uses These References

- Builds a dependency graph from resource references.
- Creates prerequisite resources before resources that require them.
- Runs independent operations in parallel where possible.
- Reverses dependency order during destruction so dependent resources are removed first.

For example, the subnet needs a real VPC ID. The VPC must therefore exist before AWS can accept the subnet creation request.

**Key takeaway:** Prefer direct resource references because they both supply real resource attributes and express the required creation order.

---

## Task 4: Configure the Security Group, SSH Key Pair, and EC2 Instance

### Security Group

The security group acts as a stateful virtual firewall for the EC2 instance.

Configured lab rules:

- **Inbound TCP 22:** SSH administration.
- **Inbound TCP 80:** HTTP access.
- **Outbound traffic:** Allows traffic to all IPv4 destinations.
- **VPC association:** Places the security group inside the VPC.
- **EC2 attachment:** Applies the rules to the instance through its security group ID.

**Security note:** The lab rule `0.0.0.0/0` on SSH exposes port 22 to the public internet. For a real environment, restrict SSH to a trusted public IP using a `/32` CIDR, or use a managed access method such as AWS Systems Manager where appropriate.

### Create a Local SSH Key Pair

Generate a dedicated key pair on the Ubuntu machine:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/terraweek-key -C "terraweek-ec2"
chmod 600 ~/.ssh/terraweek-key
chmod 644 ~/.ssh/terraweek-key.pub
```

- `terraweek-key` is the private key and must remain on the trusted client machine.
- `terraweek-key.pub` is the public key that can be registered with AWS.
- Keep the private key outside the Terraform project directory.
- Never commit the private key to Git or upload it to a public repository.

### Register the Public Key in AWS

Keep the key-pair resource in a separate `keypair.tf` file:

```hcl
resource "aws_key_pair" "terraweek_key" {
  key_name   = "terraweek-key"
  public_key = file(pathexpand("~/.ssh/terraweek-key.pub"))

  tags = {
    Name = "TerraWeek-KeyPair"
  }
}
```

The EC2 resource should refer to the registered key pair:

```hcl
key_name = aws_key_pair.terraweek_key.key_name
```

- Terraform reads the public key file and registers its contents with EC2.
- AWS stores the public key; the corresponding private key remains on the Ubuntu machine.
- The resource reference creates an implicit dependency, so Terraform registers the key pair before launching the instance.
- Define `aws_key_pair.terraweek_key` only once across the module. Terraform loads all `.tf` files in the same directory as one module.

### EC2 Instance Configuration

The lab instance is configured with these properties:

- AWS region: `ap-southeast-2` (Sydney).
- Operating system image: an available Amazon Linux 2 AMI for that region and architecture.
- Instance type: `t3.micro` in the current lab configuration.
- Subnet: `aws_subnet.public_subnet.id`.
- Public IPv4 association: enabled.
- Security group: `aws_security_group.ec2_sg.id`.
- SSH key: `aws_key_pair.terraweek_key.key_name`.
- Name tag: `TerraWeek-Server`.
- Lifecycle setting: `create_before_destroy = true`.

AMI IDs are region-specific. Do not assume an image ID from another region is valid. Find an available Amazon Linux 2 image in the selected region before applying the configuration:

```bash
aws ec2 describe-images \
  --region ap-southeast-2 \
  --owners amazon \
  --filters \
    "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    "Name=state,Values=available" \
  --query 'sort_by(Images,&CreationDate)[-5:].[ImageId,Name,CreationDate]' \
  --output table
```

Select an image ID from the returned results and use it for the EC2 `ami` argument. Confirm it before deployment:

```bash
aws ec2 describe-images \
  --region ap-southeast-2 \
  --image-ids AMI_ID_FROM_THE_RESULTS \
  --query 'Images[0].[ImageId,Name,State,Architecture]' \
  --output table
```

### Verify EC2 Access

After applying a reviewed plan:

- Confirm the instance reaches the `running` state.
- Check its VPC, subnet, security group, key-pair name, and public IPv4 address.
- Confirm the route table is associated with the subnet.
- Confirm SSH ingress permits the connecting client IP.
- Connect using the private key and the Amazon Linux default username:

```bash
ssh -i ~/.ssh/terraweek-key ec2-user@PUBLIC_IP_ADDRESS
```

**Key takeaway:** EC2 access depends on a valid regional AMI, an existing regional key pair, a reachable network path, a public address, and matching security group rules.

---

## Task 5: Express Explicit Dependencies and Inspect the Graph

Terraform normally discovers ordering through attribute references. Some operational relationships do not involve a direct attribute reference, so they may need an explicit dependency.

### S3 Bucket Dependency

The lab S3 bucket uses `depends_on` to make its creation wait until the EC2 instance resource has been processed:

```hcl
resource "aws_s3_bucket" "app_logs" {
  bucket = "terraweek-app-logs-2k26-9193"

  depends_on = [
    aws_instance.ec2
  ]

  tags = {
    Name = "TerraWeek-app-logs"
  }
}
```

- The bucket does not consume an EC2 attribute in its configuration.
- `depends_on` supplies an explicit ordering relationship.
- The bucket is planned after the EC2 instance.
- During destruction, the dependent bucket is handled before the EC2 instance.
- An ordering dependency does not prove that software on the EC2 instance is installed, healthy, or ready to receive traffic.

Use explicit dependencies only when the relationship is real and cannot be represented more clearly through a resource attribute reference.

### Generate a Terraform Dependency Graph

Install Graphviz if it is not already available:

```bash
sudo apt-get update
sudo apt-get install -y graphviz
```

Generate the graph:

```bash
terraform graph -type=plan | dot -Tpng -o terraform-dependency-graph.png
```

The graph can help inspect:

- VPC and subnet relationships.
- Internet Gateway and route dependencies.
- Security group and EC2 ordering.
- SSH key-pair registration before EC2 creation.
- The explicit S3-to-EC2 dependency.

**Key takeaway:** Use implicit dependencies for normal resource relationships and reserve `depends_on` for ordering requirements that Terraform cannot infer from attributes.

---

## Task 6: Apply Lifecycle Rules and Clean Up Resources

Terraform lifecycle meta-arguments influence how Terraform handles replacement, deletion protection, and selected attribute changes.

### `create_before_destroy`

- Requests that Terraform create a replacement resource before removing the existing resource.
- Can reduce interruption during replacement when both resource instances can coexist.
- Is configured on the EC2 resource in this lab.
- Does not guarantee application health or zero downtime; traffic checks and application readiness require additional design.

Example:

```hcl
lifecycle {
  create_before_destroy = true
}
```

### `prevent_destroy`

- Rejects a Terraform plan that would destroy the protected resource while the lifecycle rule remains in the configuration.
- Can help guard critical resources such as production databases.
- Must be considered carefully during planned replacement or decommissioning.

Example:

```hcl
lifecycle {
  prevent_destroy = true
}
```

### `ignore_changes`

- Excludes selected attributes from normal update comparisons after initial creation.
- Can be useful when an external process is intentionally managing particular attributes.
- Can also conceal configuration drift if applied without a clear ownership decision.

Example:

```hcl
lifecycle {
  ignore_changes = [tags["ManagedBy"]]
}
```

### Review a Replacement Plan

Changing an EC2 AMI normally requires replacement because the AMI is an immutable launch parameter for an existing instance. With `create_before_destroy`, inspect the plan to confirm the replacement order and review any cost or coexistence implications.

```bash
terraform plan
```

Do not apply a replacement until the plan shows the intended actions and the replacement AMI has been verified.

### Destroy Lab Infrastructure

When the lab is ready for removal, first inspect the resources tracked in Terraform state:

```bash
terraform state list
```

Review the destruction plan:

```bash
terraform plan -destroy
```

If the plan contains only the intended lab resources, run:

```bash
terraform destroy
```

- Terraform removes dependent resources before the resources they rely on.
- Associations and compute resources are removed before their supporting network components where required by the dependency graph.
- The S3 bucket is subject to its explicit dependency on the EC2 resource.
- An S3 bucket containing objects may need to be emptied before Terraform can delete it.
- Verify in the AWS console that no lab resources remain, and check for any manually created or unmanaged resources separately.

**Key takeaway:** Lifecycle settings change Terraform's resource handling behavior; the dependency graph determines a valid ordering for creation and removal. Always inspect a destroy plan before cleanup.

---

## Troubleshooting Notes

### 1. `InvalidAMIID.NotFound`

**Observed symptom:** EC2 creation failed because the configured AMI ID could not be found.

**Likely cause:** The ID was incorrect, removed, or belonged to a different AWS region.

**Resolution:**

- Confirm the provider region.
- Query available Amazon Linux 2 images in that same region using the command in Task 4.
- Replace the stale ID with a returned, available AMI ID.
- Verify the selected image using `describe-images` before running `terraform apply`.

### 2. `InvalidKeyPair.NotFound`

**Observed symptom:** EC2 creation failed because AWS could not find `terraweek-key`.

**Likely cause:** Creating a key with `ssh-keygen` only creates local files; it does not register the public key with EC2.

**Resolution:**

- Confirm `~/.ssh/terraweek-key.pub` exists.
- Define `aws_key_pair.terraweek_key` in `keypair.tf`.
- Set the EC2 `key_name` to `aws_key_pair.terraweek_key.key_name`.
- Ensure the provider and key pair use the same AWS region.
- Keep the private key on the local machine and never commit it.

### 3. Duplicate `aws_key_pair` Resource

**Observed symptom:** Terraform reported that `aws_key_pair.terraweek_key` was declared more than once.

**Likely cause:** The same resource was defined in both `main.tf` and `keypair.tf`.

**Resolution:**

- Keep the key-pair resource in `keypair.tf` only.
- Remove the duplicate block from `main.tf`.
- Keep the resource reference in the EC2 block.
- Remember that all `.tf` files in one directory are loaded as a single Terraform module.

### 4. S3 `AccessDenied` or Organization Policy Denial

**Observed symptom:** S3 bucket creation can be rejected even when the IAM user appears to have an S3 permission policy.

**Possible cause:** An AWS Organizations Service Control Policy (SCP) explicitly denies the requested action. An IAM allow policy cannot override an applicable explicit SCP deny.

**Resolution:**

- Check the complete AWS error message to identify whether the denial comes from an organization policy.
- Ask the AWS Organizations administrator to review the applicable SCP and account permissions.
- Do not repeatedly change Terraform code when the blocking rule is outside the account's IAM permissions.
- Use an AWS account or environment where the required S3 action is authorized, if available.

### 5. SSH Connection Failure

**Check the following before troubleshooting the SSH client:**

- EC2 instance is running and has a public IPv4 address.
- Subnet route table has a default route to the attached Internet Gateway.
- Security group permits TCP 22 from the connecting public IP.
- The correct private key is being used and has restrictive permissions.
- The username is `ec2-user` for Amazon Linux.
- The key pair was registered in the same AWS region as the instance.

### 6. Terraform Validation or Duplicate Configuration Errors

**Resolution sequence:**

```bash
terraform fmt
terraform validate
terraform plan
```

- Check the file and line number reported by Terraform.
- Search all `.tf` files for duplicate resource type/name combinations.
- Check resource references for spelling and matching labels.
- Keep each logical resource declaration in one place within the module.

---

## Final Verification Checklist

Use this checklist after performing and verifying each action. Leave an item unchecked until it has been confirmed.

- [ ] AWS provider configured with the intended region and version constraint.
- [ ] `terraform init` completed and `.terraform.lock.hcl` reviewed.
- [ ] VPC created with the expected CIDR.
- [ ] Public subnet created with the expected CIDR and public IPv4 assignment setting.
- [ ] Internet Gateway attached to the VPC.
- [ ] Default route points to the Internet Gateway.
- [ ] Route table association connects the public subnet to the intended route table.
- [ ] Security group rules reviewed and attached to EC2.
- [ ] Local SSH key pair generated and public key registered in AWS.
- [ ] EC2 launched with a valid AMI for the configured region.
- [ ] EC2 public IPv4 address and SSH connectivity verified.
- [ ] S3 bucket dependency configured and bucket creation confirmed, if permitted by account policy.
- [ ] Terraform dependency graph generated and inspected.
- [ ] Lifecycle behavior reviewed through a Terraform plan.
- [ ] Destroy plan reviewed before removing the lab.
- [ ] AWS console and Terraform state checked for remaining resources.

---

## Key Takeaways

- **Terraform Provider:** Provider configuration connects Terraform to AWS and constrains provider releases.
- **Dependency Lock File:** `.terraform.lock.hcl` records the selected provider version and checksums.
- **Infrastructure as Code (IaC):** VPC, subnet, routing, security, compute, and storage resources can be defined and managed declaratively.
- **AWS Networking:** A public subnet needs correct route-table association, an Internet Gateway route, and appropriate IP addressing.
- **Implicit Dependencies:** Resource references let Terraform infer prerequisites and construct its execution graph.
- **Explicit Dependencies:** `depends_on` expresses ordering when no attribute reference captures the relationship.
- **EC2 and SSH:** A regional AMI, registered key pair, security group, and network path are all required for successful access.
- **Lifecycle Management:** Lifecycle arguments influence replacement, deletion protection, and drift handling.
- **Infrastructure Cleanup:** Reviewing the destroy plan and checking for leftover resources helps control cloud costs.

## Conclusion

Day 62 develops practical Terraform skills for managing connected AWS infrastructure. The exercise links provider management, network provisioning, EC2 access, S3 ordering, dependency graphs, and lifecycle controls into one Infrastructure as Code workflow.

The troubleshooting work also reinforces an important operational habit: diagnose whether a failure comes from Terraform configuration, a regional AWS resource identifier, an unregistered credential, or an account-level permission boundary before changing infrastructure code.

#Terraform #AWS #TerraformAWS #InfrastructureAsCode #DevOps #CloudInfrastructure #90DaysOfDevOps
