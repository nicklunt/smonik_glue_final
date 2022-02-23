# # env variables
environment = "qa"

# region            = "us-east-1"
region            = "eu-west-2"
region_short_name = "euw2"
name              = "smonik"

# vpc and subnets
vpc_cidr                   = "10.136.16.0/21"
data_subnet_cidr_az1a      = "10.136.20.0/23"
data_subnet_cidr_az1a_name = "nl-qa-use1-X-az1-sub-smonik-data-z"
data_subnet_cidr_az1b      = "10.136.22.0/23"
data_subnet_cidr_az1b_name = "nl-qa-use1-X-az2-sub-smonik-data-z"

# glue variables
glue_crawler_rds_name = "ToAuroraDbDestStag"
glue_crawler_s3_name  = "FromS3Source"

# buckets
#glue_crawler_bucket_name = "aws-qa-use1-0-s3-smonik-metadatamappingfiles-0"
#glue_job_bucket_name     = "aws-qa-glue-scripts-us-east-1/admin/"
# glue_job_temp_bucket_name = "aws-qa-glue-scripts-us-east-1/temp_job_files/"

# aurora rds variables
aurora_database_name = "custodianmdr"
# aurora_secretmanager_secret_name = "qa/smonik-custodianmdr"
# aurora_instance_class = "db.t4g.medium"
aurora_admin_username = "sa"

# aurora vpc variables
##aurora_vpc_id     = "vpc-056c362468282c734"
# aurora_vpc_id = "vpc-056c362468282c734"
##aurora_subnet_ids = ["subnet-0374fbc8b557c17ff", "subnet-06b935055a81fb2e8"]


# aurora_subnet_ids = ["subnet-002c559cff62bffa7", "subnet-0043f6caf568c6400"]
# aurora_subnet_ids = [ "10.0.1.0/24",  "10.0.2.0/24"]
