resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = var.tags
}

# output "vpc_created_submodule" {
#   value = aws_vpc.main.*
# }