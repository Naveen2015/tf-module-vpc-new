resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(var.tags, { Name = "${var.env}-vpc"})

}

output "vpc_created_submodule" {
  value = aws_vpc.main.*
}

module "subnets" {
  source = "./subnets"
  for_each = var.subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value["cidr_block"]
  azs = each.value["azs"]
  name = each.value["name"]
  tags = var.tags
  env = var.env

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.env}-igw"})
}

resource "aws_eip" "eip" {
  count = length(lookup(lookup(var.subnets, "public",null), "cidr_block",0))
  tags = merge(var.tags, { Name = "${var.env}-eip-${count.index+1}"})
}
# resource "aws_nat_gateway" "example" {
#   allocation_id = aws_eip.example.id
#   subnet_id     = aws_subnet.example.id
#
#   tags = {
#     Name = "gw NAT"
#   }
#
#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.example]
# }