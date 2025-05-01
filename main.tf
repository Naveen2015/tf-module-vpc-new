resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(var.tags, { Name = "${var.env}-vpc"})

}

# output "vpc_created_submodule_kru" {
#   value = module.subnets
# }

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
resource "aws_nat_gateway" "example" {
  count = length(var.subnets["public"].cidr_block)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = module.subnets["public"].subnet_ids[count.index]
  tags = merge(var.tags, { Name = "${var.env}-ngw-${count.index+1}"})


}