resource "aws_s3_bucket" "glue_crawler" {
  bucket = "nl-xx${var.environment}-${var.region_short_name}-smonik-metadatamappingfiles-0"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "nl-xx${var.environment}-${var.region_short_name}-smonik-metadatamappingfiles-0"
    Product     = var.name
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "glue_jobs" {
  bucket = "nl-xx${var.environment}-${var.region_short_name}-glue-scripts-${var.region}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "nl-xx${var.environment}-${var.region_short_name}-glue-scripts-${var.region}"
    Product     = var.name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_object" "S3_To_Aurora_Stag_Position" {
  bucket = aws_s3_bucket.glue_jobs.id
  key    = "admin/S3_To_Aurora_Stag_Position"
  source = "scripts/Glue-S3_To_Aurora_Stag_Position.py"
}

resource "aws_s3_bucket_object" "S3_To_Aurora_Stag_Transaction" {
  bucket = aws_s3_bucket.glue_jobs.id
  key    = "admin/S3_To_Aurora_Stag_Transaction"
  source = "scripts/Glue-S3_To_Aurora_Stag_Transaction.py"
}

