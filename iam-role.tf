resource "aws_iam_role" "mailhog" {
  name               = "instance_role_policy_${var.app_name}"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "mailhog" {
  name   = "ecsTaskExecutionRolePolicy-${var.app_name}"
  role   = aws_iam_role.mailhog.name
  policy = data.aws_iam_policy_document.alb_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "task" {
  role       = aws_iam_role.mailhog.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "alb_policy_doc" {
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterTargets",
    ]
    resources = [aws_alb_target_group.webserver.arn]
  }
}