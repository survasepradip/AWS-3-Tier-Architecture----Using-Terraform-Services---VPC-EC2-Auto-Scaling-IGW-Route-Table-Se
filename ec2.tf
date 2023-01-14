
################################################################################
# CREATING AN EC2 INSTANCE USING COUNT 
################################################################################

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


################################################################################
# CREATING AN EC2 INSTANCE USING COUNT 
################################################################################

resource "aws_instance" "app1" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet[0].id # us-east-1a
  vpc_security_group_ids = [aws_security_group.app_static_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data              = file("${path.module}/templates/app1.sh")
  tags = {
    Name = "app1"
  }
}
# ALLOW INGRESS ACCESS ON ALB SECURITY GROUP ON PORT 80 (security group referentail)

resource "aws_instance" "app2" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet[1].id # # us-east-1b
  vpc_security_group_ids = [aws_security_group.app_static_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data              = file("${path.module}/templates/app2.sh")

  tags = {
    Name = "app2"
  }
}

###############################################################################
# REGISTRATION APP CONTAINS APPLICATION ENV VARIABLES
###############################################################################
resource "aws_instance" "registration_app" {
  depends_on = [aws_db_instance.registration_app_db]
  count      = 2

  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.registration-app-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data = templatefile("${path.root}/templates/registration_app.tmpl",
    {
      hostname    = aws_db_instance.registration_app_db.address
      db_port     = var.port
      db_name     = var.db_name
      db_username = var.username
      db_password = random_password.password.result
    }
  )
  tags = {
    Name = "registration-app-${count.index + 1}"
  }
}


