resource "aws_instance" "web_app" {
  ami                  = var.custom_ami_id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public[0].id
  iam_instance_profile = aws_iam_instance_profile.webapp_profile.name

  vpc_security_group_ids = [aws_security_group.application.id]

  root_block_device {
    volume_size           = 25
    volume_type           = "gp2"
    delete_on_termination = true
  }

  disable_api_termination = false


  user_data = base64encode(<<EOF
#!/bin/bash
echo "DB_HOST=${aws_db_instance.mydb.address}" >> /opt/webapp/webapp/.env
echo "DB_USER=csye6225" >> /opt/webapp/webapp/.env
echo "DB_PASSWORD=${var.db_password}" >> /opt/webapp/webapp/.env
echo "DB_NAME=csye6225" >> /opt/webapp/webapp/.env
echo "DB_PORT=${var.db_port}" >> /opt/webapp/webapp/.env
echo "PORT=3000" >> /opt/webapp/webapp/.env
echo "S3_BUCKET_NAME=${aws_s3_bucket.app_bucket.bucket}" >> /opt/webapp/webapp/.env



sudo chown -R csye6225:csye6225 /opt/webapp/webapp

# Set the correct permissions (600) for the .env file
chmod 600 /opt/webapp/webapp/.env

# CloudWatch Agent Configuration
# Create CloudWatch agent configuration directory
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

# Navigate to the application directory (ensure your app is here)
cd /opt/webapp/webapp
sudo systemctl start app.service 
EOF
  )

  tags = {
    Name        = "${var.environment}--app-server"
    Environment = var.environment
  }
}