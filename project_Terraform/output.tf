output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "public_route_table_id" {
  value = aws_route_table.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "load_balancer_dns_name" {
  value = aws_lb.main.dns_name
}

output "rds_instance_address" {
  value = aws_db_instance.default.address
}
