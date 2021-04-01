resource "aws_alb_target_group" "target_group" {
  name = replace(
    replace("${var.env}-${var.component_name}", "/(.{0,32}).*/", "$1"),
    "/^-+|-+$/",
    "",
  )

  # port will be set dynamically, but for some reason AWS requires a value
  port                 = var.port
  target_type          = var.target_type
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    matcher             = var.health_check_matcher
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = var.cookie_duration
    enabled         = var.stickiness_enabled
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    component = var.component_name
    env       = var.env
    service   = "${var.env}-${var.component_name}"
  }
}

resource "aws_alb_listener_rule" "rule" {
  count = length(var.path_conditions)

  listener_arn = var.alb_listener_arn
  priority     = var.starting_priority + count.index

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }

  # Always pass host-based routing condition, with '*.*' being default
  #
  # NOTE: You can have multiple paths but only a single hostname
  condition {
    host_header {
      values = [var.host_condition]
    }
  }

  condition {
    path_pattern {
      # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
      # force an interpolation expression to be interpreted as a list by wrapping it
      # in an extra set of list brackets. That form was supported for compatibility in
      # v0.11, but is no longer supported in Terraform v0.12.
      #
      # If the expression in the following list itself returns a list, remove the
      # brackets to avoid interpretation as a list of lists. If the expression
      # returns a single list item then leave it as-is and remove this TODO comment.
      values = [element(var.path_conditions, count.index)]
    }
  }
}

