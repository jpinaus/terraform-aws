output "EIP_public_IP_address" {
    value = data.aws_eip.wordpress_eip.public_ip
}

output "EC2_private_IP_address" {
    value = aws_instance.EC2.private_ip
}

output "tfc_example_table_arn" {
  value = aws_dynamodb_table.tfc_example_table.arn
}
