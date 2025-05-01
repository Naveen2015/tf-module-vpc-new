output "subnet_ids_naveen" {
  value = aws_subnet.main.*.id
}