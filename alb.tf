
# create Application load_balancer
resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Allow http and https traffic"
  vpc_id      = local.vpc_id

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}


resource "aws_security_group_rule" "ingress-http-inboudrule" {
  for_each = var.http_https_port

  security_group_id        = aws_security_group.alb-sg.id
  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.from_port
  protocol                 = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "app_load_balancer" {
  name                       = "alb-app"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-sg.id]
  subnets                    = [aws_subnet.cloudwave-public.*.id]
  enable_deletion_protection = false
}

# create Target groups

resource "aws_lb_target_group" "alb_target_group" {
  name     = "app-${substr(uuid(), 0, 5)}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id

  health_check {
    enabled           = true
    interval          = 300
    path              = "/" 
    port              = "traffic-port"
    timeout           = 60
    matcher           = 200
    healthy_threshold = 5
  }

  lifecycle {
    ignore_changes = [name]
    create_before_destroy = true
  }
}

# create aws_lb_listener on port 80 with redirect Action
resource "aws_lb_listener" "alb_http_slistener" {
  load_balancer_arn = aws_lb.app_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
}

#Auto-Scaling
resource "aws_launch_configuration" "cloudwave-as" {
  image_id = var.ami_id_for_windows
  instance_type = var.instance_type
  #security_groups = ["sg-01234567890abcdef0"]
  
}

resource "aws_autoscaling_group" "cloudwave-asg" {
  launch_configuration = "${aws_launch_configuration.cloudwave-as.name}"
  min_size = 1
  max_size = 5
  desired_capacity = 2
  availability_zones = ["us-east-1a", "us-east-1b"]
}
