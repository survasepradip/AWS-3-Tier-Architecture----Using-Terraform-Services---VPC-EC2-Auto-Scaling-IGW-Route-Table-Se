
resource "aws_iam_role" "ssm_fleet_instance" {
  name = "${var.component}-ssm-234-role"
  assume_role_policy = jsonencode({
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
  })
  tags = {
    Name = "${var.component}-ssm-234-role"
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.component}-ssm-fleet23d-instance-profile"
  role = aws_iam_role.ssm_fleet_instance.name
}

resource "aws_iam_policy" "policy" {
  name        = "${var.component}-ssm-ew3-policy"
  description = "allow ecs instance to be managed by ssm"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
         "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }   
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ssm_fleet_instance.name
  policy_arn = aws_iam_policy.policy.arn
}