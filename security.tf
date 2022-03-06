# db security group
resource "aws_security_group" "aurora" {
  # arn         = "arn:aws:ec2:us-east-1:086767241423:security-group/sg-0ce9320de0a8c33be"
  description = "Restricts access to and from Database Servers"
  name        = "aws-${var.environment}-${var.region_short_name}-0-vpc-smonik-rdsdatasg-0"
  # vpc_id = var.aurora_vpc_id
  vpc_id = aws_vpc.this.id

  lifecycle {
    create_before_destroy = true
  }

  egress = [
    {
      cidr_blocks = ["0.0.0.0/0", ]
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
    {
      cidr_blocks = [aws_subnet.az1a.cidr_block, aws_subnet.az1b.cidr_block, ]
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

  tags = {
    "Name" = "aws-${var.environment}-${var.region_short_name}-vpc-smonik-rdsdatasg-0"
  }
}

# EC2 SG 
resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.this.id
  name   = "nl-ec2-windows-sg"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = [var.allowed_rdp_ips]
  }

  egress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = [var.allowed_rdp_ips]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    # cidr_blocks = join(", ", [for block in aws_db_subnet_group.this.subnet_ids : format("%q", block)])
    cidr_blocks = [aws_subnet.az1a.cidr_block, aws_subnet.az1b.cidr_block]
  }

  tags = {
    Name = "nl-ec2-smonik-windows-sg"
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

# data "aws_secretsmanager_secret" "data" {
#   arn = aws_secretsmanager_secret.this.arn

#   depends_on = [
#     aws_rds_cluster.this
#   ]
# }

# data "aws_secretsmanager_secret_version" "data" {
#   secret_id = data.aws_secretsmanager_secret.data.arn

#   depends_on = [
#     aws_rds_cluster.this
#   ]
# }

resource "aws_iam_role" "glue_crawler" {
  name = "aws-0-${var.region_short_name}-0-iam-smonik-gluerole-0"

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

  managed_policy_arns = [
    aws_iam_policy.glue_etl.arn,
    "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
  ]
}

resource "aws_iam_policy" "glue_etl" {
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
}
