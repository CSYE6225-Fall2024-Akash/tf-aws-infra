# IAM Role
resource "aws_iam_role" "webapp_role" {
  name = "${var.environment}-webapp-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.environment}-webapp-role"
    Environment = var.environment
  }
}

# CloudWatch Agent Server Policy (AWS Managed Policy)
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.webapp_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# S3 Access Policy
resource "aws_iam_role_policy" "s3_policy" {
  name = "${var.environment}-s3-policy"
  role = aws_iam_role.webapp_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.app_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.app_bucket.id}/*"
        ]
      }
    ]
  })
}

# Instance Profile (combines all policies)
resource "aws_iam_instance_profile" "webapp_profile" {
  name = "${var.environment}-webapp-profile"
  role = aws_iam_role.webapp_role.name
}

# EC2 Role Policy
resource "aws_iam_role_policy" "ec2_secrets" {
  name = "${var.environment}-ec2-secrets-policy"
  role = aws_iam_role.webapp_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          aws_secretsmanager_secret.db_credentials.arn,
          aws_kms_key.secrets.arn
        ]
      }
    ]
  })
}

# Lambda Role Policy
resource "aws_iam_role_policy" "lambda_secrets" {
  name = "${var.environment}-lambda-secrets-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = [
          aws_secretsmanager_secret.sendgrid.arn,
          aws_kms_key.secrets.arn
        ]
      }
    ]
  })
}

# KMS policy for EC2 instance role
resource "aws_iam_role_policy" "kms_policy" {
  name = "${var.environment}-kms-policy"
  role = aws_iam_role.webapp_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ]
        Resource = [
          aws_kms_key.ec2.arn,
          aws_kms_key.secrets.arn,
          aws_kms_key.s3.arn
        ]
      }
    ]
  })
}


