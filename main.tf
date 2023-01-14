
################################################################################
# CONFIGURE BACKEND
################################################################################

terraform {
  required_version = ">=1.1.0" # version

  backend "s3" {
    bucket         = "3-tier-architecture-implementation"
    key            = "path/env"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

################################################################################
# PROVIDERS BLOCK
################################################################################

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      ChangeCode = "100283836HDHDF"
      component  = var.component
    }
  }
}

################################################################################
# LOCALS BLOCK
################################################################################

locals {
  vpc_id = aws_vpc.this.id
  azs    = slice(data.aws_availability_zones.available.names, 0, 2)
}

################################################################################
# DATA SOURCE BLOCK
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# CREATING VPC
################################################################################

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "kojitechs-vpc"
  }
}

################################################################################
# CREATING INTERNET GATEWAY
################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id

  tags = {
    Name = "kojitechs-igw"
  }
}

################################################################################
# CREATING PUBLIC SUBNETS USING COUNT
################################################################################

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnetcidr)

  vpc_id                  = local.vpc_id
  cidr_block              = var.public_subnetcidr[count.index]
  availability_zone       = local.azs[count.index] # element(local.azs,count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

################################################################################
# CREATING PRIVATE SUBNETS USING COUNT
################################################################################

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnetcidr)

  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnetcidr[count.index]
  availability_zone = local.azs[count.index] # element(local.azs,count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

################################################################################
# CREATING DATABASE SUBNETS USING COUNT
################################################################################

resource "aws_subnet" "database_subnets" {
  count = length(var.database_subnetcidr)

  vpc_id            = local.vpc_id
  cidr_block        = var.database_subnetcidr[count.index]
  availability_zone = local.azs[count.index] # element(local.azs,count.index)

  tags = {
    Name = "database-subnet-${count.index + 1}"
  }
}

################################################################################
# CREATING ROUTE TABLES FOR PUBLIC SUBNETS
################################################################################

resource "aws_route_table" "public_routable" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-routetable"
  }
}

################################################################################
# CREATING PUBLIC ROUTE TABLES ASSOCIATED WITH ?
################################################################################

resource "aws_route_table_association" "public_routetable_association" {
  count = length(aws_subnet.public_subnet)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_routable.id
}

################################################################################
# CREATING DEFAULT ROUTE TABLES 
################################################################################

resource "aws_default_route_table" "defaultroutetable" {
  default_route_table_id = aws_vpc.this.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id
  }
}

################################################################################
# CREATING A NAT GATEWAY
################################################################################ 

resource "aws_nat_gateway" "this" {
  depends_on = [aws_internet_gateway.igw]

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "gw NAT"
  }
}

################################################################################
# CREATING A AN  ELASTICIP
################################################################################ 

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  vpc        = true
}