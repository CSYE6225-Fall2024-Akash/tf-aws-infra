resource "aws_db_instance" "mydb" {
  identifier             = "csye6225"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "csye6225"
  username               = "csye6225"
  password               = random_password.db_password.result
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds.arn
  parameter_group_name   = aws_db_parameter_group.custom.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.mydb.id]
  db_subnet_group_name   = aws_db_subnet_group.mysubnet.name
  multi_az               = false
  publicly_accessible    = false
}

resource "aws_db_subnet_group" "mysubnet" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "Private DB Subnet Group"
  }
}