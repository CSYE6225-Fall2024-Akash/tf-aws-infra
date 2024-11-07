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