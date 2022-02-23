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

# # glue variables
# variable "glue_database_name" {
#   type        = string
#   description = "name of the glue database"
# }

variable "glue_crawler_rds_name" {
  type        = string
  description = "name of the rds glue crawler"
}

variable "glue_crawler_s3_name" {
  type        = string
  description = "name of the s3 glue crawler"
}

# variable "glue_crawler_pos_bucket_name" {
#   type        = string
#   description = "s3 bucket name to crawl"
# }

# variable "glue_crawler_tran_bucket_name" {
#   type        = string
#   description = "s3 bucket name to crawl"
# }

# variable "glue_job_bucket_name" {
#   type        = string
#   description = "location of the glue job scripts"
# }

# # aurora rds variables
# variable "aurora_secret_name" {
#   type        = string
#   description = "secret manager secret name for aurora pgsql authentication"
# }

variable "aurora_database_name" {
  type        = string
  description = "the name of the aurora pgsql database"
}

# variable "aurora_engine_version" {
#   type        = string
#   description = "the postgresql version"
# }

variable "aurora_admin_username" {
  type        = string
  description = "the name of the aurora pgsql admin user"
}

# variable "aurora_instance_class" {
#   type        = string
#   description = "the instance size for aurora"
# }

# aurora vpc variables
# variable "aurora_vpc_id" {
#   type        = string
#   description = "vpc for aurora"
# }

# variable "aurora_subnet_ids" {
#   type        = list(string)
#   description = "vpc subnets for aurora"
# }

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

variable "data_subnet_cidr_az1a_name" {
  type        = string
  description = "the name of the smonik data subnet az1"
}

variable "data_subnet_cidr_az1b" {
  type        = string
  description = "the cidr of the smonik data subnet"
}

variable "data_subnet_cidr_az1b_name" {
  type        = string
  description = "the name of the smonik data subnet az2"
}