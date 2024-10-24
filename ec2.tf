resource "aws_instance" "web_app" {
  ami           = var.custom_ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id

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

sudo chown -R csye6225:csye6225 /opt/webapp/webapp

# Set the correct permissions (600) for the .env file
chmod 600 /opt/webapp/webapp/.env

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