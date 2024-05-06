output "ELASTIC_IP" {
  value = aws_eip.coodesh_eip.public_ip
}

output "EC2_Private_IP" {
  value = aws_instance.coodesh-nginx.private_ip
}

output "EC2_Availability_Zone" {
  value = aws_instance.coodesh-nginx.availability_zone
}

output "EC2_Instance_ID" {
  value = aws_instance.coodesh-nginx.id
}

output "VPC_ID" {
  value = aws_vpc.coodesh_vpc.id
}