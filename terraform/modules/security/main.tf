# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-execution-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.app_name}-ecs-execution-role-${var.environment}"
  }
}

# Attach the ECS Task Execution policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for the application)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.app_name}-ecs-task-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.app_name}-ecs-task-role-${var.environment}"
  }
}

# Custom policy for the application (add permissions as needed)
resource "aws_iam_policy" "app_policy" {
  name        = "${var.app_name}-app-policy-${var.environment}"
  description = "Policy for the HR Engagement Application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.app_name}-*-${var.environment}",
          "arn:aws:s3:::${var.app_name}-*-${var.environment}/*"
        ]
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-app-policy-${var.environment}"
  }
}

# Attach the custom policy to the ECS task role
resource "aws_iam_role_policy_attachment" "app_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

# S3 bucket for application data (if needed)
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.app_name}-data-${var.environment}"

  tags = {
    Name = "${var.app_name}-data-${var.environment}"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################################
# IAM User for GitHub Actions Deployment
#########################################

resource "aws_iam_user" "github_actions" {
  name = "${var.app_name}-github-actions-${var.environment}"
  path = "/deployment/"

  tags = {
    Name        = "${var.app_name}-github-actions-user-${var.environment}"
    Description = "IAM user for GitHub Actions deployments"
  }
}

# Policy for GitHub Actions user
resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.app_name}-github-actions-policy-${var.environment}"
  description = "Policy for GitHub Actions deployment of HR Engagement Application"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ECR permissions
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:DescribeRepositories",
          "ecr:ListImages"
        ]
        Resource = "*"
      },
      # ECS permissions
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks"
        ]
        Resource = [
          "arn:aws:ecs:*:*:service/${var.app_name}-cluster-${var.environment}/${var.app_name}-service-${var.environment}",
          "arn:aws:ecs:*:*:cluster/${var.app_name}-cluster-${var.environment}",
          "arn:aws:ecs:*:*:task-definition/${var.app_name}-task-${var.environment}:*",
          "arn:aws:ecs:*:*:task/${var.app_name}-cluster-${var.environment}/*"
        ]
      },
      # ELB permissions for retrieving application URL
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeLoadBalancers"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.app_name}-github-actions-policy-${var.environment}"
  }
}

# Attach the policy to the GitHub Actions user
resource "aws_iam_user_policy_attachment" "github_actions_policy_attachment" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# Create access keys for the GitHub Actions user
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}