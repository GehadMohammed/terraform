resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [ module.network.private-subnet-01-id , module.network.private-subnet-02-id ]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-security-group"
  description = "allow inbound access to the database"
  vpc_id      = module.network.vpc-01-id

  ingress {
    // protocol    = "tcp"
    // from_port   = 0
    // to_port     = 3306
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ var.vpc-01-cidr-block ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ var.vpc-01-cidr-block ]
  }
}

resource "aws_db_instance" "rds-gehad" {
  allocated_storage    = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  identifier           = "mydb"
  db_name              = "mydb"
  username             = "root"
  password             = "12345678"
  parameter_group_name = aws_db_parameter_group.default.id
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [ aws_security_group.rds-sg.id ]
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az             = false
}