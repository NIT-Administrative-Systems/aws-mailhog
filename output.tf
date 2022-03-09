output "log_group_name" {
  description = "Name of the ECS task's log group. Useful for forwarding logs to DataDog."
  value       = aws_cloudwatch_log_group.logs.name
}