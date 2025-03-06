# HR Engagement App - AWS Infrastructure

This directory contains the Terraform infrastructure as code (IaC) for deploying the HR Engagement Application on AWS. The infrastructure is designed to be secure, scalable, and maintainable.

## Infrastructure Overview

The infrastructure is deployed using the following AWS services:

- **Amazon ECS with Fargate** for containerized application deployment
- **Application Load Balancer (ALB)** for traffic distribution
- **Amazon ECR** for container image storage
- **Amazon S3** for storage and Terraform state management
- **Amazon CloudWatch** for monitoring and logging
- **IAM Roles and Policies** for access control

## Directory Structure

```
terraform/
├── main.tf                # Main configuration file
├── variables.tf           # Variable definitions
├── outputs.tf             # Output definitions
├── providers.tf           # Provider configurations
├── modules/               # Reusable modules
│   ├── networking/        # VPC, subnets, security groups, ALB
│   ├── ecs/               # ECS cluster, service, task definition
│   └── security/          # IAM roles and policies, S3 buckets
└── environments/          # Environment-specific configurations
    ├── dev/               # Development environment
    └── prod/              # Production environment
```

## Prerequisites

Before deploying the infrastructure, ensure you have:

1. AWS CLI installed and configured with appropriate credentials
2. Terraform v1.0.0 or later installed
3. Docker installed (for building and pushing container images)
4. Created an S3 bucket named `app-builder-dplmt-tf-state` for storing Terraform state

## Deployment Process

The deployment process consists of two parts:
1. **Infrastructure Deployment (Manual)**: Using Terraform to provision AWS resources
2. **Container Deployment (Automated)**: Using GitHub Actions to build and deploy the container

### Infrastructure Deployment (Manual)

#### 1. Prepare Terraform State Storage

Create the S3 bucket for Terraform state if it doesn't exist:

```bash
aws s3 mb s3://app-builder-dplmt-tf-state
aws s3api put-bucket-versioning --bucket app-builder-dplmt-tf-state --versioning-configuration Status=Enabled
```

#### 2. Deploy the Infrastructure

Deploying the infrastructure will create all necessary AWS resources, including the ECR repository.

**For Development Environment:**

```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

**For Production Environment:**

```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply -var="container_tag=v1.0.0"  # Specify a specific tag if not using 'latest'
```

After applying the Terraform configuration, note the outputs including the ECR repository URL and ALB DNS name. The ECR repository is automatically created as part of the infrastructure.

#### 3. Get ECR Repository URL

After deployment, get the ECR repository URL:

```bash
# For development
aws ecr describe-repositories --repository-names hr-engagement-app-dev --query 'repositories[0].repositoryUri' --output text

# For production
aws ecr describe-repositories --repository-names hr-engagement-app-prod --query 'repositories[0].repositoryUri' --output text
```

### Container Deployment (Automated)

Once the infrastructure is deployed, container deployment is handled by GitHub Actions.

#### Setting Up GitHub Actions Deployment

The Terraform infrastructure includes an IAM user specifically for GitHub Actions with the necessary permissions to:
- Push images to ECR
- Update ECS services
- Describe load balancers to get application URLs

When you apply the Terraform configuration, it will output the following:
- `github_actions_user_name`: The name of the IAM user
- `github_actions_access_key_id`: The access key ID for the user
- `github_actions_secret_access_key`: The secret access key for the user (sensitive)

After applying the Terraform configuration, you can retrieve these values:

```bash
# For the access key ID
terraform output github_actions_access_key_id

# For the secret access key (this is sensitive)
terraform output -raw github_actions_secret_access_key

# For development environment
cd terraform/environments/dev
terraform output github_actions_access_key_id
terraform output -raw github_actions_secret_access_key

# For production environment
cd terraform/environments/prod
terraform output github_actions_access_key_id
terraform output -raw github_actions_secret_access_key
```

These credentials should be added as secrets in your GitHub repository:

1. Go to your GitHub repository
2. Navigate to Settings > Secrets and variables > Actions
3. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: The access key ID from Terraform output
   - `AWS_SECRET_ACCESS_KEY`: The secret access key from Terraform output

#### GitHub Actions Workflow

The repository includes a GitHub Actions workflow file (`.github/workflows/deploy.yml`) that automates the container build and deployment process. The workflow will:

1. Build the Docker image
2. Push the image to Amazon ECR
3. Trigger a new deployment in the ECS service (if it exists)
4. Verify the deployment and provide a summary

The workflow can be triggered:
- Automatically when code is pushed to the `main` branch (deploys to dev)
- Manually through the GitHub Actions interface (choose dev or prod environment)

**Note:** The GitHub Actions workflow expects that the infrastructure (including the ECR repository) has already been deployed using Terraform. If the infrastructure hasn't been deployed, the workflow will fail with an error message.

## Destroying the Infrastructure

To destroy the infrastructure when it's no longer needed:

```bash
# For development environment
cd terraform/environments/dev
terraform destroy

# For production environment
cd terraform/environments/prod
terraform destroy
```

> **Important:** This will destroy all resources created by Terraform, including:
> - The ECS service and task definitions
> - The ECR repository and all container images
> - The IAM user for GitHub Actions (invalidating any credentials being used)
> - The Application Load Balancer
> - The S3 bucket and any data stored in it
>
> Make sure to backup any important data before running this command.

## Security Considerations

The infrastructure includes several security features:

- IP-based access restrictions for the application
- Security groups with least privilege permissions
- IAM roles and policies following the principle of least privilege
- S3 bucket encryption and public access blocking
- Container image scanning in ECR
- Dedicated IAM user for GitHub Actions with limited permissions
  - Access restricted to only the resources needed for deployment
  - No permissions to modify infrastructure or access sensitive resources

## Monitoring and Logging

The application uses CloudWatch for monitoring and logging:

- Container logs are stored in CloudWatch Logs
- ECS service metrics are available in CloudWatch Metrics
- Auto-scaling is configured based on CPU and memory metrics

You can access the logs and metrics in the AWS Management Console.

## Customization

To customize the infrastructure, modify the variables in the respective environment directories. Common customizations include:

- `container_tag`: Specify which container image tag to deploy (defaults to 'latest')
- `container_cpu` and `container_memory`: Adjust the resources allocated to the container
- `desired_count`: Change the number of container instances
- `allowed_ip_addresses`: Update the list of allowed IP addresses
- `enable_auto_scaling`: Enable or disable auto-scaling
- `min_capacity` and `max_capacity`: Adjust the auto-scaling limits