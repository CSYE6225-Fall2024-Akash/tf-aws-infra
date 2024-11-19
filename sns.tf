# SNS Topic
resource "aws_sns_topic" "user_verification" {
  name = "${var.environment}-user-verification"
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.user_verification.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_role.webapp_role.arn
      }
      Action   = "SNS:Publish"
      Resource = aws_sns_topic.user_verification.arn
    }]
  })
}

# SNS Topic Subscription for Lambda
resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.user_verification.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.email_verification.arn
}

# Lambda permission to allow SNS to invoke it
resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.email_verification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_verification.arn
}

