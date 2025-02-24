resource "aws_instance" "app1" {
  ami                    = "ami-0ddfba243cbee3768"  # Replace with your actual AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet_az1.id  # Reference correct subnet
  key_name               = "test"
  security_groups        = [aws_security_group.allow_ec2.id]  # Correctly reference the security group
  associate_public_ip_address = true
  user_data              = <<-EOF
                            #!/bin/bash
                            sudo yum update -y
                            sudo yum install -y httpd
                            sudo systemctl start httpd
                            sudo systemctl enable httpd
                            sudo echo "Hello from EC2 Instance 1" > /var/www/html/index.html
                            EOF
  depends_on = [
    aws_security_group.allow_ec2  # Ensure security group is created before EC2 instance
  ]
}

resource "aws_instance" "app2" {
  ami                    = "ami-03b8adbf322415fd0"  # Replace with your actual AMI ID
  instance_type          = "t2.micro"
  key_name               = "test"
  subnet_id              = aws_subnet.subnet_az2.id  # Reference correct subnet
  security_groups        = [aws_security_group.allow_ec2.id]  # Correctly reference the security group
  associate_public_ip_address = true
  user_data              = <<-EOF
                            #!/bin/bash
                            sudo yum update -y
                            sudo yum install -y httpd
                            sudo systemctl start httpd
                            sudo systemctl enable httpd
                            sudo echo "Hello from EC2 Instance 2" > /var/www/html/index.html
                            EOF
  depends_on = [
    aws_security_group.allow_ec2  # Ensure security group is created before EC2 instance
  ]
}


resource "aws_lb_target_group_attachment" "app1_target_attachment" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.app1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "app2_target_attachment" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.app2.id
  port             = 80
}
