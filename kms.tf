data "aws_caller_identity" "current" {}

# EC2 KMS Key and Policy
resource "aws_kms_key" "ec2" {
  description             = "KMS key for EC2 encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7
}

resource "aws_kms_key_policy" "ec2_key_policy" {
  key_id = aws_kms_key.ec2.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableRootPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowEC2RoleAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.webapp_role.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowServiceLinkedRoleUseOfKey",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource = "*"
      }
    ]
  })
}

# RDS KMS Key and Policy
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7
}

resource "aws_kms_key_policy" "rds_key_policy" {
  key_id = aws_kms_key.rds.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableRootPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowRDSUseOfKey",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# S3 KMS Key and Policy
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7
}

resource "aws_kms_key_policy" "s3_key_policy" {
  key_id = aws_kms_key.s3.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableRootPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowS3UseOfKey",
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEC2RoleAccessToS3Key",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.webapp_role.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# Secrets KMS Key and Policy
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  deletion_window_in_days = 7
}

resource "aws_kms_key_policy" "secrets_key_policy" {
  key_id = aws_kms_key.secrets.key_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "EnableRootPermissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowSecretsManagerUseOfKey",
        Effect = "Allow",
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        },
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowEC2RoleAccessToSecretsKey",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.webapp_role.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowLambdaRoleAccessToSecretsKey",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        },
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Policies for KMS access
resource "aws_iam_policy" "ec2_kms_policy" {
  name        = "${var.environment}-EC2KMSAccessPolicy"
  description = "Policy to allow EC2 role to use KMS for disk encryption"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ],
        Resource = [
          aws_kms_key.ec2.arn,
          aws_kms_key.secrets.arn,
          aws_kms_key.s3.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_kms_policy_attachment" {
  role       = aws_iam_role.webapp_role.name
  policy_arn = aws_iam_policy.ec2_kms_policy.arn
}

# KMS Aliases
resource "aws_kms_alias" "ec2" {
  name          = "alias/${var.environment}-ec2"
  target_key_id = aws_kms_key.ec2.key_id
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.environment}-rds"
  target_key_id = aws_kms_key.rds.key_id
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.environment}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.environment}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}