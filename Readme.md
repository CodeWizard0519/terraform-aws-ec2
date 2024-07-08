### README.md
---
# AWS EC2 Instance Setup with Terraform

This document provides a comprehensive guide to create an AWS EC2 instance, including setting up a VPC, subnet, security group, internet gateway, and route table using Terraform.

## Prerequisites

- **AWS Account**: Ensure you have an AWS account.
- **Terraform**: Install Terraform on your local machine. Follow the [official installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
- **AWS CLI**: Install the AWS CLI and configure it with your credentials. Follow the [AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).

## Steps

### Step 1: Generate SSH Key Pair

Generate an SSH key pair to use for connecting to your EC2 instance.

```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/my-key-pair
```

This will create two files:
- `~/.ssh/my-key-pair` (private key)
- `~/.ssh/my-key-pair.pub` (public key)

### Step 2: Import the Key Pair to AWS

1. **Copy the public key**:
    ```sh
    cat ~/.ssh/my-key-pair.pub
    ```

2. **Import the Key Pair via AWS Management Console**:
   - Go to the [EC2 Dashboard](https://console.aws.amazon.com/ec2/).
   - In the left-hand menu, click on "Key Pairs" under "Network & Security".
   - Click on the "Import key pair" button.
   - Name the key pair (e.g., `my-key-pair`).
   - Paste the contents of the public key file into the "Public key contents" field.
   - Click "Import key pair".

### Step 3: Create a Terraform Configuration File

Create a file named `main.tf` and add the following configuration:

#### Define Providers and Variables

```hcl
provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (replace with your desired AMI ID)
}

variable "key_name" {
  default = "my-key-pair"  # Replace with your key pair name
}
```

#### Create VPC, Subnet, and Internet Gateway

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "MySubnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
```

#### Create Security Group

```hcl
resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to the world (change to your IP for security)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}
```

#### Launch EC2 Instance

```hcl
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.main.id
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.main.id]

  associate_public_ip_address = true

  tags = {
    Name = "MyEC2Instance"
  }
}
```

#### Outputs (Optional)

```hcl
output "instance_public_ip" {
  value = aws_instance.main.public_ip
}

output "instance_public_dns" {
  value = aws_instance.main.public_dns
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.main.id
}

output "security_group_id" {
  value = aws_security_group.main.id
}
```

### Step 4: Apply the Terraform Configuration

1. **Initialize Terraform**:
    ```sh
    terraform init
    ```

2. **Review the Plan**:
    ```sh
    terraform plan
    ```

3. **Apply the Configuration**:
    ```sh
    terraform apply
    ```

This will create the VPC, subnet, internet gateway, route table, security group, and EC2 instance as specified in the configuration.

### Accessing Your EC2 Instance

Once the EC2 instance is running, you can access it via SSH:

```sh
ssh -i ~/.ssh/my-key-pair ec2-user@<public_ip>
```

Replace `<public_ip>` with the public IP address of your instance, which you can find in the Terraform output or the AWS Management Console.
