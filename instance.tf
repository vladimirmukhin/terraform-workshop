data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10*"]
  }

  owners = ["137112412989"]
}

resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id
  iam_instance_profile        = "${var.environment_code}-main"

  user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd git
    git clone https://github.com/gabrielecirulli/2048.git
    cp -R 2048/* /var/www/html
    systemctl start httpd && systemctl enable httpd
  EOF

  tags = {
    Name = "${var.environment_code}-Public"
  }
}

resource "aws_security_group" "public" {
  name        = "${var.environment_code}-Public"
  description = "Allows SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["98.180.121.31/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_code}-Public"
  }
}

resource "aws_iam_role" "main" {
  name = "${var.environment_code}-main"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Sid    = ""
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
    }
  )

  inline_policy {
    name = "s3FullAccess"

    policy = jsonencode(
      {
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["s3:*"]
            Effect   = "Allow"
            Resource = "*"
          },
        ]
      }
    )
  }
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.environment_code}-main"
  role = aws_iam_role.main.name
}

resource "aws_iam_policy_attachment" "ssm" {
  name       = "${var.environment_code}-ssm"
  roles      = [aws_iam_role.main.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
