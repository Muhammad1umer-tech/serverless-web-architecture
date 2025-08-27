output "serverless_aws_sns_arn" {
    value = aws_sns_topic.data_added_topic.arn
}