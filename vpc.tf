resource "aws_vpc" "myvpc" {
  cidr_block = varr.vpc_cidr



  tags = {
    Name = "My VPC"
  }
}
