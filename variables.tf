# # Variables for general information
# variable "aws_region" {
#     description = "AWS region to launch servers."
#     default = "ap-southeast-1"
# }
# variable "aws_region_az" {
#   description = "AWS region availability zone"
#   type        = string
#   default     = "a"
# }
# variable "access_key" {
#     description = "AWS access key to launch servers."
#     default = ""
# }
# variable "secret_key" {
#     description = "AWS secret key to launch servers."
#     default = ""
# }
# variable "owner" {
#   description = "Configuration owner"
#   default     = "kwi"
# }
# # Variables for VPC
# variable "vpc_cidr_block" {
#   description = "CIDR block for the VPC"
#   default     = "10.0.0.0/16"
# } 
# variable "vpc_dns_support" {
#   description = "Enable DNS support in the VPC"
#   type        = bool
#   default     = true
# }
# variable "vpc_dns_hostnames" {
#   description = "Enable DNS hostnames in the VPC"
#   type        = bool
#   default     = true
# }
# # Variables for Route Table
# variable "rt_cidr_block" {
#   description = "CIDR block for the route table"
#   type        = string
#   default     = "0.0.0.0/0"
# }
# # Variables for Subnet
# variable "sbn_public_ip" {
#   description = "Assign public IP to the instance launched into the subnet"
#   type        = bool
#   default     = true
# }
# variable "sbn_cidr_block" {
#   description = "CIDR block for the subnet"
#   type        = string
#   default     = "10.0.0.0/20"
# }
# # Variables for Instance

# variable "aws_amis" {
#     default = "ami-0a5d57f8853ce9760"
# }
# variable "instance_type" {
#   description = "Type of the instance"
#   type        = string
#   default     = "t2.micro"
# }
# variable "root_device_type" {
#   description = "Type of the root block device"
#   type        = string
#   default     = "gp2"
# }
# variable "root_device_size" {
#   description = "Size of the root block device"
#   type        = string
#   default     = "15"
# }

# # Variables for multiple Instance linux
# variable "servers" {
#     default = {
#         #IFE server 
#         "1" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "t2.2xlarge"
#             Name = "IFE"
#             volume_size = "250"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         "2" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "t2.2xlarge"
#             Name = "ACCELERATOR"
#             volume_size = "200"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         #PAS server 
#         "3" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "t2.2xlarge"
#             Name = "PAS-LIFE"
#             volume_size = "200"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         "4" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "t2.2xlarge"
#             Name = "PAS-GROUP"
#             volume_size = "200"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         "5" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "t2.2xlarge"
#             Name = "CAS-WS"
#             volume_size = "200"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         "6" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "a1.xlarge"
#             Name = "DMS"
#             volume_size = "300"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         "7" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "a1.2xlarge"
#             Name = "PE-WORKFLOW"
#             volume_size = "150"
#             volume_type = "gp2"
#             key_name = "ssh-key"
#         },
#         "8" = {
#             amis = "ami-00e1cd9fb58632a0e"
#             instance_type = "r5.2xlarge"
#             Name = "DATABASE"
#             volume_size = "700"
#             volume_type = "gp2"
#             key_name = "rdp-key"
#         },
#         "9" = {
#             amis = "ami-0b4dd9d65556cac22"
#             instance_type = "r5.xlarge"
#             Name = "SISENSE"
#             volume_size = "500"
#             volume_type = "gp2"
#             key_name = "rdp-key"
#         }
#     }
# }
