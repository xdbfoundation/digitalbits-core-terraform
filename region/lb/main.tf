# --- region/lb/main.tf ---
resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_lb_target_group" "livenet_tg" {
  name     = "livenet-lb-tg"
  port     = 11625
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group_attachment" "node" {
  count            = local.instance_count
  target_group_arn = aws_lb_target_group.livenet_tg.arn
  target_id        = var.instances[count.index].id
  port             = 11625
}


resource "aws_lb" "livenet_lb" {
  name               = "livenet-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_sg]
  subnets            = var.public_subnets
}

resource "aws_route53_record" "node" {
  zone_id = var.zone_id
  name    = var.instances[0].tags.Name
  type    = "A"
  alias {
    name                   = aws_lb.livenet_lb.dns_name
    zone_id                = aws_lb.livenet_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "node" {
  load_balancer_arn = aws_lb.livenet_lb.arn
  port              = "11625"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.livenet_tg.arn
  }
}