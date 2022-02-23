## Locals
locals {
  account_id                       = data.aws_caller_identity.current.account_id
  # db_creds                         = jsondecode(data.aws_secretsmanager_secret_version.data.secret_string)
}
  # aurora_secretmanager_secret_name = "${var.environment}/smonik-${var.aurora_database_name}"

  # Get bucket ids from the TF that creates the buckets
  # glue_crawler_bucket_name = "aws-{var.environment}-${var.region_short_name}-${local.account_id}-smonik-metadatamappingfiles-0"
  # glue_job_bucket_name = "aws-${var.environment}-${var.region_short_name}-${local.account_id}-glue-scripts-${var.region}/admin/"
  # glue_job_temp_bucket_name = "aws-${var.environment}-glue-scripts-${var.region}/temp_job_files/"




# Account ID
data "aws_caller_identity" "current" {}

## Glue Databases
resource "aws_glue_catalog_database" "srcmetadata" {
  description = "This where schema will be created and stored for source files in S3 bucket sent by SMONIK"
  name        = "srcmetadata"
}

resource "aws_glue_catalog_database" "destmetadata" {
  description = "This where schema will be created and stored for destination tables in AuroraDb"
  name        = "destmetadata"
}

## Glue Crawlers
resource "aws_glue_crawler" "s3" {
  classifiers   = []
  database_name = "srcmetadata"
  name          = "FromS3Source"
  # role          = "aws-0-use1-0-iam-smonik-gluerole-0"
  role         = aws_iam_role.glue_crawler.arn
  table_prefix = "smonik_S3_"
  tags         = {}

  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  s3_target {
    exclusions = []
    # path       = "s3://aws-0-use1-0-s3-smonik-metadatamappingfiles-0/Position"
    path = "s3://${aws_s3_bucket.glue_crawler.id}/Position"
  }
  s3_target {
    exclusions = []
    # path       = "s3://aws-0-use1-0-s3-smonik-metadatamappingfiles-0/Transaction"
    path = "s3://${aws_s3_bucket.glue_crawler.id}/Transaction"
  }

  schema_change_policy {
    delete_behavior = "DEPRECATE_IN_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

resource "aws_glue_crawler" "rds" {
  classifiers   = []
  database_name = "destmetadata"
  name          = "ToAuroraDbDestStag"
  # role          = "aws-0-use1-0-iam-smonik-gluerole-0"
  role         = aws_iam_role.glue_crawler.arn
  table_prefix = "RDS_Aurora_"
  tags         = {}

  jdbc_target {
    #connection_name = "AuroraPostgresRDS"
    connection_name = aws_glue_connection.AuroraPostgresRDS.name
    exclusions      = []
    path            = "custodianmdr/dbo/stagposition"
  }
  jdbc_target {
    #connection_name = "AuroraPostgresRDS"
    connection_name = aws_glue_connection.AuroraPostgresRDS.name
    exclusions      = []
    path            = "custodianmdr/dbo/stagtransaction"
  }

  lineage_configuration {
    crawler_lineage_settings = "DISABLE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  schema_change_policy {
    delete_behavior = "DEPRECATE_IN_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

## Glue Jobs
resource "aws_glue_job" "S3_To_Aurora_Stag_Position" {
  # connections = [
  #   "AuroraPostgresRDS",
  # ]

  connections = [
    aws_glue_connection.AuroraPostgresRDS.id
  ]

  default_arguments = {
    # "--TempDir"                   = local.glue_job_temp_bucket_name
    "--TempDir"                   = "s3://${aws_s3_bucket.glue_jobs.id}/temp_position"
    "--additional-python-modules" = "pg8000"
    "--job-bookmark-option"       = "job-bookmark-enable"
    "--job-language"              = "python"
  }
  glue_version              = "2.0"
  max_retries               = 0
  name                      = "S3_To_Aurora_Stag_Position"
  non_overridable_arguments = {}
  # role_arn                  = "arn:aws:iam::086767241423:role/aws-0-use1-0-iam-smonik-gluerole-0"
  role_arn = aws_iam_role.glue_crawler.arn
  tags     = {}
  tags_all = {}
  timeout  = 2880
  #worker_type               = "G.1X"

  command {
    name           = "glueetl"
    python_version = "3"
    # script_location = "s3://aws-glue-scripts-086767241423-us-east-1/admin/S3_To_Aurora_Stag_Position"
    script_location = "s3://${aws_s3_bucket.glue_jobs.id}/admin/S3_To_Aurora_Stag_Position"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_glue_job" "S3_To_Aurora_Stag_Transaction" {
  # connections = [
  #   "AuroraPostgresRDS",
  # ]

  connections = [
    aws_glue_connection.AuroraPostgresRDS.id
  ]

  default_arguments = {
    # "--TempDir"                   = "s3://aws-glue-temporary-086767241423-us-east-1/admin"
    "--TempDir"                   = "${aws_s3_bucket.glue_jobs.id}/temp_transaction"
    "--additional-python-modules" = "pg8000"
    "--job-bookmark-option"       = "job-bookmark-enable"
    "--job-language"              = "python"
  }
  glue_version              = "2.0"
  max_retries               = 0
  name                      = "S3_To_Aurora_Stag_Transaction"
  non_overridable_arguments = {}
  # role_arn                  = "arn:aws:iam::086767241423:role/aws-0-use1-0-iam-smonik-gluerole-0"
  role_arn    = aws_iam_role.glue_crawler.arn
  tags        = {}
  timeout     = 2880
  # worker_type = "G.1X"

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.glue_jobs.id}/admin/S3_To_Aurora_Stag_Transaction"
  }

  execution_property {
    max_concurrent_runs = 1
  }
}

## Glue RDS Connection
resource "aws_glue_connection" "AuroraPostgresRDS" {
  connection_properties = {
    "JDBC_CONNECTION_URL" : "jdbc:postgresql://${aws_rds_cluster.this.endpoint}:5432/custodianmdr"
    "JDBC_ENFORCE_SSL" : "false"
    "PASSWORD" : "${random_password.this.result}"
    "USERNAME" : "${var.aurora_admin_username}"
  }

  connection_type = "JDBC"
  match_criteria  = []
  name            = "AuroraPostgresRDS"

  physical_connection_requirements {
    availability_zone = "${var.region}a"
    #subnet_id         = "subnet-0f965cdb781c9cfb2"
    # subnet_id = "vpc-056c362468282c734"
    subnet_id = aws_subnet.az1a.id
    security_group_id_list = [
      # "sg-0ce9320de0a8c33be",
      aws_security_group.aurora.id,
    ]
  }
}


