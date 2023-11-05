variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-2"
}
variable "vpc_cidr_block" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}
variable "subnet_a_cidr_block" {
  description = "Subnet A CIDR Block"
  type        = string
  default     = "10.0.1.0/24"
}
variable "subnet_b_cidr_block" {
  description = "Subnet B CIDR Block"
  type        = string
  default     = "10.0.2.0/24"
}
variable "az-a" {
  description = "Availibility Zone A"
  type        = string
  default     = "eu-west-2a"
}
variable "az-b" {
  description = "Availibility Zone B"
  type        = string
  default     = "eu-west-2b"
}
variable "public_internet_cidr" {
  description = "Public Internet CIDR"
  type        = string
  default     = "0.0.0.0/0" 
}
variable "aws_ami" {
  description = "AWS AMI ID"
  type        = string
  default     = "ami-0cf6f2b898ac0b337" # AWS Linux 2023
}
variable "aws_instance_type" {
  description = "AWS EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}
