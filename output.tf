
output "cloudwave-private" {
  value = aws_subnet.cloudwave-private[*].id
}

output "cloudwave-public" {
    value = aws_subnet.cloudwave-public[*].id
  
}