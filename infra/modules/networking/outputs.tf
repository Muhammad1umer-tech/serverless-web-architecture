output "serverless_public_subnet_id" {
  value = aws_subnet.serverless_public_subnet.id
}

output "serverless_private_subnet_id" {
  value = aws_subnet.serverless_private_subnet.id
}

output "custom_vpc_id"{
    value = aws_vpc.serverless_custom_vpc.id
}
