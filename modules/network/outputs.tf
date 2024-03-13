output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_net_id" {
  value = aws_subnet.net.id
}

output "subnet_app_id" {
  value = aws_subnet.app.id
}

output "subnet_data_id" {
  value = aws_subnet.app.id
}
