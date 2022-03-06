# env variables
environment = "qa"

region            = "eu-west-2"
region_short_name = "euw2"
name              = "smonik"

# vpc and subnets
vpc_cidr              = "10.136.16.0/20"
data_subnet_cidr_az1a = "10.136.20.0/23"
data_subnet_cidr_az1b = "10.136.22.0/23"
web_subnet_cidr       = "10.136.28.0/23"

# glue variables
glue_crawler_rds_name = "ToAuroraDbDestStag"
glue_crawler_s3_name  = "FromS3Source"

# aurora rds variables
aurora_database_name  = "custodianmdr"
aurora_admin_username = "sa"

# ec2 variables
ec2_key_pair_name = "smonik-ec2-key_pair"
allowed_rdp_ips   = "86.23.82.87/32"
instance_type = "t3.medium"
ami_id = "ami-03778fe8eef3985a7"