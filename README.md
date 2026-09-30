# terraform-acuris-frontend-service-routing

Description
-----------

Creates an ALB target group and path-based listener rules for a frontend service.

This module does **not** create DNS records. It only creates:

- `aws_alb_target_group.target_group` - the target group for the service
- `aws_alb_listener_rule.rule` - one listener rule per entry in `path_conditions`, forwarding to the target group

Requirements
------------

| Name | Version |
|------|---------|
| terraform | >= 0.12 |

Usage
-----

```hcl
module "frontend_routing" {
  source = "github.com/mergermarket/tf_frontend_service_routing"

  env               = "live"
  component_name    = "my-frontend"
  vpc_id            = "vpc-0123456789abcdef0"
  alb_listener_arn  = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:listener/app/my-alb/abc/def"
  path_conditions   = ["/home", "/home/*"]
  starting_priority = 100
  host_condition    = "www.example.com"
}
```

Inputs
------

### Required

| Name | Description | Type |
|------|-------------|------|
| `env` | Name of the environment, e.g. `live` or `live_eu-west-2`. See [How `env` is used](#how-env-is-used). | any |
| `component_name` | Name of the component. Used in the target group name and tags. | `string` |
| `vpc_id` | ID of the VPC to create the target group in. | `string` |
| `alb_listener_arn` | ARN of the listener to add the rule(s) to. | `string` |
| `path_conditions` | Path patterns to route, e.g. `["/home", "/home/*"]`. One listener rule is created per entry. | `list(string)` |
| `starting_priority` | Priority of the first rule. Subsequent rules use `starting_priority + index`. | any |

### Optional

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `host_condition` | Host-header condition for the rules. Only a single hostname is supported. | `string` | `"*.*"` |
| `port` | Target port. Overridden dynamically for ECS services, but AWS requires a value. | any | `"31337"` |
| `target_type` | Target type: `instance`, `ip` or `lambda`. | any | `"instance"` |
| `deregistration_delay` | Seconds to wait before a deregistering target moves from draining to unused (0-3600). | `string` | `"10"` |
| `health_check_path` | Destination for the health check request. | `string` | `"/internal/healthcheck"` |
| `health_check_interval` | Seconds between health checks of an individual target (5-300). | `string` | `"5"` |
| `health_check_timeout` | Seconds without a response before a health check fails. | `string` | `"4"` |
| `health_check_healthy_threshold` | Consecutive successes required to mark a target healthy. | `string` | `"2"` |
| `health_check_unhealthy_threshold` | Consecutive failures required to mark a target unhealthy. | `string` | `"2"` |
| `health_check_matcher` | HTTP codes counted as healthy, e.g. `"200,202"` or `"200-299"`. | `string` | `"200-299"` |
| `stickiness_enabled` | Enable `lb_cookie` sticky sessions. | any | `false` |
| `cookie_duration` | Sticky session cookie lifetime in seconds. | any | `"86400"` |

Outputs
-------

| Name | Description |
|------|-------------|
| `target_group_arn` | ARN of the target group. |

How `env` is used
-----------------

The target group name uses only the part of `env` before the first underscore, so
region-suffixed environments share the base name:

| `env` | Target group name | `service` tag |
|-------|-------------------|---------------|
| `live` | `live-<component_name>` | `live-<component_name>` |
| `live_eu-west-2` | `live-<component_name>` | `live_eu-west-2-<component_name>` |

- The name is truncated to 32 characters (the AWS limit) and leading/trailing hyphens are stripped.
- The `env` tag always holds the full `env` value.
- Target group names are unique per region, so `live` and `live_eu-west-2` with the same
  `component_name` must not be deployed to the same region and account.
