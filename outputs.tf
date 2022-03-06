output "username" {
  value     = var.aurora_admin_username
  sensitive = true
}

output "password" {
  value     = random_password.this.result
  sensitive = true
}

output "rds_arn" {
  description = "rds arn"
  value       = aws_rds_cluster.this.arn
}

output "rds_id" {
  description = "rds id"
  value       = aws_rds_cluster.this.id
}

output "rds_cluster_identifier" {
  description = "rds cluster identifier"
  value       = aws_rds_cluster.this.cluster_identifier
}

output "rds_azs" {
  description = "rds availability zones"
  value       = aws_rds_cluster.this.availability_zones
}

output "rds_endpoint" {
  description = "rds endpoint"
  value       = aws_rds_cluster.this.endpoint
}

output "rds_reader_endpoint" {
  description = "rds reader endpoint"
  value       = aws_rds_cluster.this.reader_endpoint
}

output "rds_db_name" {
  description = "rds database name"
  value       = aws_rds_cluster.this.database_name
}

output "private_key_pem" {
    value = tls_private_key.this.private_key_pem
    sensitive = true
}

output "public_key_pem" {
  value = tls_private_key.this.public_key_pem
  sensitive = true
}

output "instance_public_ip_address" {
  value = aws_instance.this[*].public_ip
}
