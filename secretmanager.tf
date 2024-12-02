# Generate random DB password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# DB Credentials Secret
resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.environment}/database/credentials"
  description = "RDS database credentials"
  kms_key_id  = aws_kms_key.secrets.arn
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "csye6225"
    password = random_password.db_password.result
  })
}

# SendGrid Credentials Secret
resource "aws_secretsmanager_secret" "sendgrid" {
  name        = "${var.environment}/sendgrid/credentials"
  description = "SendGrid API credentials"
  kms_key_id  = aws_kms_key.secrets.arn
}

resource "aws_secretsmanager_secret_version" "sendgrid" {
  secret_id = aws_secretsmanager_secret.sendgrid.id
  secret_string = jsonencode({
    api_key    = var.sendgrid_api_key
    from_email = "noreply@${var.environment}.${var.domain_name}"
  })
}