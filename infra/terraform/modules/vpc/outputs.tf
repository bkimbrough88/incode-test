output "arn" {
  value = aws_vpc.main.arn
}

output "cidr" {
  value = aws_vpc.main.cidr_block
}

output "id" {
  value = aws_vpc.main.id
}

output "additional_private_subnet_cidrs" {
  value = [ for az, cidr in var.additional_private_subnet_cidrs : aws_subnet.additional_private[az].cidr_block ]
}

output "main_private_subnet_cidrs" {
  value = [ for az, cidr in var.main_private_subnet_cidrs : aws_subnet.main_private[az].cidr_block ]
}

output "additional_public_subnet_cidrs" {
  value = [ for az, cidr in var.additional_public_subnet_cidrs : aws_subnet.additional_public[az].cidr_block ]
}

output "main_public_subnet_cidrs" {
  value = [ for az, cidr in var.main_public_subnet_cidrs : aws_subnet.main_public[az].cidr_block ]
}