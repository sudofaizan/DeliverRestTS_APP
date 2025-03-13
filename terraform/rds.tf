provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_db_instance" "postgres" {
  identifier             = "mydatabase-instance"
  engine                 = "postgres"
  engine_version         = "17.2"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "mydatabase"
  username               = "myuser"
  password               = "##Linux##1"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_rds.id]
}

resource "aws_security_group" "allow_rds" {
  name = "allow_rds"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Make sure to restrict this for security
  }
}

resource "null_resource" "initialize_db" {
  provisioner "local-exec" {
    command = <<EOT
      PGPASSWORD=##Linux##1 psql -h ${aws_db_instance.postgres.address} -U admin -d mydatabase -c "
      CREATE TABLE IF NOT EXISTS tasks (
        id SERIAL PRIMARY KEY,
        description TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );"
    EOT
  }
}