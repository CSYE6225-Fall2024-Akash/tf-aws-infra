resource "aws_launch_template" "webapp" {
  name        = "csye6225-launch-template"
  description = "Launch template for webapp instances"

  image_id      = var.custom_ami_id
  instance_type = var.instance_type

  # Network configuration
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.application.id]
  }

  # IAM Instance Profile
  iam_instance_profile {
    name = aws_iam_instance_profile.webapp_profile.name
  }

  # Block Device Mapping
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2.arn
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash

# Install AWS CLI and jq if not present
sudo apt-get update
sudo apt-get install -y jq awscli

# Get DB credentials from Secrets Manager
DB_CREDS=$(aws secretsmanager get-secret-value \
  --secret-id ${aws_secretsmanager_secret.db_credentials.id} \
  --region ${var.region} \
  --query 'SecretString' \
  --output text)

# Parse credentials
DB_USER=$(echo $DB_CREDS | jq -r '.username')
DB_PASSWORD=$(echo $DB_CREDS | jq -r '.password')

echo "DB_HOST=${aws_db_instance.mydb.address}" >> /opt/webapp/webapp/.env
echo "DB_USER=$DB_USER" >> /opt/webapp/webapp/.env
echo "DB_PASSWORD=$DB_PASSWORD" >> /opt/webapp/webapp/.env
echo "DB_NAME=csye6225" >> /opt/webapp/webapp/.env
echo "DB_PORT=${var.db_port}" >> /opt/webapp/webapp/.env
echo "PORT=3000" >> /opt/webapp/webapp/.env
echo "AWS_REGION=${var.region}" >> /opt/webapp/webapp/.env
echo "DOMAIN_NAME=${var.environment}.${var.domain_name}" >> /opt/webapp/webapp/.env
echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.bucket}" >> /opt/webapp/webapp/.env
echo "USER_TOPIC_ARN=${aws_sns_topic.user_verification.arn}" >> /opt/webapp/webapp/.env  

sudo chown -R csye6225:csye6225 /opt/webapp/webapp

# Set the correct permissions (600) for the .env file
chmod 600 /opt/webapp/webapp/.env

# CloudWatch Agent Configuration
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

# Copy CloudWatch configuration from webapp directory
sudo cp /opt/webapp/webapp/cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Set proper permissions for CloudWatch config
sudo chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start and enable CloudWatch agent
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

# Apply CloudWatch configuration
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Restart CloudWatch agent to ensure configuration is applied
sudo systemctl restart amazon-cloudwatch-agent

# Start application
cd /opt/webapp/webapp
sudo systemctl start app.service 
EOF
  )

  # Tags
  tags = {
    Name        = "${var.environment}-launch-template"
    Environment = var.environment
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-webapp-asg-instance"
      Environment = var.environment
    }
  }

  # Disable API termination protection for ASG management
  disable_api_termination = false

  # Enable detailed monitoring for better scaling decisions
  monitoring {
    enabled = true
  }
}
