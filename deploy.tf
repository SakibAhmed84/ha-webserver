# Setup AWS provider

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.20.0"
      }
    }
}

provider "aws" {
    region = "eu-west-2"
    access_key = var.access_key # defined in secrets.tf
    secret_key = var.secret_key # defined in secrets.tf
}

# Create a VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

# Create an Internet Garteway for the VPC
resource "aws_internet_gateway" "public_internet" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "public-internet"
  }
}

# Create a public subnet in AZ-A
resource "aws_subnet" "demo_subnet_a" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a" 
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-subnet-a"
  }
}

# Create a public subnet in AZ-B
resource "aws_subnet" "demo_subnet_b" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "demo-subnet-b"
  }
}

# Create a Route to the Internet for the VPC
resource "aws_route_table" "demo_vpc_public_route_table" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_internet.id
  }
}

# Associate public route to subnet AZ-A
resource "aws_route_table_association" "route_table_subnet_a" {
  subnet_id      = aws_subnet.demo_subnet_a.id
  route_table_id = aws_route_table.demo_vpc_public_route_table.id
}

# Associate public route to subnet AZ-A
resource "aws_route_table_association" "route_table_subnet_b" {
  subnet_id      = aws_subnet.demo_subnet_b.id
  route_table_id = aws_route_table.demo_vpc_public_route_table.id
}


# Create a security group for the EC2 instances
resource "aws_security_group" "ha_webserver_security_group" {
  vpc_id      = aws_vpc.demo_vpc.id
  name        = "ha_webserver_security_group"
  description = "Security group for web servers"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ha-webserver-security-group"
  }
}

# Create an IAM instance profile
resource "aws_iam_instance_profile" "ha_webserver_instance_profile" {
  name = "ha_webserver_instance_profile"

}

# Create a launch configuration for EC2 instances
resource "aws_launch_configuration" "ha_webserver_launch_configuration" {
  name_prefix          = "ha-webserver-"
  image_id             = "ami-0cf6f2b898ac0b337" # Amazon Linux 2 AMI
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.ha_webserver_security_group.id]
  iam_instance_profile = aws_iam_instance_profile.ha_webserver_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    chkconfig httpd on
    sleep 10
    systemctl start httpd
    echo "<p>Hello World!</p><p><a class='weatherwidget-io' href='https://forecast7.com/en/51d51n0d13/london/' data-label_1='LONDON' data-label_2='WEATHER' data-theme='original' >LONDON WEATHER</a><p/><script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='https://weatherwidget.io/js/widget.min.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','weatherwidget-io-js');</script>" > /var/www/html/index.html
    systemctl restart httpd
  EOF

}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "ha_webserver_asg" {
  launch_configuration = aws_launch_configuration.ha_webserver_launch_configuration.name
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.demo_subnet_a.id, aws_subnet.demo_subnet_b.id]
  target_group_arns    = ["${aws_lb_target_group.ha_webserver_target.arn}"]

  tag {
    key                 = "Name"
    value               = "ha-webserver"
    propagate_at_launch = true
  }
}

# Create a Load Balancer
resource "aws_lb" "ha_webserver_lb" {
  name               = "ha-webserver-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.demo_subnet_a.id,aws_subnet.demo_subnet_b.id,]

  enable_deletion_protection = false

  enable_http2 = true

  security_groups = [aws_security_group.ha_webserver_security_group.id]

  tags = {
    Name = "ha-webserver-lb"
  }
}

# Create a Load Balancer Target Group
resource "aws_lb_target_group" "ha_webserver_target" {
  name        = "ha-webserver-target"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.demo_vpc.id}"
  target_type = "instance"

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }
}

# Create a listener for the Load Balancer
resource "aws_lb_listener" "ha_webserver_listener" {
  load_balancer_arn = aws_lb.ha_webserver_lb.arn
  port             = 80
  protocol         = "HTTP"


  default_action {
  type                 = "forward"
  target_group_arn    = aws_lb_target_group.ha_webserver_target.arn
  }

  tags = {
    Name = "ha-webserver-listener"
  }
}

# Output the DNS name of the Load Balancer
output "load_balancer_dns" {
  value = aws_lb.ha_webserver_lb.dns_name
}

