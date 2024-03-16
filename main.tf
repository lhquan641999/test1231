#Configure AWS
provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.aws_region
    version = "~> 3.26"
}
#create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support
 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-vpc"
  }
}
#create igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-igw"
  }
}
#create route
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  } 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-rt"
  } 
}

#create subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.sbn_cidr_block
  map_public_ip_on_launch = var.sbn_public_ip
  availability_zone       = "${var.aws_region}${var.aws_region_az}" 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-subnet"
  }
}

#association subnet you want 
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.rt.id
}


#create security group for openvpn
resource "aws_security_group" "openvpn" {
  name        = "sg-openvpn"
  description = "Rules for openvpn"
  vpc_id      = aws_vpc.vpc.id 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-sg"
  }
}

#create security group for internal traffic
resource "aws_security_group" "internal" {
  name        = "sg-internal"
  description = "Rules for internal traffic"
  vpc_id      = aws_vpc.vpc.id 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-sg"
  }
}

#create security group for internet traffic
resource "aws_security_group" "internet" {
  name        = "sg-internet"
  description = "Rules for internet traffic"
  vpc_id      = aws_vpc.vpc.id 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-sg"
  }
}

#create security group for developer 
resource "aws_security_group" "dev" {
  name        = "sg-dev"
  description = "Rules for developer "
  vpc_id      = aws_vpc.vpc.id 
  tags = {
    "Owner" = var.owner
    "Name"  = "${var.owner}-sg"
  }
}


######create rules security group
# Allow all outbound traffic 
resource "aws_security_group_rule" "allow_outbound_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]
  description = "allow outbound all"

  security_group_id = [aws_security_group.openvpn.id,aws_security_group.internet.id]
}

# Allow all inbound traffic via https 
resource "aws_security_group_rule" "allow_inbound_all_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  description = "allow outbound all"

  security_group_id = "${aws_security_group.openvpn.id}"
}

# Allow all inbound internal traffic
resource "aws_security_group_rule" "allow_inbound_internal" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = ["10.0.0.0/16"]
  description = "allow inbound internal traffic"

  security_group_id = "${aws_security_group.internal.id}"
}

# Allow all outbound internal traffic
resource "aws_security_group_rule" "allow_outbound_internal" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"
  cidr_blocks = ["10.0.0.0/16"]
  description = "allow outbound internal traffic"

  security_group_id = "${aws_security_group.internal.id}"
}

# Allow inbound via Pulse by https
resource "aws_security_group_rule" "allow_inbound_pulse_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["192.46.83.0/24"]
  description = "allow inbound pulse via https"

  security_group_id = "${aws_security_group.internet.id}"
}

# Allow inbound via Pulse by http
resource "aws_security_group_rule" "allow_inbound_pulse_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["192.46.83.0/24"]
  description = "allow inbound pulse via http"

  security_group_id = "${aws_security_group.internet.id}"
}

# Allow inbound via BIG IP by https
resource "aws_security_group_rule" "allow_inbound_bigip_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["20.139.0.0/16"]
  description = "allow inbound via BIG IP by https"

  security_group_id = "${aws_security_group.internet.id}"
}

# Allow inbound via BIG IP by http
resource "aws_security_group_rule" "allow_inbound_bigip_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["20.139.0.0/16"]
  description = "allow inbound via BIG IP by http"

  security_group_id = "${aws_security_group.internet.id}"
}

#bucket log
resource "aws_s3_bucket" "log_bucket" {
  bucket = "kingwai-log"
  acl    = "log-delivery-write"
}

#bucket project
resource "aws_s3_bucket" "b" {
  bucket = "kingwai-bucket"
  acl    = "private"

  tags = {
    Name        = "Project Name"
    Environment = "SIT"
  }
# enable version
  versioning {
    enabled = true
  }
#enable log
  logging {
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/"
  }
}


#create multiple instance 
resource "aws_instance" "kwi" {
    for_each = var.servers
    ami             = each.value.amis
    instance_type   = each.value.instance_type
    subnet_id       = aws_subnet.subnet.id
    vpc_security_group_ids      = [aws_security_group.internal.id,aws_security_group.internet.id]
    key_name        = each.value.key_name
    tags = {
        Name        = each.value.Name
        Creator     = "qthai2"
    }
    root_block_device {
        
        device_name = "/dev/xvda"
        volume_size = each.value.volume_size
        volume_type = each.value.volume_type
        delete_on_termination = true
    }
}

#create instance for jenkins
resource "aws_instance" "jenkins" {
  ami                         = "ami-0b4dd9d65556cac22"
  availability_zone           = "${var.aws_region}${var.aws_region_az}"
  instance_type               = "t2.2xlarge"
  vpc_security_group_ids      = [aws_security_group.internal.id,aws_security_group.internet.id]
  subnet_id                   = aws_subnet.subnet.id
  key_name                    = "ssh-key"
 
  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = "250"
    volume_type           = "gp2"
  }
 
  tags = {
    "Owner"               = var.owner
    "Name"                = "jenkins-instance"
    "KeepInstanceRunning" = "false"
  }
  #input file
  user_data = file("./install_jenkins.sh")
}

###output definitions
output "aws_instance_public_dns" {
  value = aws_instance.jenkins.public_dns
}
output "public_ip" {
  value = aws_instance.jenkins.public_ip
}
