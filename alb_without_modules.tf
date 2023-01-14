
resource "aws_lb" "this" {
    load_balancer_type         = "application"
    name = "${var.component}-web-alb"
    security_groups            = [aws_security_group.alb_sg.id]
    subnets                    = aws_subnet.public_subnet.*.id
 
  tags = { Name = "${var.component}-web-alb" }
}


resource "aws_lb_target_group" "app1" {
    deregistration_delay               = "10"
    name_prefix                        = "app1-"
    port                               = 80
    protocol                           = "HTTP"
    protocol_version                   = "HTTP1"
    proxy_protocol_v2                  = false
    slow_start                         = 0
    target_type                        = "instance"
    vpc_id                             = local.vpc_id

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        matcher             = "200-399"
        path                = "/app1/index.html"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        unhealthy_threshold = 3
    }
}

resource "aws_lb_target_group" "app2" {

    connection_termination             = false
    deregistration_delay               = "10"
  
    lambda_multi_value_headers_enabled = false
    name_prefix                        = "app2-"
    port                               = 80
    protocol                           = "HTTP"
    protocol_version                   = "HTTP1"
    proxy_protocol_v2                  = false
    slow_start                         = 0

    target_type                        = "instance"
    vpc_id                             = local.vpc_id

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        matcher             = "200-399"
        path                = "/app2/index.html"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        unhealthy_threshold = 3
    }
}

resource "aws_lb_target_group" "registration_app" {
    connection_termination             = false
    deregistration_delay               = "10"

    lambda_multi_value_headers_enabled = false
    name_prefix                        = "regis-"
    port                               = 8080
    protocol                           = "HTTP"
    protocol_version                   = "HTTP1"
    proxy_protocol_v2                  = false
    slow_start                         = 0
  
    target_type                        = "instance"
    vpc_id                             = local.vpc_id

    health_check {
        enabled             = true
        healthy_threshold   = 3
        interval            = 30
        matcher             = "200-399"
        path                = "/login"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        unhealthy_threshold = 3
    }
}


resource "aws_lb_listener" "frontend_http_tcp" {
 
    load_balancer_arn = aws_lb.this.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type  = "redirect"

        redirect {
            host        = "#{host}"
            path        = "/#{path}"
            port        = "443"
            protocol    = "HTTPS"
            query       = "#{query}"
            status_code = "HTTP_301"
        }
    }
}

# module.alb.aws_lb_listener.frontend_https[0] will be created
resource "aws_lb_listener" "frontend_https" {
    certificate_arn   = aws_acm_certificate.this.arn

    load_balancer_arn = aws_lb.this.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
   
    default_action {
        type  = "fixed-response"

        fixed_response {
            content_type = "text/plain"
            message_body = "Fixed Static message - for Root Context"
            status_code  = "200"
        }
    }
}


# module.alb.aws_lb_listener_rule.https_listener_rule[0] will be created
resource "aws_lb_listener_rule" "https_listener_rule_app1" {
    listener_arn = aws_lb_listener.frontend_https.arn
    priority     = 1
    tags_all     = {
        "ChangeCode" = "100283836HDHDF"
        "component"  = "3-tier-architecture"
    }
    action {
        target_group_arn = aws_lb_target_group.app1.arn
        type             = "forward"
    }
    condition {
        path_pattern {
            values = [
                "/app1*",
            ]
        }
    }
}

resource "aws_lb_listener_rule" "https_listener_rule_app2" {
    listener_arn = aws_lb_listener.frontend_https.arn
    priority     = 2
  

    action {

        target_group_arn = aws_lb_target_group.app2.arn
        type             = "forward"
    }

    condition {

        path_pattern {
            values = [
                "/app2*",
            ]
        }
    }
}

resource "aws_lb_listener_rule" "https_listener_rule_registration" {
    listener_arn = aws_lb_listener.frontend_https.arn
    priority     = 3
    action {
        target_group_arn = aws_lb_target_group.registration_app.arn
        type             = "forward"
    }

    condition {

        path_pattern {
            values = [
                "/*",
            ]
        }
    }
}

resource "aws_lb_target_group_attachment" "app1" {
    port             = 80
    target_group_arn = aws_lb_target_group.app1.arn
    target_id        = aws_instance.app1.id
}

resource "aws_lb_target_group_attachment" "app2" {
    port             = 80
    target_group_arn = aws_lb_target_group.app2.arn
    target_id        = aws_instance.app2.id
}

resource "aws_lb_target_group_attachment" "this" {
    count = length(aws_instance.registration_app)
    port             = 8080
    target_group_arn = aws_lb_target_group.registration_app.arn
    target_id        = aws_instance.registration_app[count.index].id
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    =  var.dns_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}


resource "aws_acm_certificate" "this" {
    domain_name               = data.aws_route53_zone.this.name
    subject_alternative_names =  var.subject_alternative_names
    validation_method         = "DNS"

    options {
        certificate_transparency_logging_preference = "ENABLED"
    }
}

resource "aws_acm_certificate_validation" "this" {
    certificate_arn         = aws_acm_certificate.this.arn
    validation_record_fqdns = [for record in aws_route53_record.example : record.fqdn]
}

