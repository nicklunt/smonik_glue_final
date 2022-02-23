# db security group
resource "aws_security_group" "aurora" {
  # arn         = "arn:aws:ec2:us-east-1:086767241423:security-group/sg-0ce9320de0a8c33be"
  description = "Restricts access to and from Database Servers"
  name        = "aws-${var.environment}-${var.region_short_name}-0-vpc-smonik-rdsdatasg-0"
  # vpc_id = var.aurora_vpc_id
  vpc_id = aws_vpc.this.id

  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = "All Traffic"
      from_port   = 0
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "-1"
      security_groups = []
      self            = false
      to_port         = 0
    },
  ]
  # id = "sg-0ce9320de0a8c33be"
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "RDS Aurora Postgre Server Traffic"
      from_port        = 5432
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 5432
    },
    {
      cidr_blocks      = []
      description      = "All Traffic within same Security Group"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
  ]

  # owner_id    = "086767241423"
  tags = {
    "Name" = "aws-${var.environment}-${var.region_short_name}-vpc-smonik-rdsdatasg-0"
  }


}

## Secrets Manager
resource "random_password" "this" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  description             = "Access to smonik-custodianmdr database"
  name                    = "smonik-custodianmdr"
  recovery_window_in_days = 0

  depends_on = [
    aws_rds_cluster.this
  ]
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = <<EOF
  {
    "username" : "${var.aurora_admin_username}",
    "password" : "${random_password.this.result}",
    "engine" : "${aws_rds_cluster.this.engine}",
    "host" : "${aws_rds_cluster.this.endpoint}",
    "port" : "${aws_rds_cluster.this.port}",
    "dbClusterIdentifier" : "${aws_rds_cluster.this.cluster_identifier}",
    "dbname" : "${aws_rds_cluster.this.database_name}",
    "conntimeout" : "190",
    "cmdtimeout" : "30000",
    "poolling" : "true",
    "connlifetm" : "0"
  }
EOF

depends_on = [
  aws_rds_cluster.this
]
}

/*
    "engine" : "${aws_rds_cluster.this.engine}",
    "host" : "${aws_rds_cluster.this.endpoint}",
    "port" : "${aws_rds_cluster.this.port}",
    "dbClusterIdentifier" : "${aws_rds_cluster.this.cluster_identifier}",
    "dbname" : "${aws_rds_cluster.this.database_name}",
    "conntimeout" : "190",
    "cmdtimeout" : "30000",
    "poolling" : "true",
    "connlifetm" : "0"
    */

data "aws_secretsmanager_secret" "data" {
  arn = aws_secretsmanager_secret.this.arn

  depends_on = [
    aws_rds_cluster.this
  ]
}

data "aws_secretsmanager_secret_version" "data" {
  # secret_id = data.aws_secretsmanager_secret.data.id
  secret_id = data.aws_secretsmanager_secret.data.arn

  depends_on = [
    aws_rds_cluster.this
  ]
}

resource "aws_iam_role" "glue_crawler" {
  # arn                   = "arn:aws:iam::086767241423:role/aws-0-use1-0-iam-smonik-gluerole-0"
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "glue.amazonaws.com"
          }
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
  # create_date           = "2021-10-06T10:47:57Z"
  # force_detach_policies = false
  # id                    = "aws-0-use1-0-iam-smonik-gluerole-0"
  managed_policy_arns = [
    # "arn:aws:iam::086767241423:policy/aws-0-use1-0-iam-smonik-glueetlpolicy-0",
    aws_iam_policy.glue_etl.arn,
    "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
  ]
  # max_session_duration  = 3600
  name = "aws-0-${var.region_short_name}-0-iam-smonik-gluerole-0"
  # path                  = "/"
  # unique_id             = "AROARIM53BDH2WCN3HLDX"

  inline_policy {}
}

resource "aws_iam_policy" "glue_etl" {
  # arn       = "arn:aws:iam::086767241423:policy/aws-0-use1-0-iam-smonik-glueetlpolicy-0"
  # id        = "arn:aws:iam::086767241423:policy/aws-0-use1-0-iam-smonik-glueetlpolicy-0"
  name = "aws-${var.environment}-0-${var.region_short_name}-0-iam-smonik-glueetlpolicy-0"
  path = "/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:Get*",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:List*",
            "s3:DeleteObject",
            "s3:DeleteObjectVersion",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.glue_crawler.arn}",
            "${aws_s3_bucket.glue_crawler.arn}/*",
            "${aws_s3_bucket.glue_jobs.arn}",
            "${aws_s3_bucket.glue_jobs.arn}/*",
          ]
        },
        {
          Action = [
            "s3:Get*",
            "s3:List*",
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:s3:::aws-0-use1-0-s3-smonik-metadatamappingfiles-0",
            "arn:aws:s3:::aws-0-use1-0-s3-smonik-metadatamappingfiles-0/*",
          ]
        },
        {
          Action = [
            "secretsmanager:GetSecretValue",
          ]
          Effect   = "Allow"
          Resource = "${aws_secretsmanager_secret.this.arn}"
        },
      ]
      Version = "2012-10-17"
    }
  )
  # policy_id = "ANPARIM53BDH2CATQZ2UP"
}
