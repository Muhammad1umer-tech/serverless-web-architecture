resource "aws_sns_topic" "data_added" {
  name = "${var.project_name}-data-added"
}

resource "aws_sns_topic_subscription" "admin_email" {
  topic_arn = aws_sns_topic.data_added.arn
  protocol  = "email"
  endpoint  = var.admin_email
}