# ==============================
# DocumentDB Subnet Group
# ==============================
resource "aws_docdb_subnet_group" "docdb_subnets" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.subnet_ids
  description = "Subnet group for DocumentDB cluster"
}

# ==============================
# DocumentDB Security Group
# ==============================
resource "aws_security_group" "docdb_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for DocumentDB cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = var.ecs_sg_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================
# DocumentDB Cluster
# ==============================
resource "aws_docdb_cluster" "this" {
  cluster_identifier      = var.cluster_name
  engine                  = "docdb"
  master_username         = var.username
  master_password         = var.password
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnets.name
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  skip_final_snapshot     = true
  apply_immediately       = true
}

# ==============================
# DocumentDB Cluster Instances
# ==============================
resource "aws_docdb_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.cluster_name}-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
  engine             = "docdb"
  apply_immediately  = true
}
