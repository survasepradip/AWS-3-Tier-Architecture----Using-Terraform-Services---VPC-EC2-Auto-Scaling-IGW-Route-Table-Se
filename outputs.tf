
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "priavate_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database_subnets[*].id
}

output "dns_name" {
  value = aws_route53_record.www.fqdn
}