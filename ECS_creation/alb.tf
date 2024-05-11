resource "aws_alb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.my_subnet[*].id

  enable_deletion_protection = false

  tags = {
    Name = "my_alb"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_alb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_alb.my_alb.dns_name
  description = "The DNS name of the ALB for accessing the load balancer"
}

resource "aws_lb_target_group" "my_tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id  # Assuming you have a VPC defined as `aws_vpc.my_vpc`
  target_type = "ip"  # Ensure target_type is set to 'ip'

  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "my-target-group"
  }
}


resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.my_vpc.id

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
}
