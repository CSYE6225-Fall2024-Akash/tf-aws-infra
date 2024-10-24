resource "aws_db_parameter_group" "custom" {
  family = "mysql5.7"
  name   = "${var.environment}-custom-pg"

  parameter {
    name  = "general_log"
    value = "1"
  }
}