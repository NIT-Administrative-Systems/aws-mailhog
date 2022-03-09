variable "hostname" {
  description = "Hostname for Mailhog"
  type        = string
}

variable "region" {
  description = "Region to deploy to."
  type        = string
}

variable "vpc_id" {
  # data.terraform_remote_state.shared_resources.outputs.vpc_id
  description = "Identifier for the VPC"
  type        = string
}

variable "ecs_subnet_ids" {
  # data.terraform_remote_state.shared_resources.outputs.xxxx_subnet_ids
  description = "Subnet ID(s) to deploy ECS to"
  type        = list(string)
}

variable "alb_arn" {
  description = "ARN for your ALB"
  type        = string
}

variable "oicd_client_id" {
  description = "Azure AD client ID"
  default     = "a90b0f2c-4041-4e64-b975-3521a0107cfb"
  type        = string
}

variable "oicd_secret" {
  description = "Azure AD secret for the oicd_client_id"
  type        = string
}

variable "alb_security_group_ids" {
  # [data.terraform_remote_state.shared_resources.outputs.lb_security_group_id]
  description = "Security group(s) for your ALB"
  type        = list(string)
}

variable "smtp_permitted_cidr_blocks" {
  description = "List of IPv4 CIDR blocks permitted to use the SMTP port"
  default = [
    "10.0.0.0/8", # NU LAN (all of it)
  ]
  type = list(string)
}

variable "app_name" {
  description = "Used for tags, names, etc."
  default     = "Mailhog"
  type        = string
}

variable "environment" {
  description = "Used for tags, names, etc"
  default     = "dev"
  type        = string
}

variable "container_cpu" {
  description = "CPU for the ECS task"
  default     = 256
  type        = number
}

variable "container_memory" {
  description = "Memory for the ECS task"
  default     = 1024
  type        = number
}

variable "container_image" {
  description = "Mailhog Docker image to use. Can be a Dockerhub ref or a URL w/ tag."
  default     = "mailhog/mailhog:latest"
  type        = string
}

variable "health_check_grace_period" {
  description = "ALB health check grace period when starting a task"
  default     = 90
  type        = number
}

locals {
  full_name      = "${var.app_name} - ${var.environment}"
  full_name_slug = replace("${var.app_name} ${var.environment}", " ", "-")
  web_port       = 8025
}