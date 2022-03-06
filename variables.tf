variable "region" {
  type        = string
  description = "the aws region to deploy to"
}

variable "region_short_name" {
  type        = string
  description = "short form of the region, eg use1 for us-east-1"
}

variable "name" {
  type        = string
  description = "the name of the product we are building - smonik"
}

variable "glue_crawler_rds_name" {
  type        = string
  description = "name of the rds glue crawler"
}

variable "glue_crawler_s3_name" {
  type        = string
  description = "name of the s3 glue crawler"
}

variable "aurora_database_name" {
  type        = string
  description = "the name of the aurora pgsql database"
}

variable "aurora_admin_username" {
  type        = string
  description = "the name of the aurora pgsql admin user"
}

variable "environment" {
  type        = string
  description = "the environment to deploy to - dev|qa|uat|prod"
}

variable "vpc_cidr" {
  type        = string
  description = "the cidr of the smonik vpc"
}

variable "data_subnet_cidr_az1a" {
  type        = string
  description = "the cidr of the smonik data subnet"
}

variable "data_subnet_cidr_az1b" {
  type        = string
  description = "the cidr of the smonik data subnet"
}

variable "web_subnet_cidr" {
  type        = string
  description = "the cidr of the smonik web subnet"
}

variable "ec2_key_pair_name" {
  type        = string
  description = "ec2 key to get instance password"
}

variable "allowed_rdp_ips" {
  type        = string
  description = "external IP allowed to RDP in"
}

variable "instance_type" {
  type = string
  description = "EC2 instance type"
}

variable "ami_id" {
  type = string
  description = "AMI ID for ec2"
}