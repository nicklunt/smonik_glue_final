# data "aws_availability_zones" "available" {}

resource "aws_db_subnet_group" "this" {
  name       = "nl-${var.environment}-smonik-aurora-db-subnets"
  subnet_ids = [aws_subnet.az1a.id, aws_subnet.az1b.id]
  # subnet_ids = [aws_subnet.az1a.id]
}

# resource "aws_rds_cluster" "this" {
#   availability_zones = [
#     "us-east-1a",
#     "us-east-1b",
#     "us-east-1c",
#   ]

resource "aws_rds_cluster" "this" {

  # availability_zones                  = ["us-east-1a", "us-east-1b"]
  # availability_zones                  = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  # availability_zones                  = ["eu-west-2a", "eu-west-2b"]
  # availability_zones = [aws_subnet.az1a.availability_zone, aws_subnet.az1b.availability_zone]
  backup_retention_period             = 1
  cluster_identifier                  = "nl-${var.environment}-0-${var.region_short_name}-0-rds-smonik-custodianmdr-0"
  cluster_members                     = []
  copy_tags_to_snapshot               = false
  database_name                       = "custodianmdr"
  db_cluster_parameter_group_name     = "default.aurora-postgresql10"
  db_subnet_group_name                = aws_db_subnet_group.this.name
  deletion_protection                 = false
  enable_http_endpoint                = true
  enabled_cloudwatch_logs_exports     = []
  engine                              = "aurora-postgresql"
  engine_mode                         = "serverless"
  engine_version                      = "10.14"
  iam_database_authentication_enabled = false
  iam_roles                           = []
  # kms_key_id                   = "arn:aws:kms:us-east-1:086767241423:key/af40c001-18a3-43e5-95dc-aaf062fac798"
  # master_username              = local.db_creds.username
  # master_password              = local.db_creds.password
  master_username              = var.aurora_admin_username
  master_password              = random_password.this.result
  port                         = 5432
  preferred_backup_window      = "03:00-03:30"
  preferred_maintenance_window = "wed:08:21-wed:08:51"
  skip_final_snapshot          = true
  storage_encrypted            = true

  tags = {
    "Name" = "nl-${var.environment}-0-use1-0-${var.region_short_name}-rds-smonik-custodianmdr-0"
  }

  vpc_security_group_ids = [
    aws_security_group.aurora.id
  ]

  scaling_configuration {
    auto_pause               = true
    max_capacity             = 8
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "RollbackCapacityChange"
  }
}