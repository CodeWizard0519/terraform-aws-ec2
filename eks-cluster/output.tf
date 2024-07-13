output "aws-vpc" {
    value = data.aws_availability_zones.available.names
}

output "vpc-cidr" {
    value = aws_vpc.eks-vpc.cidr_block
}