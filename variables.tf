# required
variable "env" {
  description = "The name of the environment (included at the front of the DNS name with a hyphen if not live)"
}

variable "component_name" {
  type        = "string"
  description = "The name of the component - used by default for the DNS entry (with the -service suffix removed), as well as to give the target group a meaningful name"
}

variable "vpc_id" {
  description = "The ID of the VPC to create the target group in"
  type        = "string"
}

variable "alb_listener_arn" {
  description = "Listener to add the rule(s) to"
  type        = "string"
}

variable "path_conditions" {
  description = "Defines path-based conditions for routing - e.g. ['/home', '/home/*']"
  type        = "list"
}

variable "starting_priority" {
  description = "Starting priority for rules that will be added"
}

# optional
variable "host_condition" {
  description = "Defines host-based condition for rule (domain name)"
  type        = "string"
  default     = "*.*"
}

variable "deregistration_delay" {
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds."
  type        = "string"
  default     = "10"
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds."
  type        = "string"
  default     = "5"
}

variable "health_check_path" {
  description = "The destination for the health check request."
  type        = "string"
  default     = "/internal/healthcheck"
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check."
  type        = "string"
  default     = "4"
}

variable "health_check_healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
  type        = "string"
  default     = "2"
}

variable "health_check_unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering the target unhealthy."
  type        = "string"
  default     = "2"
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
  type        = "string"
  default     = "200-299"
}

variable "stickiness_enabled" {
  description = "Turn sticky sessions on or off"
  default = false
}

variable "cookie_duration" {
  description = "How long sticky session cookie lasts"
  default = "86400"
}

variable "port" {
  description = "Target port. For ECS service port will be set dynamically."
  default = "31337"
}

variable "target_type" {
  description = "The possible values are instance, ip or lambda."
  default = "instance"
}
