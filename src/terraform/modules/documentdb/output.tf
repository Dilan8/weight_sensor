output "endpoint" {
  description = "DocumentDB cluster endpoint"
  value       = aws_docdb_cluster.this.endpoint
}

output "port" {
  description = "DocumentDB port"
  value       = aws_docdb_cluster.this.port
}

output "docdb_sg_id" {
  description = "Security group ID for DocumentDB"
  value       = aws_security_group.docdb_sg.id
}
